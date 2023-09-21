/* eslint-disable require-jsdoc */
import * as functions from "firebase-functions";
import fetch from "node-fetch";

const BASE_URL = "https://api.openai.com/v1";

async function sendMessage(data: any) {
  const selectedGPT = data.selectedGPT || "gpt-3.5-turbo";
  const messages = data.messages;

  if (!messages || !Array.isArray(messages)) {
    throw new Error(messages+" must be an array.");
  }

  if (messages.some((message: any) => !message.role || !message.content)) {
    // eslint-disable-next-line max-len
    throw new Error("role and content are required properties for each message.");
  }

  const requestBody = JSON.stringify({
    model: selectedGPT,
    messages: messages.map((message: any) => ({
      role: message.role,
      content: message.content,
    })),
  });

  const response = await fetch(`${BASE_URL}/chat/completions`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${functions.config().openai.key}`,
      "Content-Type": "application/json",
    },
    body: requestBody,
  });

  if (!response.ok) {
    const errorData = await response.text();
    throw new Error(`OpenAI request failed: ${errorData}`);
  }

  const responseData = await response.json();
  const latestMessage = responseData.choices?.[0]?.message?.content;
  return {content: latestMessage};
}

// eslint-disable-next-line max-len
export const sendFunctionMessage = functions.region("europe-west1").https.onRequest(async (request, response) => {
  try {
    if (request.method !== "POST") {
      response.status(405).send("Method Not Allowed");
      return;
    }

    const data = request.body;
    const result = await sendMessage(data);
    response.status(200).send(result);
  } catch (error) {
    response.status(500).send((error as Error).message || "An error occurred.");
  }
});
