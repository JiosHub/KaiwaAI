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
  List<Message> messages = [
    // Sample messages for demonstration
    Message(content: 'Hello', chatIndex: 0),
    Message(content: 'Hi!', chatIndex: 1),
  ];
  String currentUser = 'user1';
  bool _isTyping = false;
  final messageController = TextEditingController();

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
                // Check if the index is even or odd to distinguish between user messages and AI responses
                bool isUserMessage = index % 2 == 0;
                return MessageWidget(message: messages[index], isUserMessage: isUserMessage);
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
                  onPressed: () async{
                    if (messageController.text.isNotEmpty) {
                      final userMessage = messageController.text;
                      setState(() {
                        messages.add(Message(content: userMessage, chatIndex: messages.length));
                      });
                      messageController.clear();

                      try {
                        final chatbotReply = await ApiService.sendMessage(message: userMessage);
                        // Note: Ensure that chatbotReply is the actual reply you want to display
                        setState(() {
                          messages.add(Message(content: chatbotReply, chatIndex: messages.length));
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
                  },
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