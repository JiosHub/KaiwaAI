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
    console.log("1");
    const userIdToken = request.get("Authorization")?.split("Bearer ")[1];
    console.log(userIdToken);
    let uid: string | undefined;

    if (!userIdToken) {
      response.status(403).send("Unauthorized");
      return;
    }

    console.log("2");
    try {
      const decodedToken = await admin.auth().verifyIdToken(userIdToken);
      uid = decodedToken.uid;
    } catch (error) {
      response.status(403).send("Unauthorized");
      return;
    }
    console.log("3"+uid);
    const userRef = db.collection("users").doc(uid);
    const userData = await userRef.get();
    console.log("Document exists:", userData.exists);
    console.log("3.5"+ JSON.stringify(userData.data()));
    if (!userData.exists) {
      // Handle the case where the user's data doesn't exist
      response.status(404).send("User data not found");
      return;
    }
    console.log("4");
    const messageCountGPT4 = userData.get("gpt4_message_count");
    const messageCountGPT35 = userData.get("gpt3_5_message_count");
    console.log("5");
    // {data:{selectedGPT:, messages:[{role:,content:,}]}}
    const requestData = request.body.data;
    const selectedGPT = requestData.selectedGPT;
    const messages = requestData.messages;
    console.log("7 "+messageCountGPT4+messageCountGPT35);
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
    console.log("8");
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
    console.log("9");
    const apiResponse = await fetch(`${BASE_URL}/chat/completions`, {
      method: "POST",
      headers: {
        // eslint-disable-next-line max-len
        "Authorization": "Bearer "
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
    console.log("13");
    response.send({data: {content: latestMessage}});
  } catch (error) {
    response.status(500).send((error as Error).message || "An error occurred.");
  }
});
