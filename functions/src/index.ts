import * as functions from "firebase-functions";
import fetch from "node-fetch";
// import * as admin from "firebase-admin";

const BASE_URL = "https://api.openai.com/v1"; // I'm assuming this is the base URL

export const sendFunctionMessage =
functions.https.onCall(async (data) => {
  // try {
  // const idToken = request.headers.authorization;
  // or wherever you put the token
  // const decodedToken = await admin.auth().verifyIdToken(idToken);
  // const uid = decodedToken.uid;

  // } catch (error) {
  // response.status(401).send("Unauthorized");
  // return;
  // }
  // eslint-disable-next-line
  const API_KEY = "";
  // Place your API key here
  const selectedGPT = data.selectedGPT; // Default value
  const messages = data.messages;

  // If you're using Firebase Firestore to store preferences,
  // you can retrieve it like:
  // const preferences =
  // await admin.firestore().collection('preferences').doc('someDocId').get();
  // selectedGPT = preferences.data()?.selectedGPT || 'gpt-3.5-turbo';

  const requestBody = JSON.stringify({
    model: selectedGPT,
    messages: messages.map((message: any) => ({
      role: message.isUser,
      content: message.content,
    })),
  });

  try {
    const response = await fetch(`${BASE_URL}/chat/completions`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${API_KEY}`,
        "Content-Type": "application/json",
      },
      body: requestBody,
    });

    const jsonResponse = await response.json();

    if (jsonResponse.error) {
      throw new Error(jsonResponse.error.message);
    }

    if (jsonResponse.choices && jsonResponse.choices.length > 0) {
      const fullResponse = jsonResponse.choices[0].message.content;
      return {content: fullResponse};
      // content: jsonResponse.choices[0].message.content,
      // isUser: "assistant",
    } else {
      throw new functions.https.HttpsError("internal",
        "An internal error occurred.");
    }
  } catch (error) {
    console.error("Error in sendMessage function:", error);
    throw new functions.https.HttpsError("internal",
      "An internal error occurred.");
  }
});
