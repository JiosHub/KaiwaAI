import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kaiwaai/constants/api_consts.dart';
import 'package:kaiwaai/models/message.dart';
import 'dart:convert' show utf8;

class ApiService{
  static Future<Message> sendMessage({required List<Message> messages})async {
    log("all messages: ${(messages.map((m) => {"role": m.isUser, "content": m.content})).join(', ')}");
    try{
      var response = await http.post(
        Uri.parse("$BASE_URL/chat/completions"),
        headers: {'Authorization': 'Bearer $API_KEY', 
        "Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages.map((message) => {
            "role": message.isUser, 
            "content": message.content
          }).toList()//..add({
          //"role": "user", "content": newMessage
          //})
        }));
    
      // Decode the response body as UTF-8
      String decodedResponse = utf8.decode(response.bodyBytes);
      
      // Parse the decoded response as JSON
      Map jsonResponse = jsonDecode(decodedResponse);

      //Map jsonResponse = jsonDecode(response.body);
      log("jsonResponse: $jsonResponse");  // <-- Log the entire JSON response

      if(jsonResponse['error'] != null){
        //print("jsonResponse['error']['message'] ${jsonResponse['error']['message']}");
        throw HttpException(jsonResponse['error']['message']);
      }
      log("jsonResponse[\"choices\"]: ${jsonResponse["choices"]}");  // <-- Log the "choices" part of the response
      
      if (jsonResponse["choices"].length > 0) {
        String fullResponse = jsonResponse["choices"][0]["message"]["content"];
        // Split the full response at "Feedback:"
        List<String> responseParts = fullResponse.split("Feedback:");
        String japanesePartWithTranslation = responseParts[0].trim();

        // Split the Japanese part at "(" to separate the main message and the optional translation
        List<String> japaneseParts = japanesePartWithTranslation.split("(");
        String japanesePart = japaneseParts[0].trim();

        String feedback = responseParts.length > 1 ? responseParts[1].trim() : "";

        return Message(content: japanesePart, feedback: feedback, isUser: "assistant");

        //return fullResponse;
        // Split the full response by the opening bracket "("
        //List<String> responseParts = fullResponse.split("Feedback:");

        // The Japanese part of the message should be the first element of the list
        //String japanesePart = responseParts[0].trim();  // Use trim to remove any leading or trailing whitespace

        //return japanesePart;
      }

      return Message(
          content: "Sorry, I couldn't process that request.",
          feedback: "",
          isUser: "error"
      );

    }catch(error){
      log("error $error");
      rethrow;
    }
  }

  /*static Future<void> getModels({required String message})async {
    try{
      var response = await http.get(
        Uri.parse("$BASE_URL/models"),
        headers: {'Authorization': 'Bearer $API_KEY'},);

      Map jsonResponse = jsonDecode(response.body);

      if(jsonResponse['error'] != null){
        print("jsonResponse['error']['message'] ${jsonResponse['error']['message']}");
        throw HttpException(jsonResponse['error']['message']);
      }
      print("jsonResponse: $jsonResponse");
    }catch(error){
      print("error $error");
    }
  }*/

  static Future<Message> fetchInitialReply(String content) async {
  try{
    log("all messages: $content");
    var response = await http.post(
      Uri.parse("$BASE_URL/chat/completions"),
      headers: {'Authorization': 'Bearer $API_KEY', 
      "Content-Type": "application/json; charset=UTF-8"},
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [{"role": "system", "content": content}]
      }));
    String decodedResponse = utf8.decode(response.bodyBytes);
      
    // Parse the decoded response as JSON
    Map jsonResponse = jsonDecode(decodedResponse);

    //Map jsonResponse = jsonDecode(response.body);
    log("jsonResponse: $jsonResponse");  // <-- Log the entire JSON response

    if(jsonResponse['error'] != null){
      //print("jsonResponse['error']['message'] ${jsonResponse['error']['message']}");
      throw HttpException(jsonResponse['error']['message']);
    }

    if (jsonResponse["choices"].length > 0) {
        String fullResponse = jsonResponse["choices"][0]["message"]["content"];
        List<String> responseParts = fullResponse.split("Feedback:");
        String japanesePartWithTranslation = responseParts[0].trim();
        List<String> japaneseParts = japanesePartWithTranslation.split("(");
        String japanesePart = japaneseParts[0].trim();
        String feedback = responseParts.length > 1 ? responseParts[1].trim() : "";

        return Message(content: japanesePart, feedback: feedback, isUser: "assistant");
      }

      return Message(
          content: "Sorry, I couldn't process that request.",
          feedback: "",
          isUser: "error"
      );

  }catch(error){
    log("error $error");
    rethrow;
  }
  }
}


