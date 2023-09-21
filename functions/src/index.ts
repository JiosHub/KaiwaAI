/* eslint-disable require-jsdoc */
import * as functions from "firebase-functions";
import fetch from "node-fetch";

const BASE_URL = "https://api.openai.com/v1";

async function sendMessage(data: any) {
  console.log("1"+data.selectedGPT+" "+data.messages);
  const selectedGPT = data.selectedGPT || "gpt-3.5-turbo";
  const messages = data.messages;
  let requestBody = "undefined";
  console.log("1.5 "+messages[0].content);
  if (!Array.isArray(messages)) {
    console.log(messages[0].selectedGPT+" not array (first message).");
    requestBody = JSON.stringify({
      "model": messages[0].selectedGPT,
      "messages": ["role:", "system", "content:", messages[0].content],
    });
    // throw new Error(messages+" must be an array.");
  } else {
    console.log("is array");
    requestBody = JSON.stringify({
      "model": selectedGPT,
      "messages": messages.map((message: any) => ({
        "role": message.role,
        "content": message.content,
      })),
    });
  }
  console.log("2");

  const response = await fetch(`${BASE_URL}/chat/completions`, {
    method: "POST",
    headers: {
      // eslint-disable-next-line max-len
      "Authorization": "Bearer ",
      "Content-Type": "application/json",
    },
    body: requestBody,
  });
  console.log("5");

  if (!response.ok) {
    const errorData = await response.text();
    console.log(`OpenAI request failed: ${errorData}`);
    throw new Error(`OpenAI request failed: ${errorData}`);
  }
  console.log("6");

  const responseData = await response.json();
  console.log("7");
  const latestMessage = responseData.choices?.[0]?.message?.content;
  console.log("8");
  return {content: latestMessage};
}

// eslint-disable-next-line max-len
export const sendFunctionMessage = functions.region("europe-west1").https.onRequest(async (request, response) => {
  try {
    console.log("Function triggered.");
    console.log("Request method:", request.method);
    console.log("Request headers:", JSON.stringify(request.headers));
    console.log("Request body:", JSON.stringify(request.body));
    if (request.method !== "POST") {
      response.status(405).send("Method Not Allowed");
      return;
    }
    console.log("passed if");
    const data = request.body;
    console.log("passed data const");
    const result = await sendMessage(data);
    console.log("sendMessage returned");
    response.status(200).send(result);
  } catch (error) {
    response.status(500).send((error as Error).message || "An error occurred.");
  }
});
