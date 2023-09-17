import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:unichat_ai/constants/api_consts.dart';
import 'package:unichat_ai/models/message.dart';
import 'package:unichat_ai/services/shared_preferences_helper.dart';
import 'dart:convert' show utf8;

class ApiService{
  
  static Future<Message> sendMessage({required List<Message> messages})async {
    log("all messages: ${(messages.map((m) => {"role": m.isUser, "content": m.content})).join(', ')}");
    try{
      String API_KEY = await SharedPreferencesHelper.getAPIKey() ?? "no API key registered"; 
      String selectedGPT = await SharedPreferencesHelper.getSelectedGPT() ?? "gpt-3.5-turbo";
      print("----------------------------------$API_KEY");
      var requestBody = jsonEncode({
          "model": "$selectedGPT",
          "messages": messages.map((message) => {
            "role": message.isUser, 
            "content": message.content
          }).toList()//..add({
          //"role": "user", "content": newMessage
          //})
        });

      var response = await http.post(
        Uri.parse("$BASE_URL/chat/completions"),
        headers: {'Authorization': 'Bearer $API_KEY', 
        "Content-Type": "application/json; charset=UTF-8"},
        body: requestBody);

      log("full post: $requestBody");
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
      //log("jsonResponse[\"choices\"]: ${jsonResponse["choices"]}");  // <-- Log the "choices" part of the response
      
      if (jsonResponse["choices"].length > 0) {
        String fullResponse = jsonResponse["choices"][0]["message"]["content"];
        
        // Split the full response at "Translation:"
        List<String> responsePartsTranslation = fullResponse.split("Translation:");
        String mainContent = responsePartsTranslation[0].trim();  // Before "Translation:"
        
        String translation = "";
        String feedback = "";
        
        if (responsePartsTranslation.length > 1) {  // Check if "Translation:" was present
          // Split the remaining part at "Feedback:"
          List<String> responsePartsFeedback = responsePartsTranslation[1].split("Feedback:");
          translation = responsePartsFeedback[0].trim();  // Between "Translation:" and "Feedback:"
          
          if (responsePartsFeedback.length > 1) {  // Check if "Feedback:" was present
              feedback = responsePartsFeedback[1].trim();
          }
        }
        log("main $mainContent       translation: $translation         feedback: $feedback");
        return Message(content: mainContent, translation: translation, feedback: feedback, isUser: "assistant");
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

  static Future<Message> fetchInitialReply(String content) async {
  try{
    String API_KEY = await SharedPreferencesHelper.getAPIKey() ?? "no API key registered"; 
    String selectedGPT = await SharedPreferencesHelper.getSelectedGPT() ?? "gpt-3.5-turbo";
    print("----------------------------------$API_KEY");
    log("all messages: $content");
    var response = await http.post(
      Uri.parse("$BASE_URL/chat/completions"),
      headers: {'Authorization': 'Bearer $API_KEY', 
      "Content-Type": "application/json; charset=UTF-8"},
      body: jsonEncode({
        "model": "$selectedGPT",
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
      
      // Split the full response at "Translation:"
      List<String> responsePartsTranslation = fullResponse.split("Translation:");
      String mainContent = responsePartsTranslation[0].trim();  // Before "Translation:"
      
      String translation = "";
      String feedback = "";
      
      if (responsePartsTranslation.length > 1) {  // Check if "Translation:" was present
        // Split the remaining part at "Feedback:"
        List<String> responsePartsFeedback = responsePartsTranslation[1].split("Feedback:");
        translation = responsePartsFeedback[0].trim();  // Between "Translation:" and "Feedback:"
        
        if (responsePartsFeedback.length > 1) {  // Check if "Feedback:" was present
            feedback = responsePartsFeedback[1].trim();
        }
      }
      log("main $mainContent       translation: $translation         feedback: $feedback");
      return Message(content: mainContent, translation: translation, feedback: feedback, isUser: "assistant");
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


