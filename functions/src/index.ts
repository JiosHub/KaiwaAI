/* eslint-disable require-jsdoc */
import * as functions from "firebase-functions";
import fetch from "node-fetch";

const BASE_URL = "https://api.openai.com/v1";

// eslint-disable-next-line max-len
export const sendFunctionMessage = functions.region("europe-west1").https.onRequest(async (request, response) => {
  try {
    console.log("Function triggered.");
    console.log("Request method:", request.method);
    console.log("Request headers:", JSON.stringify(request.headers));
    console.log("Request body:", JSON.stringify(request.body));
    console.log("passed if");

    // {data:{selectedGPT:, messages:[{role:,content:,}]}}
    const data = request.body.data;
    console.log("passed data const   "+JSON.stringify(request.body));
    // eslint-disable-next-line max-len
    console.log("-------"+JSON.stringify(data.selectedGPT)+" "+JSON.stringify(data.messages));
    const selectedGPT = data.selectedGPT || "gpt-3.5-turbo";
    const messages = data.messages;
    // eslint-disable-next-line max-len
    console.log(messages.length +"   "+ messages.map((message: any) => ({"role": message.role, "content": message.content})));
    let requestBody = "undefined";
    console.log("1.5 "+ JSON.stringify(data));
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
    console.log("2     "+requestBody);

    const apiResponse = await fetch(`${BASE_URL}/chat/completions`, {
      method: "POST",
      headers: {
        // eslint-disable-next-line max-len
        "Authorization": "Bearer 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",
        "Content-Type": "application/json",
      },
      body: requestBody,
    });
    console.log("5");

    if (!apiResponse.ok) {
      const errorData = await apiResponse.text();
      console.log(`OpenAI request failed: ${errorData}`);
      throw new Error(`OpenAI request failed: ${errorData}`);
    }
    console.log("6");

    const responseData = await apiResponse.json();
    console.log("7");
    const latestMessage = responseData.choices?.[0]?.message?.content;
    console.log("8");

    console.log("sendMessage returned");
    response.send({content: latestMessage});
  } catch (error) {
    response.status(500).send((error as Error).message || "An error occurred.");
  }
});
