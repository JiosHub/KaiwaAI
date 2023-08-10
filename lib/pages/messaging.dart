import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kaiwaai/models/message.dart';
import 'package:kaiwaai/services/api.dart';
import 'package:kaiwaai/widgets/message_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MessengerPage extends StatefulWidget {
  @override
  _MessengerPageState createState() => _MessengerPageState();
}

class _MessengerPageState extends State<MessengerPage> {
  List<Message> messages = [];
  List<Message> apiMessages = [];  // List of messages to send to the API
  String currentUser = 'user1';
  bool _isTyping = false;
  final messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Add an initial system message
    apiMessages.add(Message(
      //content: "You are ALWAYS the shop clerk (gpt:). ONLY I will respond as the customer (user). Your messages must contain a Japanese sentence which must be short, and then in English give feedback on the users last replies' Japanese grammar, mark this with \"Feedback:\". Do not translate any Japanese to English and never switch roles.",
      //content: "You are a shop clerk (gpt:). I am the customer (user:). Only I will speak as the user. Respond to me with Japanese sentence which must be short, and then in English give feedback on the users last replies' Japanese grammar, mark this with \"Feedback:\". Do not translate any Japanese to English.",
      //content: "using the topic \"you (chatgpt) are a shop clerk and I (the user) am at the counter\", message me in Japanese where I wil reply in Japanese. The Japanese part of your responses should be 1 sentence long including a leading question. Invent any necessary details such as items or people involved and do not translate and Japanese to english. After I send a message back (I will mark my replies with \"user:\" by myself), explain in English how the user Japanese grammar I used could be improved (do not explain messages marked with \"gpt:\"), mark this with \"Feedback:\" after the Japanese part of your message.  Your response should be 200 tokens or less.",
      isUser: false,
    ));
  
    ApiService.fetchInitialReply(apiMessages[0].content).then((response){
    setState(() {
      messages.add(response);
      apiMessages.add(Message(content: "gpt: " + response.content, isUser: false));
    });
  });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Messenger')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return MessageWidget(message: messages[index]);
              },
            ),
          ),
          /*if (_isTyping) ...[
              const SpinKitThreeBounce(
                color: Colors.white,
                size: 18,
              ),
            ],*/
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    String userMessage = messageController.text.trim();
                    if (userMessage.isNotEmpty) {
                      setState(() {
                        messages.add(Message(content: userMessage, isUser: true));
                        apiMessages.add(Message(content: "user: " + userMessage, isUser: true));
                      });

                      final chatbotReply = await ApiService.sendMessage(previousMessages: apiMessages, newMessage: userMessage);
                      setState(() {
                        messages.add(Message(content: chatbotReply.content, feedback: chatbotReply.feedback, isUser: false));
                        apiMessages.add(Message(content: "gpt: " + chatbotReply.content, feedback: chatbotReply.feedback, isUser: false));
                      });
                    }
                  },
                  /*onPressed: () async{
                    if (messageController.text.isNotEmpty) {
                      final userMessage = messageController.text;
                      setState(() {
                        print("user message, content: ${userMessage}      index: ${messages.length}");
                        messages.add(Message(content: userMessage, chatIndex: messages.length));
                        print("user message api, content: ${userMessage}      index: ${apiMessages.length}");
                        apiMessages.add(Message(content: "user: " + userMessage, chatIndex: apiMessages.length));
                      });
                      messageController.clear();

                      try {
                        final chatbotReply = await ApiService.sendMessage(previousMessages: apiMessages, newMessage: userMessage);
                          // Split the full response at "Feedback:"
                          //List<String> responseParts = chatbotReply.split("Feedback:");
                          //String japanesePartWithTranslation = responseParts[0].trim();

                          // Split the Japanese part at "(" to separate the main message and the optional translation
                          //List<String> japaneseParts = japanesePartWithTranslation.split("(");
                          //String japanesePart = japaneseParts[0].trim();
                        setState(() {
                          //messages.add(Message(content: chatbotReply, chatIndex: messages.length));
                          print("gpt message, ${chatbotReply.content}      index: ${chatbotReply.chatIndex}");
                          messages.add(chatbotReply);
                          print("gpt message, content: ${chatbotReply.content}      index: ${apiMessages.length}");
                          apiMessages.add(Message(content: chatbotReply.content, chatIndex: apiMessages.length));
                        });
                      } catch (e) {
                        print("Error fetching chatbot reply: $e");
                      }
                    }
                    /*try {
                      setState(() {
                        _isTyping = true;
                      });
                    final lst = await ApiService.sendMessage(message: messageController.text);
                    } catch (error) {
                      print("error: $error");
                    } finally {
                      setState(() {
                        _isTyping = false;
                      });
                    }*/
                  },*/
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /*Future<void> sendMessageFCT () async{
                    try {
                      setState(() {
                        _isTyping = true;
                      });
                    final lst = await ApiService.sendMessage(message: messageController.text);
                    } catch (error) {
                      print("error: $error");
                    } finally {
                      setState(() {
                        _isTyping = false;
                      });
                    }
                  }*/
}