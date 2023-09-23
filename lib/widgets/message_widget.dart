import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:unichat_ai/models/message.dart';

class MessageWidget extends StatefulWidget {
  final Message message;
  String language;
  MessageWidget({required this.message, required this.language});

  @override
  _MessageWidgetState createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {

  FlutterTts flutterTts = FlutterTts();

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
        child: Row(
          mainAxisAlignment: widget.message.isUser == "user" ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [

            GestureDetector(
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
                    Stack(
                      children: [
                        // This will only show if isLoading is false
                        if (!widget.message.isLoading)
                          SelectableText(
                            widget.message.showTranslation && widget.message.isUser == "assistant"
                                ? widget.message.translation
                                : widget.message.content,
                            style: TextStyle(color: Colors.black),
                          ),
                        // This will only show if isLoading is true
                        if (widget.message.isLoading)
                          Padding(
                            padding: EdgeInsets.only(right: 10, left: 10, top: 2),
                            child: LoadingAnimationWidget.staggeredDotsWave(color: Colors.black, size: 27),
                          ),
                      ],
                    ),
                    //SelectableText(widget.message.content),
                    if (widget.message.showFeedback && widget.message.isUser != "user") ...[
                      SizedBox(height: 5),
                      SelectableText(widget.message.feedback, style: TextStyle(fontSize: 10, color: Colors.blueGrey[700])),
                    ],
                  ],
                ),
              ),
            ),
            //if (widget.message.isUser != "user") SizedBox(width: 5.0),  // gap between the message and the icon
            if (widget.message.isUser != "user") IconButton(
                icon: Icon(Icons.volume_up_rounded, size: 35), 
                color: Colors.blue,
                padding: EdgeInsets.zero,
                onPressed: () async {
                  try {
                    String language = widget.language;
                    var voices = await flutterTts.getVoices.timeout(Duration(seconds: 5));
                    if (language == "English") {
                        await flutterTts.setLanguage("en-US");
                        await flutterTts.setVoice({"name": "Aaron"});
                    } else if (language == "Japanese") {
                        await flutterTts.setLanguage("ja-JP");
                    } else if (language == "Korean") {
                        await flutterTts.setLanguage("ko-KR");
                    } else if (language == "Spanish") {
                        await flutterTts.setLanguage("es-ES");
                    } else if (language == "French") {
                        await flutterTts.setLanguage("fr-FR");
                    } else if (language == "German") {
                        await flutterTts.setLanguage("de-DE");
                    } else if (language == "Swedish") {
                        await flutterTts.setLanguage("sv-SE");
                    } else if (language == "Italian") {
                        await flutterTts.setLanguage("it-IT");
                    } else if (language == "Russian") {
                        await flutterTts.setLanguage("ru-RU");
                    } else if (language == "Dutch") {
                        await flutterTts.setLanguage("nl-NL");
                    } else if (language == "Danish") {
                        await flutterTts.setLanguage("da-DK");
                    } else if (language == "Portuguese") {
                        await flutterTts.setLanguage("pt-PT");  // For European Portuguese. Use "pt-BR" for Brazilian Portuguese
                    } else if (language == "Chinese (Simplified)") {
                        await flutterTts.setLanguage("zh-CN");  // Simplified Chinese
                    } else if (language == "Arabic") {
                        await flutterTts.setLanguage("ar-SA");  // This is for Saudi Arabia Arabic. Arabic has various dialects so you might need to adjust based on your target audience.
                    } 
                    await flutterTts.setPitch(1);
                    await flutterTts.speak(widget.message.content);
                  } catch (e) {print("Language not supported or not listed, error: $e");}
                },
              ),  // audio icon for assistant messages
          ]
        ),
      ),
    );
  }
}

