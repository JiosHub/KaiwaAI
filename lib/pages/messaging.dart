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
  final FocusNode _focusNode = FocusNode();
  bool _showVoiceMessage = false;
  bool _isKeyboardVisible = false;

  int _limit = 20;
  int _limitIncrement = 20;

  @override
  void initState() {
    super.initState();
    messageController.addListener(_onTextChanged);
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardVisibilityController.onChange.listen((bool visible) {
      setState(() {
        _isKeyboardVisible = visible;
      });
      if (visible == false) {
        setState(() {
          _focusNode.unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        });
      }
    });

    messages = GlobalState().globalMessageList;
    apiMessages = GlobalState().globalApiMessageList;
    topicContent = widget.topicContent;
    String contentString = "$topicContent EVERY one of your replies MUST contain 1: A single SHORT Japanese sentence inluding a leading question, DO NOT translate this part to english. 2: AFTER the Japanese part, in English give feedback on MY (the user) usage of Japanese, you MUST mark this with \"Feedback:\". 3) DO NOT give feedback to YOUR (assistant) replies and NEVER switch roles";
    // Add an initial system message
    if(messages.isEmpty){
      apiMessages.add(Message(
        content: contentString,isUser: "system",
      ));
      //messages.add(Message(content: contentString, isUser: "system"));
    
      ApiService.fetchInitialReply(apiMessages[0].content).then((response){
        setState(() {
          messages.add(response);
          apiMessages.add(Message(content: response.content, isUser: "assistant"));
        });
      });
    }
  }

  void _onTextChanged() {
    if (messageController.text.isNotEmpty) {
      setState(() {
        _showVoiceMessage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Current Active Topic'), backgroundColor: Colors.cyan, toolbarHeight: 50.0),

      body: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible){
          return Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      reverse: true,
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
                    padding: EdgeInsets.all(14.0),
                    //color: Colors.red,
                    height: 75.0,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            focusNode: _focusNode,
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
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: messageController,
                          builder: (BuildContext context, TextEditingValue textValue, Widget? child) {
                            return AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return ScaleTransition(scale: animation, child: child);
                              },
                              child: IconButton(
                                padding: EdgeInsets.only(left: 5),
                                key: ValueKey<bool>(textValue.text.isEmpty),
                                icon: textValue.text.isEmpty 
                                    ? Icon(Icons.mic, size: 37) 
                                    : Icon(Icons.send, size: 37),
                                onPressed: () async {
                                  if (messageController.text.isEmpty) {
                                    _focusNode.requestFocus();
                                    setState(() {
                                      _showVoiceMessage = true; // Show the voice message overlay when mic is pressed
                                    });
                                  } else {
                                    _showVoiceMessage = false;
                                    String userMessage = messageController.text.trim();
                                    messageController.clear();
                                      if (userMessage.isNotEmpty) {
                                      setState(() {
                                        messages.add(Message(content: userMessage, isUser: "user"));
                                        apiMessages.add(Message(content: userMessage, isUser: "user"));
                                      });
                                        final chatbotReply = await ApiService.sendMessage(messages: apiMessages);
                                      setState(() {
                                        messages.add(Message(content: chatbotReply.content, feedback: chatbotReply.feedback, isUser: "assistant"));
                                        apiMessages.add(Message(content: chatbotReply.content, feedback: chatbotReply.feedback, isUser: "assistant"));
                                      });
                                    }
                                  }
                                },
                              ),
                              
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_isKeyboardVisible && _showVoiceMessage)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showVoiceMessage = false;
                          _focusNode.unfocus();
                        });
                      },
                      child: Container(
                        color: Colors.black.withOpacity(0.7),
                        child: Center(
                          child: Text(
                            'Tap the microphone on your keyboard for voice input',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
            ]
            
          );
        },
      )
    );
    
  }
}