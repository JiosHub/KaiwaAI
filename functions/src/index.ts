/* eslint-disable require-jsdoc */
import * as functions from "firebase-functions";
import fetch from "node-fetch";

const BASE_URL = "https://api.openai.com/v1";

// eslint-disable-next-line max-len
export const sendFunctionMessage = functions.region("europe-west1").https.onRequest(async (request, response) => {
  try {
    // {data:{selectedGPT:, messages:[{role:,content:,}]}}
    const requestData = request.body.data;
    // eslint-disable-next-line max-len
    const selectedGPT = requestData.selectedGPT || "gpt-3.5-turbo";
    const messages = requestData.messages;

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
        "Authorization": "Bearer API_KEY",
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

    response.send({data: {content: latestMessage}});
  } catch (error) {
    response.status(500).send((error as Error).message || "An error occurred.");
  }
});
