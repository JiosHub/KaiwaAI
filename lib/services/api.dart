import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kaiwaai/constants/api_consts.dart';
import 'package:kaiwaai/models/message.dart';

class ApiService{
  static Future<String> sendMessage({required String message})async {
    try{
      var response = await http.post(
        Uri.parse("$BASE_URL/chat/completions"),
        headers: {'Authorization': 'Bearer $API_KEY', 
        "Content-Type": "application/json"},
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [{"role": "user", "content": message}],
          "max_tokens": 200
          })
        );

      Map jsonResponse = jsonDecode(response.body);
      //log("jsonResponse: $jsonResponse");  // <-- Log the entire JSON response

      if(jsonResponse['error'] != null){
        //print("jsonResponse['error']['message'] ${jsonResponse['error']['message']}");
        throw HttpException(jsonResponse['error']['message']);
      }
      log("jsonResponse[\"choices\"]: ${jsonResponse["choices"]}");  // <-- Log the "choices" part of the response
      
      if(jsonResponse["choices"].length > 0){
        //log("jsonResponse[\"choices\"][0]: ${jsonResponse["choices"][0]}");  // <-- Log the first element of "choices"
        //log("jsonResponse[\"choices\"][0][\"text\"]: ${jsonResponse["choices"][0]["text"]}");  // <-- Log the "text" of the first element of "choices"
        return jsonResponse["choices"][0]["message"]["content"];
      }

      return '';

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
}