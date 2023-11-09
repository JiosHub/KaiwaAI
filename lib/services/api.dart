import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:unichat_ai/constants/api_consts.dart';
import 'package:unichat_ai/models/message.dart';
import 'package:unichat_ai/services/shared_preferences_helper.dart';
import 'dart:convert' show utf8;

class ApiService{

  static RegExp expTrans = new RegExp("translation:", caseSensitive: false);
  static RegExp expFeed = new RegExp("feedback:", caseSensitive: false);

  static Future<Map<String, int>?> getMessageLimitCount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("User not logged in!");
        return null;
      }

      final idToken = await user.getIdToken();

      FirebaseFunctions functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
      //functions.useFunctionsEmulator('localhost', 5001);
      final response = await functions.httpsCallable('checkMessageCount').call();

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      final gpt4MessageCount = data['gpt4_message_count'] as int;
      final gpt35MessageCount = data['gpt3_5_message_count'] as int;

      print("GPT-4 Message Count: $gpt4MessageCount");
      print("GPT-3.5 Message Count: $gpt35MessageCount");
      return {
        'gpt4_message_count': gpt4MessageCount,
        'gpt3_5_message_count': gpt35MessageCount,
      };
    } catch (e) {
      print("Error calling checkMessageCount: $e");
      return null;
    }
  }


  static Future<Message> sendFunctionMessage({required List<Message> messages})async {
    try{
      FirebaseFunctions functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
      //functions.useFunctionsEmulator('localhost', 5001);
      print("----------------------$functions");
      String selectedGPT = await SharedPreferencesHelper.getSelectedGPT() ?? "gpt-3.5-turbo";
      final dataToSend = {
        'selectedGPT': selectedGPT, // or any other model you want
        'messages': messages.map((message) => {
          "role": message.isUser,
          "content": message.content
        }).toList()
      };
      final response = await functions.httpsCallable('sendFunctionMessage').call(dataToSend);
      print("Response from Firebase Function: ${response.data}");
      
      // Split the full response at "Translation:"
      final Map<String, dynamic> data = response.data;
      final fullResponse = data['content'];
      String cleanResponse = fullResponse.replaceAll(RegExp(r'[()]'), '');

      List<String> responsePartsTranslation = cleanResponse.split(expTrans);
      String mainContent = responsePartsTranslation[0].trim();  // Before "Translation:"

      String translation = "";
      String feedback = "";

      if (responsePartsTranslation.length > 1) {  // Check if "Translation:" was present
        // Split the remaining part at "Feedback:"
        List<String> responsePartsFeedback = responsePartsTranslation[1].split(expFeed);
        translation = responsePartsFeedback[0].trim();  // Between "Translation:" and "Feedback:"
        
        if (responsePartsFeedback.length > 1) {  // Check if "Feedback:" was present
            feedback = responsePartsFeedback[1].trim();
        }
      }
      print("main $mainContent       translation: $translation         feedback: $feedback");
      return Message(content: mainContent, translation: translation, feedback: feedback, isUser: "assistant");

    }catch(error){
      if (error is FirebaseFunctionsException) {
        print('Error code: ${error.code}');
        print('Error message: ${error.message}');
        print('Error details: ${error.details}');
      } else {
        print('Other error: $error');
      }
      rethrow;
    }
  }

  static Future<Message> fetchFirstFunctionMessage(String content) async {
    try{
      //curl -X POST -H "Content-Type: application/json" -d '{"selectedGPT": "gpt-3.5-turbo", "messages": [{"role": "system", "content": "content"}]}' https://europe-west1-unichat-ai.cloudfunctions.net/sendFunctionMessage

      FirebaseFunctions functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
      //functions.useFunctionsEmulator('10.0.2.2', 5001);
      print("----------------------${functions}");
      String selectedGPT = await SharedPreferencesHelper.getSelectedGPT() ?? "gpt-3.5-turbo";
      print("----------------------$selectedGPT");
      final dataToSend = {
        "selectedGPT": selectedGPT, // or any other model you want
        "messages": [{
          "role": "system",
          "content": content
        }]
      };

      print('Sending data: $dataToSend');
      final response = await functions.httpsCallable('sendFunctionMessage').call(dataToSend);
      print("Response from Firebase Function: ${response.data}");
      
      // Split the full response at "Translation:"
      final Map<String, dynamic> data = response.data;
      final fullResponse = data['content'];
      String cleanResponse = fullResponse.replaceAll(RegExp(r'[()]'), '');
      
      List<String> responsePartsTranslation = cleanResponse.split(expTrans);
      String mainContent = responsePartsTranslation[0].trim();  // Before "Translation:"
      
      String translation = "";
      String feedback = "";
      
      if (responsePartsTranslation.length > 1) {  // Check if "Translation:" was present
        // Split the remaining part at "Feedback:"
        List<String> responsePartsFeedback = responsePartsTranslation[1].split(expFeed);
        translation = responsePartsFeedback[0].trim();  // Between "Translation:" and "Feedback:"
        
        if (responsePartsFeedback.length > 1) {  // Check if "Feedback:" was present
            feedback = responsePartsFeedback[1].trim();
        }
      }
      print("main $mainContent       translation: $translation         feedback: $feedback");
      return Message(content: mainContent, translation: translation, feedback: feedback, isUser: "assistant");
    }catch(error){
      if (error is FirebaseFunctionsException) {
        print('Error code: ${error.code}');
        print('Error message: ${error.message}');
        print('Error details: ${error.details}');
      } else {
        print('Other error: $error');
      }
      rethrow;
    }
  }
  
  static Future<Message> sendMessage({required List<Message> messages})async {
    print("all messages: ${(messages.map((m) => {"role": m.isUser, "content": m.content})).join(', ')}");
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

      print("full post: $requestBody");
      // Decode the response body as UTF-8
      String decodedResponse = utf8.decode(response.bodyBytes);
      
      // Parse the decoded response as JSON
      Map jsonResponse = jsonDecode(decodedResponse);

      //Map jsonResponse = jsonDecode(response.body);
      print("jsonResponse: $jsonResponse");  // <-- Log the entire JSON response

      if(jsonResponse['error'] != null){
        //print("jsonResponse['error']['message'] ${jsonResponse['error']['message']}");
        throw HttpException(jsonResponse['error']['message']);
      }
      //log("jsonResponse[\"choices\"]: ${jsonResponse["choices"]}");  // <-- Log the "choices" part of the response
      
      if (jsonResponse["choices"].length > 0) {
        String fullResponse = jsonResponse["choices"][0]["message"]["content"];
        String cleanResponse = fullResponse.replaceAll(RegExp(r'[()]'), '');
        
        // Split the full response at "Translation:"
        List<String> responsePartsTranslation = cleanResponse.split(expTrans);
        String mainContent = responsePartsTranslation[0].trim();  // Before "Translation:"
        
        String translation = "";
        String feedback = "";
        
        if (responsePartsTranslation.length > 1) {  // Check if "Translation:" was present
          // Split the remaining part at "Feedback:"
          List<String> responsePartsFeedback = responsePartsTranslation[1].split(expFeed);
          translation = responsePartsFeedback[0].trim();  // Between "Translation:" and "Feedback:"
          
          if (responsePartsFeedback.length > 1) {  // Check if "Feedback:" was present
              feedback = responsePartsFeedback[1].trim();
          }
        }
        print("main $mainContent       translation: $translation         feedback: $feedback");
        return Message(content: mainContent, translation: translation, feedback: feedback, isUser: "assistant");
      }

      return Message(
          content: "Sorry, I couldn't process that request.",
          feedback: "",
          isUser: "error"
      );

    }catch(error){
      print("error $error");
      rethrow;
    }
  }

  static Future<Message> fetchFirstMessage(String content) async {
  try{
    String API_KEY = await SharedPreferencesHelper.getAPIKey() ?? "no API key registered"; 
    String selectedGPT = await SharedPreferencesHelper.getSelectedGPT() ?? "gpt-3.5-turbo";
    print("----------------------------------$API_KEY");
    print("all messages: $content");
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
    print("jsonResponse: $jsonResponse");  // <-- Log the entire JSON response

    if(jsonResponse['error'] != null){
      //print("jsonResponse['error']['message'] ${jsonResponse['error']['message']}");
      throw HttpException(jsonResponse['error']['message']);
    }

    if (jsonResponse["choices"].length > 0) {
      String fullResponse = jsonResponse["choices"][0]["message"]["content"];
      String cleanResponse = fullResponse.replaceAll(RegExp(r'[()]'), '');
      
      // Split the full response at "Translation:"
      List<String> responsePartsTranslation = cleanResponse.split(expTrans);
      String mainContent = responsePartsTranslation[0].trim();  // Before "Translation:"
      
      String translation = "";
      String feedback = "";
      
      if (responsePartsTranslation.length > 1) {  // Check if "Translation:" was present
        // Split the remaining part at "Feedback:"
        List<String> responsePartsFeedback = responsePartsTranslation[1].split(expFeed);
        translation = responsePartsFeedback[0].trim();  // Between "Translation:" and "Feedback:"
        
        if (responsePartsFeedback.length > 1) {  // Check if "Feedback:" was present
            feedback = responsePartsFeedback[1].trim();
        }
      }
      print("main $mainContent       translation: $translation         feedback: $feedback");
      return Message(content: mainContent, translation: translation, feedback: feedback, isUser: "assistant");
    }


      return Message(
          content: "Sorry, I couldn't process that request.",
          feedback: "",
          isUser: "error"
      );

  }catch(error){
    print("error $error");
    rethrow;
  }
  }
}