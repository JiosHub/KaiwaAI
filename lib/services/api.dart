import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kaiwaai/constants/api_consts.dart';
import 'package:kaiwaai/models/message.dart';

class ApiService{
  static Future<void> sendMessage({required String message})async {
    try{
      var response = await http.post(
        Uri.parse("$BASE_URL/completions"),
        headers: {'Authorization': 'Bearer $API_KEY', 
        "Content-Type": "application/json"},
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "prompt": message,
          "max_tokens": 200
          })
        );

      Map jsonResponse = jsonDecode(response.body);

      if(jsonResponse['error'] != null){
        //print("jsonResponse['error']['message'] ${jsonResponse['error']['message']}");
        throw HttpException(jsonResponse['error']['message']);
      }
      
      if(jsonResponse["choices"].length > 0){
        log("jsonResponse[choices]text ${jsonResponse["choices"]["text"]}");
      }

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