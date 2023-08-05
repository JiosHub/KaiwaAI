import 'package:flutter/material.dart';
import 'package:kaiwaai/models/message.dart';
import 'package:kaiwaai/widgets/message_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MessengerPage extends StatefulWidget {
  @override
  _MessengerPageState createState() => _MessengerPageState();
}

Future<String> fetchReply(String userMessage) async {
  final url = "https://api.openai.com/v1/engines/davinci/completions";  // This might change based on the exact endpoint you're using
  final headers = {
    "Authorization": "Bearer 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",  // Replace with your actual API key
    "Content-Type": "application/json",
  };
  final body = json.encode({
    "prompt": userMessage,
    // Add other required parameters based on the API documentation
  });

  final response = await http.post(Uri.parse(url), headers: headers, body: body);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['choices'][0]['text'].trim();  // This might change based on the exact structure of the response
  } else {
    throw Exception("Error fetching reply: ${response.body}");
  }
}

class _MessengerPageState extends State<MessengerPage> {
  List<Message> messages = [
    // Sample messages for demonstration
    Message(sender: 'user1', content: 'Hello', timestamp: DateTime.now()),
    Message(sender: 'user2', content: 'Hi!', timestamp: DateTime.now()),
  ];
  String currentUser = 'user1';
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
                bool isCurrentUser = messages[index].sender == currentUser;
                return MessageWidget(
                  message: messages[index],
                  isCurrentUser: isCurrentUser,
                );
              },
            ),
          ),
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
                    print("Send button pressed"); // New print statement

                    if (messageController.text.isNotEmpty) {
                      final userMessage = messageController.text;
                      setState(() {
                        messages.add(Message(
                          sender: currentUser,
                          content: userMessage,
                          timestamp: DateTime.now(),
                        ));
                      });
                      messageController.clear();

                      try {
                        print("About to fetch reply"); // New print statement
                        final chatbotReply = await fetchReply(userMessage);
                        print("Received reply: $chatbotReply"); // New print statement

                        setState(() {
                          messages.add(Message(
                            sender: 'ChatGPT',
                            content: chatbotReply,
                            timestamp: DateTime.now(),
                          ));
                        });
                      } catch (e) {
                        print("Error fetching chatbot reply: $e");
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}