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
  late String? language;
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
  int gpt4MessageCount = -1;
  int gpt35MessageCount = -1;
  late String? selectedGPT;
  late String? APIKey;

  //i wrote this litterally today and i forgot what it does but im pretty sure i need it
  Future<void> _loadCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedGPT = prefs.getString('selectedGPT');
    APIKey = prefs.getString('personalAPIKey');
  }

  Future<void> _loadFirstMessage() async {
    if(messages.isEmpty){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      selectedGPT = prefs.getString('selectedGPT');
      APIKey = prefs.getString('personalAPIKey');
      language = prefs.getString('selectedLanguage');
      topicContent = widget.topicContent;
      
      String contentString35 = "$topicContent EVERY one of your replies MUST contain 1: A single SHORT $language sentence, DO NOT translate this part to english. 2: AFTER the $language part, translate your provided sentence to English, you MUST mark this with \"Translation:\". 3: AFTER the translation, in English give feedback on MY (the user) usage of $language, you MUST mark this with \"Feedback:\". 3: DO NOT give feedback to YOUR (assistant) replies and NEVER switch roles";
      String contentString4 = "$topicContent EVERY one of your replies MUST contain 1: A single SHORT $language sentence inluding a leading question, DO NOT translate this part to english. 2: AFTER the $language part, translate the sentence as literally as possible to English, you MUST mark this with \"Translation:\". 3: AFTER the translation, in English give feedback on ONLY my (the users) last messages' usage of $language, you MUST mark this with \"Feedback:\". 4: For the feedback, only give a blunt sentence i.e. do not say \"Great job!\", \"keep it up\" etc";
      
      if (selectedGPT == "gpt-4") {
        contentString = contentString4;
      } else {
        contentString = contentString35;
      }
    
      apiMessages.add(Message(
        content: contentString, isUser: "system",
      ));
      
      final loadingMessage = Message(content: "", isUser: "assistant", isLoading: true);
      setState(() {
        messages.add(loadingMessage);
      });
      print("$APIKey<------------");
      if (APIKey == ""){
        ApiService.fetchFirstFunctionMessage(apiMessages[0].content).then((response){
          setState(() {
            messages.removeLast();
            messages.add(response);
            apiMessages.add(Message(content: response.content, translation: response.translation, isUser: "assistant"));
          });
        });
      } else {
        ApiService.fetchFirstMessage(apiMessages[0].content).then((response){
          setState(() {
            messages.removeLast();
            messages.add(response);
            apiMessages.add(Message(content: response.content, translation: response.translation, isUser: "assistant"));
          });
        });
      }
    }
  }

  Future<void> _MessageLimit({bool sendButton = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedGPT = prefs.getString('selectedGPT');
    // Check if it's a new conversation
    if (messages.isEmpty && prefs.getString("personalAPIKey") == "" && GlobalState().globalGPT4MessageCount == -1) {
      // Fetch message limits from Firestore for new conversation
      final data = await ApiService.getMessageLimitCount();
      if (data != null) {
        gpt4MessageCount = data['gpt4_message_count'] as int;
        gpt35MessageCount = data['gpt3_5_message_count'] as int;
        setState(() {
          if (selectedGPT == "gpt-4"){
            gpt4MessageCount--;
          }
          else if (selectedGPT == "gpt-3.5-turbo"){
            gpt35MessageCount--;
          }
        });
        // Update the global state
        GlobalState().globalGPT4MessageCount = gpt4MessageCount;
        GlobalState().globalGPT35MessageCount = gpt35MessageCount;
        // Reset the flag
      }
    } else if(messages.isEmpty && GlobalState().globalGPT4MessageCount != -1){
      gpt4MessageCount = GlobalState().globalGPT4MessageCount;
      gpt35MessageCount = GlobalState().globalGPT35MessageCount;
      if (selectedGPT == "gpt-4") {
        setState(() {
          gpt4MessageCount--;
          GlobalState().globalGPT4MessageCount = gpt4MessageCount;
        });
      } else if (selectedGPT == "gpt-3.5-turbo") {
        setState(() {
          gpt35MessageCount--;
        // Update the global state
          GlobalState().globalGPT35MessageCount = gpt35MessageCount;
        });
      }
    } else {
      // If it's not a new conversation, try loading from the global state
      if (GlobalState().globalGPT4MessageCount != -1) {
        setState(() {
          gpt4MessageCount = GlobalState().globalGPT4MessageCount;
          gpt35MessageCount = GlobalState().globalGPT35MessageCount;
        });
      }
    }

    if (selectedGPT == "gpt-4" && sendButton == true) {
      setState(() {
        gpt4MessageCount--;
        // Update the global state
        GlobalState().globalGPT4MessageCount = gpt4MessageCount;
      });
    } else if (selectedGPT == "gpt-3.5-turbo"  && sendButton == true) {
      setState(() {
        gpt35MessageCount--;
        // Update the global state
        GlobalState().globalGPT35MessageCount = gpt35MessageCount;
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
    _MessageLimit();
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
                                      _MessageLimit(sendButton: true);
                                      final loadingMessage = Message(isLoading: true, content: "", isUser: "assistant");
                                      setState(() {
                                        messages.add(Message(content: userMessage, isUser: "user"));
                                        messages.add(loadingMessage);
                                        apiMessages.add(Message(content: userMessage, isUser: "user"));
                                      });
                                      print("$APIKey<------------");
                                      final Message chatbotReply;
                                      if (APIKey == "") {
                                        chatbotReply = await ApiService.sendFunctionMessage(messages: apiMessages);

                                      } else {
                                        chatbotReply = await ApiService.sendMessage(messages: apiMessages);
                                      }
                                      setState(() {
                                        messages.removeLast();
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
              Positioned(
                right: 22,  // This positions the container to the right edge of the stack
                top: 15,   // Adjust this as needed
                width: 140, // Width of the container
                height: 55, // Height of the container
                child: Container(
                  decoration: BoxDecoration(
                    color:  Colors.cyan[900],
                    borderRadius: BorderRadius.circular(5)
                  ),
                ),
              ),
              Positioned(
                top: -15,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FutureBuilder<void>(
                      future: _loadCount(),
                      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          // If the Future is still running, show a loading indicator
                          return CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          // If we run into an error, display it to the user
                          return Text('Error: ${snapshot.error}');
                        }
                        if (selectedGPT == "gpt-4" && APIKey == "") {
                          return Padding(
                            padding: EdgeInsets.only(left: 20, top: 0),
                            child: Container(
                              decoration: BoxDecoration(
                                color:  Colors.cyan[900],
                                borderRadius: BorderRadius.circular(5)
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              //mainAxisSize: MainAxisSize.min,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("GPT 4:"),
                                  SizedBox(width: 20),  // A space between the text and the number
                                  Text(gpt4MessageCount == -1 ? "loading..." : gpt4MessageCount.toString()),
                                ],
                              ),
                            ),
                          );
                        } else if (selectedGPT == "gpt-3.5-turbo" && APIKey == "" && gpt35MessageCount < 100) {
                          print(APIKey);
                          return Padding(
                            padding: EdgeInsets.only(left: 20, top: 0),
                            child: Container(
                              decoration: BoxDecoration(
                                color:  Colors.cyan[900],
                                borderRadius: BorderRadius.circular(5)
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("GPT 3.5:"),
                                  SizedBox(width: 9),  // A space between the text and the number
                                  Text(gpt35MessageCount == -1 ? "loading..." : gpt35MessageCount.toString()),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Text("");
                        }
                      },
                    ),
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Row(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,  // Center the contents by default
                            children: [
                              InkWell(
                                child: Icon(
                                  buttonTranslate ? Icons.toggle_on : Icons.toggle_off,  // Use toggle_on/off icons based on state
                                  color: buttonTranslate ? Colors.green : Colors.red,
                                  size: 50,
                                ),
                                onTap: () {
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
                              Transform.translate(
                                offset: Offset(0, -10),  // Adjust the y value (-10) to change the upward shift
                                child: Text(
                                  "translate",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    backgroundColor: Colors.transparent,
                                  ),
                                ),
                              ),
                            ]
                          ),
                          SizedBox(width:10,),
                          Column(
                            mainAxisSize: MainAxisSize.min,  // Center the contents by default
                            children: [
                              InkWell(
                                child: Icon(
                                  buttonFeedback ? Icons.toggle_on : Icons.toggle_off,
                                  color: buttonFeedback ? Colors.green : Colors.red,
                                  size: 50,
                                ),
                                onTap: () {
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
                              Transform.translate(
                                offset: Offset(0, -10),  // Adjust the y value (-10) to change the upward shift
                                child: Text(
                                  "feedback",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    backgroundColor: Colors.transparent,
                                  ),
                                ),
                              ),
                            ]
                          ),
                        ]
                      ),
                    ),
                    SizedBox(width: 30),
                  ],
                ),
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