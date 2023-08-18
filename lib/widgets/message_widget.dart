import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kaiwaai/models/message.dart';

class MessageWidget extends StatefulWidget {
  final Message message;

  MessageWidget({required this.message});

  @override
  _MessageWidgetState createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  bool showFeedback = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Align(
        alignment: widget.message.isUser == "user" ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onTap: () {
            setState(() {
              showFeedback = !showFeedback;
            });
          },
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: widget.message.content));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Message copied to clipboard!')),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(15.0),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: widget.message.isUser == "user" ? Colors.blue[100] : Colors.green[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(widget.message.content),
                if (showFeedback) ...[
                  SizedBox(height: 5),
                  SelectableText(widget.message.feedback, style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

