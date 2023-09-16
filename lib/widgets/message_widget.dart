import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unichat_ai/models/message.dart';

class MessageWidget extends StatefulWidget {
  final Message message;

  MessageWidget({required this.message});

  @override
  _MessageWidgetState createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {

  @override
  Widget build(BuildContext context) {
    //DefaultTextStyle(
    //  style: TextStyle(color: Colors.black),
    //  child: Text(widget.message.content),
    //);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Align(
        alignment: widget.message.isUser == "user" ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          /*onTap: () {
            setState(() {
              showFeedback = !showFeedback;
            });
          },*/
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: widget.message.content));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Message copied to clipboard!')),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10.0),
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: widget.message.isUser == "user" ? Colors.blue[200] : Colors.green[200],
              //color: widget.message.isUser == "user" ? Colors.teal[700] : Colors.blueGrey[800],
              //color: widget.message.isUser == "user" ? Colors.blue[200] : Colors.green[200],
              borderRadius: widget.message.isUser == "user"
                ? BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(0.0),
                  )
                : BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                    bottomLeft: Radius.circular(0.0),
                    bottomRight: Radius.circular(20.0),
                  ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(widget.message.content, style: TextStyle(color: Colors.black)),
                //SelectableText(widget.message.content),
                if (widget.message.showFeedback && widget.message.isUser != "user") ...[
                  SizedBox(height: 5),
                  SelectableText(widget.message.feedback, style: TextStyle(fontSize: 10, color: Colors.blueGrey[700])),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

