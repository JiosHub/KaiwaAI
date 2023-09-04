import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:kaiwaai/models/message.dart';
import 'package:kaiwaai/services/api.dart';
import 'package:kaiwaai/widgets/message_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MessengerPage extends StatefulWidget {
  final String topicContent;  // Add this line
  MessengerPage({required this.topicContent});

  @override
  _MessengerPageState createState() => _MessengerPageState();
}

class _MessengerPageState extends State<MessengerPage> {
  
  late String topicContent;
  List<Message> messages = [];
  List<Message> apiMessages = [];  // List of messages to send to the API
  String currentUser = 'user1';
  bool _isTyping = false;
  final messageController = TextEditingController();
  final ScrollController listScrollController = ScrollController();

  int _limit = 20;
  int _limitIncrement = 20;

  //"You are the shop clerk and will always remain in this role. I am the customer. do the following in each of your replies, 1. Start with a short Japanese sentence. Do not provide an English translation for this sentence. 2. Follow the Japanese sentence with feedback on only MY last reply. Begin this feedback with the word \"Feedback:\". This feedback should address my Japanese grammar and word usage. 3. Never provide feedback on your own replies.";
  //"You are ALWAYS the shop clerk. ONLY I (the user) will respond as the customer. In EVERY one of your replies follow these steps. 1) Your messages MUST contain a short Japanese sentence and DO NOT translate this part to english. 2) AFTER the Japanese part, in English give feedback on MY (the USERS) last reply and DO NOT give feedback to YOUR (assistant) replies regarding Japanese grammar and words used, you MUST mark this with \"Feedback:\".";


  @override
  void initState() {
    super.initState();
    topicContent = widget.topicContent;
    String contentString = "$topicContent In EVERY one of your replies MUST contain 1: A short Japanese sentence inluding a leading question, DO NOT translate this part to english. 2: AFTER the Japanese part, in English give feedback on MY (the user) usage of Japanese, you MUST mark this with \"Feedback:\". 3) DO NOT give feedback to YOUR (assistant) replies and NEVER switch roles";
    // Add an initial system message
    apiMessages.add(Message(
      content: contentString,
      //"You are ALWAYS the shop clerk (gpt:). ONLY I will respond as the customer (user). Your messages must contain a Japanese sentence which must be short, and then in English give feedback on the users last replies' Japanese grammar, mark this with \"Feedback:\". Do not translate any Japanese to English and never switch roles.",
      //content: "You are a shop clerk (gpt:). I am the customer (user:). Only I will speak as the user. Respond to me with Japanese sentence which must be short, and then in English give feedback on the users last replies' Japanese grammar, mark this with \"Feedback:\". Do not translate any Japanese to English.",
      //content: "using the topic \"you (chatgpt) are a shop clerk and I (the user) am at the counter\", message me in Japanese where I wil reply in Japanese. The Japanese part of your responses should be 1 sentence long including a leading question. Invent any necessary details such as items or people involved and do not translate and Japanese to english. After I send a message back (I will mark my replies with \"user:\" by myself), explain in English how the user Japanese grammar I used could be improved (do not explain messages marked with \"gpt:\"), mark this with \"Feedback:\" after the Japanese part of your message.  Your response should be 200 tokens or less.",
      isUser: "system",
    ));
    //messages.add(Message(content: contentString, isUser: "system"));
  
    ApiService.fetchInitialReply(apiMessages[0].content).then((response){
    setState(() {
      messages.add(response);
      apiMessages.add(Message(content: response.content, isUser: "assistant"));
    });
    listScrollController.addListener(_scrollListener);
  });
  }

  _scrollListener() {
    if (!listScrollController.hasClients) return;
    if (listScrollController.offset >= listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange &&
        _limit <= messages.length) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Messenger'), backgroundColor: Colors.cyan),

      body: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible){
          return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    controller: listScrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return MessageWidget(message: messages[messages.length - 1 - index]);
                    },
                  ),
                ),
                /*if (_isTyping) ...[
                    const SpinKitThreeBounce(
                      color: Colors.white,
                      size: 18,
                    ),
                  ],*/
                Container(
                  //padding: EdgeInsets.only(bottom: isKeyboardVisible ? MediaQuery.of(context).viewInsets.bottom : 0),
                  padding: EdgeInsets.all(14.0),
                  height: 75.0,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          style: TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: Colors.grey),
                            contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
                            filled: true,
                            fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              //prefixIcon: Icon(Icons.message, color: Colors.blue),
                            ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () async {
                          String userMessage = messageController.text.trim();
                          bool shouldAutoScroll = listScrollController.offset == listScrollController.position.maxScrollExtent;

                          if (userMessage.isNotEmpty) {
                            setState(() {
                              messages.add(Message(content: userMessage, isUser: "user"));
                              apiMessages.add(Message(content: userMessage, isUser: "user"));
                              if (shouldAutoScroll) {
                                  listScrollController.animateTo(listScrollController.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
                              }
                            });

                            final chatbotReply = await ApiService.sendMessage(messages: apiMessages);
                            setState(() {
                              messages.add(Message(content: chatbotReply.content, feedback: chatbotReply.feedback, isUser: "assistant"));
                              apiMessages.add(Message(content: chatbotReply.content, feedback: chatbotReply.feedback, isUser: "assistant"));
                              if (shouldAutoScroll) {
                                  listScrollController.animateTo(listScrollController.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
                              }
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
            
              
            
          );
        },
      )
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