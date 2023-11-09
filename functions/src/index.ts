/* eslint-disable linebreak-style */
/* eslint-disable require-jsdoc */
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {google} from "googleapis";
import fetch from "node-fetch";
import * as nodemailer from "nodemailer";

// eslint-disable-next-line @typescript-eslint/no-var-requires
const BASE_URL = "https://api.openai.com/v1";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();
const gmailEmail = functions.config().gmail.email;
const gmailPassword = functions.config().gmail.password;

const mailTransport = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: gmailEmail,
    pass: gmailPassword,
  },
});

// eslint-disable-next-line max-len
export const sendEmail = functions.region("europe-west1").https.onCall(async (data, context) => {
  const userEmail = data.email;
  const subject = `Message from ${userEmail}`;
  const text = data.message;

  const mailOptions = {
    from: `UniChat AI <${userEmail}>`,
    to: "jiiosjos@gmail.com",
    subject: subject,
    text: text,
  };

  try {
    await mailTransport.sendMail(mailOptions);
    console.log("Email sent to:", mailOptions.to);
    return {success: true};
  } catch (error) {
    console.error("There was an error while sending the email:", error);
    return {success: false};
  }
});

// eslint-disable-next-line max-len
exports.createUserRecord = functions.region("europe-west1").auth.user().onCreate(async (user) => {
  const userRef = admin.firestore().collection("users").doc(user.uid);

  // Retrieve the newly created user document
  const newUserDoc = await userRef.get();

  if (!newUserDoc.exists) {
    console.error(`No document found for user ${user.uid}`);
    return null; // Exit if no user document is found
  }

  const userData = newUserDoc.data();

  if (!userData || !userData.deviceID) {
    // eslint-disable-next-line max-len
    console.error("User data is not available or deviceID is missing for user:", user.uid);
    return null; // Exit if no device ID is found
  }

  const deviceID = userData.deviceID;

  // Check for existing users with the same device ID
  const existingUsers = await admin.firestore().collection("users")
    .where("deviceID", "==", deviceID)
    .get();

  let duplicateFound = false;

  existingUsers.forEach((doc) => {
    if (doc.id !== user.uid) {
      duplicateFound = true;
    }
  });

  let gpt4MessageCount = 50;
  let gpt35MessageCount = 100;

  if (duplicateFound) {
    // Set message counts to 0
    gpt4MessageCount = 0;
    gpt35MessageCount = 0;
    // eslint-disable-next-line max-len
  }

  // Update the user document with the message counts
  return userRef.set({
    gpt4_message_count: gpt4MessageCount,
    gpt3_5_message_count: gpt35MessageCount,
    // Ensure we don't remove existing fields with merge: true
  }, {merge: true});
});

// eslint-disable-next-line max-len
export const updateUserValues = functions.region("europe-west1").https.onCall(async (data, context) => {
  // Authentication check at the beginning is good.
  if (!context.auth) {
    // eslint-disable-next-line max-len
    throw new functions.https.HttpsError("unauthenticated", "The function must be called while authenticated.");
  }

  const userId = context.auth.uid;
  const purchaseDetails = JSON.parse(data.purchaseToken);
  const orderId = purchaseDetails.orderId;
  const incrementValue = data.productId === "100messages" ? 100 : 500;

  // Use a global orders collection with the orderId as the document reference
  const orderRef = admin.firestore().collection("orders").doc(orderId);

  await admin.firestore().runTransaction(async (transaction) => {
    // First, check if the order ID has already been processed
    const orderSnapshot = await transaction.get(orderRef);
    if (orderSnapshot.exists) {
      // If the order exists, throw to abort the transaction
      // eslint-disable-next-line max-len
      throw new functions.https.HttpsError("already-exists", "This order has already been processed.");
    }

    // Authenticate with the service account
    const serviceAccountEmail = functions.config().serviceaccount.email;
    // eslint-disable-next-line max-len
    const privateKey = functions.config().serviceaccount.key.replace(/\\n/g, "\n");
    const jwtClient = new google.auth.JWT(
      serviceAccountEmail,
      undefined,
      privateKey,
      ["https://www.googleapis.com/auth/androidpublisher"]
    );
    await jwtClient.authorize();

    // Verify the purchase with Android Developer API
    const play = google.androidpublisher({version: "v3", auth: jwtClient});
    const response = await play.purchases.products.get({
      packageName: "com.jios.unichat_ai",
      productId: data.productId,
      token: purchaseDetails.purchaseToken,
    });

    // Check if the purchase is valid
    if (response.status !== 200) {
      // eslint-disable-next-line max-len
      throw new functions.https.HttpsError("internal", "Failed to verify purchase.");
    }

    // If the purchase is valid, create the order document to lock this order ID
    transaction.set(orderRef, {
      userId: userId,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      // ... any other order details
    });

    // Update the user's message count in their document
    const userDocRef = admin.firestore().collection("users").doc(userId);
    transaction.update(userDocRef, {
      // eslint-disable-next-line max-len
      gpt3_5_message_count: admin.firestore.FieldValue.increment(incrementValue),
      gpt4_message_count: admin.firestore.FieldValue.increment(incrementValue),
      // ... any other user updates
    });
  });

  // If the transaction was successful, return a success message
  return {success: true, message: "Purchase verified and user values updated."};
});


