/* eslint-disable require-jsdoc */
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import fetch from "node-fetch";

const BASE_URL = "https://api.openai.com/v1";


if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// eslint-disable-next-line max-len
exports.createUserRecord = functions.region("europe-west1").auth.user().onCreate(async (user) => {
  // Fetch the newly created user's document from Firestore
  // eslint-disable-next-line max-len
  const newUserDoc = await admin.firestore().collection("users").doc(user.uid).get();

  if (!newUserDoc.exists) {
    console.error(`No document found for user ${user.uid}`);
    return null; // Or handle this case as appropriate for your application
  }
  // eslint-disable-next-line max-len
  const userData = newUserDoc.data() as { deviceID: string, gpt4_message_count?: number, gpt3_5_message_count?: number };

  const deviceID = userData.deviceID;

  // Search for an existing account with this device ID
  // eslint-disable-next-line max-len
  const userSnapshot = await admin.firestore().collection("users").where("deviceID", "==", deviceID).get();

  let gpt4MessageCount = 25;
  let gpt35MessageCount = 100;

  if (!userSnapshot.empty) {
    // An account with this device ID already exists. Fetch the message counts.
    const originalAccount = userSnapshot.docs[0].data();
    gpt4MessageCount = originalAccount.gpt4_message_count || 25;
    gpt35MessageCount = originalAccount.gpt3_5_message_count || 100;
  }

  // Update or set the user's document with the message counts
  return newUserDoc.ref.set({
    gpt4_message_count: gpt4MessageCount,
    gpt3_5_message_count: gpt35MessageCount,
    deviceID: deviceID,
    // other fields if necessary
  });
});

exports.updateUserValues = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    // eslint-disable-next-line max-len
    throw new functions.https.HttpsError("failed-precondition", "The function must be called while authenticated.");
  }
  console.log("1");

  const uid = context.auth.uid;
  const receipt = data.receipt;
  const platform = data.platform;
  const productId = data.productId;
  console.log("2 ", uid, "  ", receipt, "  ", platform, "  ", productId, "  ");

  // Verify the receipt with Google Play API (for Android)
  if (platform === "android") {
    const packageName = "com.jios.unichat_ai";
    // You can get this from the receipt as well
    const purchaseToken = receipt.purchaseID;
    // Adjust based on your client-side receipt structure

    const googlePlayApiUrl = `https://www.googleapis.com/androidpublisher/v3/applications/${packageName}/purchases/products/${productId}/tokens/${purchaseToken}?access_token=YOUR_ACCESS_TOKEN`;
    const response = await fetch(googlePlayApiUrl);
    const responseData = await response.json();
    // eslint-disable-next-line max-len
    console.log("3 ", purchaseToken, "  ", googlePlayApiUrl, "  ", responseData.purchaseState);

    if (responseData.purchaseState !== 0) {
      // The purchase is not valid
      console.log("failed-precondition", "Invalid purchase receipt.");
      // eslint-disable-next-line max-len
      throw new functions.https.HttpsError("failed-precondition", "Invalid purchase receipt.");
    }
    console.log("4 ");

    // eslint-disable-next-line max-len
    // Based on responseData, determine what was purchased and how much to increment
    const incrementValue = responseData.productId === "100_messages" ? 100 :
      responseData.productId === "100_messages" ? 500 : 0;

    const userRef = admin.firestore().doc(`users/${uid}`);
    console.log("5 ", incrementValue, "  ", userRef);

    return userRef.update({
      // eslint-disable-next-line max-len
      ["gpt4_message_count"]: admin.firestore.FieldValue.increment(incrementValue),
      ["gpt3_5_message_count"]: admin.firestore.FieldValue.increment(2000),
    });
  } else {
    // Handle iOS or any other platform if needed
    // eslint-disable-next-line max-len
    throw new functions.https.HttpsError("unimplemented", "Platform not supported.");
  }
});

// eslint-disable-next-line max-len
export const checkMessageCount = functions.region("europe-west1").https.onCall(async (data, context) => {
  // If the user is not authenticated, throw an error
  if (!context.auth) {
    // eslint-disable-next-line max-len
    throw new functions.https.HttpsError("unauthenticated", "The function must be called while authenticated.");
  }

  const uid = context.auth.uid;

  // Fetch the user's data from Firestore
  const userRef = db.collection("users").doc(uid);
  const userData = await userRef.get();
  const userDocData = userData.data();

  // If data doesn't exist for the user, throw an error
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
      // Handle the case where the user's data doesn't exist
      response.status(404).send("User data not found");
      return;
    }
    const messageCountGPT4 = userData.get("gpt4_message_count");
    const messageCountGPT35 = userData.get("gpt3_5_message_count");

    // {data:{selectedGPT:, messages:[{role:,content:,}]}}
    const requestData = request.body.data;
    const selectedGPT = requestData.selectedGPT;
    const messages = requestData.messages;

    if (selectedGPT === "gpt-4" && messageCountGPT4 <= 0) {
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
        "Authorization": "Bearer ",
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

    if (selectedGPT === "gpt-4") {
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
