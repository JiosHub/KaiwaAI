/* eslint-disable require-jsdoc */
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import fetch from "node-fetch";

const BASE_URL = "https://api.openai.com/v1";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

exports.createUserRecord = functions.auth.user().onCreate((user) => {
  return admin.firestore().collection("users").doc(user.uid).set({
    gpt4_message_count: 25,
    gpt3_5_message_count: 100,
    // other initial fields if necessary
  });
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
      console.error("Error verifying token", error);
      response.status(403).send("Unauthorized");
      return;
    }
    console.log("3 "+uid);
    if (!uid) {
      response.status(403).send("UID not found after token verification");
      return;
    }
    console.log("4");
    // Fetch the user"s data from Firestore
    const userRef = db.collection("users").doc(uid);
    const userData = await userRef.get();
    const userDocData = await userData.data();
    console.log("5 "+ userData);
    let messageCountGPT4 = 0;
    let messageCountGPT35 = 0;

    if (userDocData) {
      messageCountGPT4 = userDocData.gpt4_message_count;
      messageCountGPT35 = userDocData.gpt3_5_message_count;
      console.log("7 " + messageCountGPT4 + " " + messageCountGPT35);
    } else {
      console.log("Failed to retrieve data for user.");
    }

    console.log("6");
    // {data:{selectedGPT:, messages:[{role:,content:,}]}}
    const requestData = request.body.data;
    // eslint-disable-next-line max-len
    const selectedGPT = requestData.selectedGPT;
    const messages = requestData.messages;
    console.log("7 "+messageCountGPT4+messageCountGPT35);
    if (selectedGPT === "gpt-4" && messageCountGPT4 >= 0) {
      // Handle this case
      response.status(400).send("Message limit reached for gpt-4");
      return;
    // eslint-disable-next-line max-len
    } else if (selectedGPT === "gpt-3.5-turbo" && messageCountGPT35 >= 0) {
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
        "Authorization": "Bearer ",
        "Content-Type": "application/json",
      },
      body: requestBody,
    });
    console.log("10");
    if (!apiResponse.ok) {
      const errorData = await apiResponse.text();
      console.log(`OpenAI request failed: ${errorData}`);
      throw new Error(`OpenAI request failed: ${errorData}`);
    }
    console.log("11");
    const responseData = await apiResponse.json();
    const latestMessage = responseData.choices?.[0]?.message?.content;
    console.log("12");
    if (selectedGPT === "gpt-4") {
      await userRef.update({
        gpt3_5_message_count: admin.firestore.FieldValue.increment(-1),
      });
    } else if (selectedGPT === "gpt-3.5-turbo") {
      await userRef.update({
        gpt4_message_count: admin.firestore.FieldValue.increment(-1),
      });
    }
    console.log("13");
    response.send({data: {content: latestMessage}});
  } catch (error) {
    response.status(500).send((error as Error).message || "An error occurred.");
  }
});