// eslint-disable-next-line max-len
export const checkMessageCount = functions.region("europe-west1").https.onCall(async (data, context) => {
  // If the user is not authenticated, throw an error
  if (!context.auth) {
    // eslint-disable-next-line max-len
    throw new functions.https.HttpsError("unauthenticated", "The function must be called while authenticated.");
  }

  const uid = context.auth.uid;

  // Fetch the user"s data from Firestore
  const userRef = db.collection("users").doc(uid);
  const userData = await userRef.get();
  const userDocData = userData.data();

  // If data doesn"t exist for the user, throw an error
  if (!userDocData) {
    throw new functions.https.HttpsError("not-found", "User data not found");
  }

  // Retrieve the message counts
  const messageCountGPT4 = userDocData.gpt4_message_count;
  const messageCountGPT35 = userDocData.gpt3_5_message_count;
  console.log(messageCountGPT4 +" "+ messageCountGPT35);
  // Return the counts as a response
  return {
    gpt4_message_count: messageCountGPT4,
    gpt3_5_message_count: messageCountGPT35,
  };
});

// eslint-disable-next-line max-len
export const sendFunctionMessage = functions.region("europe-west1").https.onRequest(async (request, response) => {
  try {
    const userIdToken = request.get("Authorization")?.split("Bearer ")[1];
    console.log(userIdToken);
    let uid: string | undefined;

    if (!userIdToken) {
      response.status(403).send("Unauthorized");
      return;
    }

    try {
      const decodedToken = await admin.auth().verifyIdToken(userIdToken);
      uid = decodedToken.uid;
    } catch (error) {
      response.status(403).send("Unauthorized");
      return;
    }
    console.log("User ID:", uid);
    const userRef = db.collection("users").doc(uid);
    const userData = await userRef.get();
    console.log("Document exists:", userData.exists);
    console.log("User Info:", JSON.stringify(userData.data()));
    if (!userData.exists) {
      // Handle the case where the user"s data doesn"t exist
      response.status(404).send("User data not found");
      return;
    }
    const messageCountGPT4 = userData.get("gpt4_message_count");
    const messageCountGPT35 = userData.get("gpt3_5_message_count");

    // {data:{selectedGPT:, messages:[{role:,content:,}]}}
    const requestData = request.body.data;
    const selectedGPT = requestData.selectedGPT;
    const messages = requestData.messages;

    if (selectedGPT === "gpt-4-1106-preview" && messageCountGPT4 <= 0) {
      // Handle this case
      response.status(400).send("Message limit reached for gpt-4");
      return;
    // eslint-disable-next-line max-len
    } else if (selectedGPT === "gpt-3.5-turbo" && messageCountGPT35 <= 0) {
      // Handle this case
      response.status(400).send("Message limit reached for gpt-3.5-turbo");
      return;
    }
    let requestBody = "undefined";

    if (!Array.isArray(messages)) {
      throw new Error(messages+" must be an array.");
    } else {
      requestBody = JSON.stringify({
        "model": selectedGPT,
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        "messages": messages.map((message: any) => ({
          "role": message.role,
          "content": message.content,
        })),
      });
    }

    const apiResponse = await fetch(`${BASE_URL}/chat/completions`, {
      method: "POST",
      headers: {
        // eslint-disable-next-line max-len
        "Authorization": "Bearer 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",
        "Content-Type": "application/json",
      },
      body: requestBody,
    });
    if (!apiResponse.ok) {
      const errorData = await apiResponse.text();
      console.log(`OpenAI request failed: ${errorData}`);
      throw new Error(`OpenAI request failed: ${errorData}`);
    }

    const responseData = await apiResponse.json();
    const latestMessage = responseData.choices?.[0]?.message?.content;

    if (selectedGPT === "gpt-4-1106-preview") {
      await userRef.update({
        gpt4_message_count: admin.firestore.FieldValue.increment(-1),
      });
    } else if (selectedGPT === "gpt-3.5-turbo") {
      await userRef.update({
        gpt3_5_message_count: admin.firestore.FieldValue.increment(-1),
      });
    }

    response.send({data: {content: latestMessage}});
  } catch (error) {
    response.status(500).send((error as Error).message || "An error occurred.");
  }
});
