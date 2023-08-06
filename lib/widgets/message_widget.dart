import 'package:flutter/material.dart';
import 'package:kaiwaai/models/message.dart';

class MessageWidget extends StatelessWidget {
  final Message message;
  final bool isUserMessage;

  MessageWidget({required this.message, required this.isUserMessage});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,  // All messages are aligned to the left
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isUserMessage ? Colors.blue[200] : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(message.content),
      ),
    );
  }
}

