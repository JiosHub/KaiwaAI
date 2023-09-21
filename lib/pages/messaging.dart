import 'dart:math';
import 'package:unichat_ai/services/global_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:unichat_ai/models/message.dart';
import 'package:unichat_ai/services/api.dart';
import 'package:unichat_ai/services/shared_preferences_helper.dart';
import 'package:unichat_ai/widgets/message_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  late String language;
  List<Message> messages = [];
  List<Message> apiMessages = [];  // List of messages to send to the API
  String currentUser = 'user1';
  //bool _isTyping = false;
  final messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showVoiceMessage = false;
  bool _isKeyboardVisible = false;
  bool buttonTranslate = false;
  bool buttonFeedback = true;
  late String contentString;
  
  int _limit = 20;
  int _limitIncrement = 20;

  Future<void> _loadFirstMessage() async {
    if(messages.isEmpty){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      language = prefs.getString('selectedLanguage') ?? "English";
      topicContent = widget.topicContent;
      
      String contentString35 = "$topicContent EVERY one of your replies MUST contain 1: A single SHORT $language sentence, DO NOT translate this part to english. 2: AFTER the $language part, translate your provided sentence to English, you MUST mark this with \"Translation:\". 3: AFTER the translation, in English give feedback on MY (the user) usage of $language, you MUST mark this with \"Feedback:\". 3: DO NOT give feedback to YOUR (assistant) replies and NEVER switch roles";
      String contentString4 = "$topicContent EVERY one of your replies MUST contain 1: A single SHORT $language sentence inluding a leading question, DO NOT translate this part to english. 2: AFTER the $language part, translate the sentence as literally as possible to English, you MUST mark this with \"Translation:\". 3: AFTER the translation, in English give feedback on ONLY my (the users) last messages' usage of $language, you MUST mark this with \"Feedback:\". 4: For the feedback, only give a blunt sentence i.e. do not say \"Great job!\", \"keep it up\" etc";
      
      if (prefs.getString('selectedGPT') == "gpt-4") {
        contentString = contentString4;
      } else {
        contentString = contentString35;
      }
    
    
      apiMessages.add(Message(
        content: contentString, isUser: "system",
      ));
      //messages.add(Message(content: contentString, isUser: "system"));
    
      ApiService.fetchFirstFunctionMessage(apiMessages[0].content).then((response){
        setState(() {
          messages.add(response);
          apiMessages.add(Message(content: response.content, translation: response.translation, isUser: "assistant"));
        });
      });
    }
  }

  

  @override
  void initState() {
    try{
    super.initState();
    print("1111111111111111111111111111111");
    messageController.addListener(_onTextChanged);
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardVisibilityController.onChange.listen((bool visible) {
      if (mounted) {
        setState(() {
            _isKeyboardVisible = visible;
        });
      }
      if (visible == false && mounted) {
        setState(() {
          _focusNode.unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        });
      }
    });
    
    messages = GlobalState().globalMessageList;
    apiMessages = GlobalState().globalApiMessageList;
    language = GlobalState().globalLanguage;
    print("2222222222222222222222222222222");
    //_loadFirstMessage();
    print("77777777777777777777777777777");
    
    } catch (e, stacktrace) {
      print("Exception during build: $e");
      print(stacktrace);
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    _focusNode.dispose();
    super.dispose();
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,  // To make the Column as small as possible
                        children: [
                          IconButton(
                            icon: Icon(
                              buttonTranslate ? Icons.toggle_on : Icons.toggle_off,  // Use toggle_on/off icons based on state
                              color: buttonTranslate ? Colors.green : Colors.red,
                              size: 50,
                            ),
                            onPressed: () {
                              setState(() {
                                buttonTranslate = !buttonTranslate;  // Toggle button state
                                if(buttonTranslate == true) {
                                  for (Message message in messages) {
                                    if (message.isUser == 'assistant'){
                                      message.showTranslation = true;
                                    }
                                  }
                                } else if(buttonTranslate == false) {
                                  for (Message message in messages) {
                                    if (message.isUser == 'assistant'){
                                      message.showTranslation = false;
                                    }
                                  }
                                }
                              });
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(left:17),
                            child: Text("translate"),
                          ),
                        ]
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              buttonFeedback ? Icons.toggle_on : Icons.toggle_off,  // Use toggle_on/off icons based on state
                              color: buttonFeedback ? Colors.green : Colors.red,
                              size: 50,
                            ),
                            onPressed: () {
                              setState(() {
                                buttonFeedback = !buttonFeedback;  // Toggle button state
                                if(buttonFeedback == false) {
                                  for (Message message in messages) {
                                    if (message.isUser == 'assistant'){
                                      message.showFeedback = false;
                                    }
                                  }
                                } else if(buttonFeedback == true) {
                                  for (int i = 1; i < messages.length; i++) {
                                    if (messages[i].isUser == 'assistant'){
                                      messages[i].showFeedback = true;
                                    }
                                  }
                                }
                              });
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(left:17),
                            child: Text("feedback"),
                          ),
                      ]),
                      SizedBox(width: 30),
                    ],
                  ),
                  Expanded(
                    child: FutureBuilder<void>(
                      future: _loadFirstMessage(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Failed to load the first message.'));
                        } else {
                          return ListView.builder(
                            reverse: true,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              return MessageWidget(message: messages[messages.length - 1 - index], language: language);
                            },
                          );
                        }
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
                                  if (messageController.text.isEmpty && mounted) {
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
                                      final chatbotReply = await ApiService.sendFunctionMessage(messages: apiMessages);
                                      setState(() {
                                        messages.add(Message(content: chatbotReply.content, translation: chatbotReply.translation, feedback: chatbotReply.feedback, isUser: "assistant", showFeedback: true));
                                        apiMessages.add(Message(content: chatbotReply.content, translation: chatbotReply.translation, feedback: chatbotReply.feedback, isUser: "assistant", showFeedback: true));
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