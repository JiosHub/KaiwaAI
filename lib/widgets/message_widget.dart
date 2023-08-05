import 'package:flutter/material.dart';
import 'package:kaiwaai/models/message.dart';

class MessageWidget extends StatelessWidget {
  final Message message;
  final bool isCurrentUser;

  MessageWidget({required this.message, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(message.content),
      ),
    );
  }
}