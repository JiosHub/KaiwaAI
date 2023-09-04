import 'dart:math';
import 'package:kaiwaai/services/global_state.dart';
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

  @override
  void initState() {
    super.initState();
    messages = GlobalState().globalMessageList;
    topicContent = widget.topicContent;
    String contentString = "$topicContent In EVERY one of your replies MUST contain 1: A short Japanese sentence inluding a leading question, DO NOT translate this part to english. 2: AFTER the Japanese part, in English give feedback on MY (the user) usage of Japanese, you MUST mark this with \"Feedback:\". 3) DO NOT give feedback to YOUR (assistant) replies and NEVER switch roles";
    // Add an initial system message
    apiMessages.add(Message(
      content: contentString,isUser: "system",
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
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: Colors.black),
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
}