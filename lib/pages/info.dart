import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unichat_ai/services/api.dart';
import 'package:unichat_ai/services/global_state.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {

  int? gpt4MessageCount;
  int? gpt35MessageCount;
  late String? selectedGPT;

  Future<void> _MessageCount() async {
    // Check if global variable was previously initialised
    if (GlobalState().globalGPT4MessageCount == -1) {
      // Fetch message limits from Firestore for new conversation
      final data = await ApiService.getMessageLimitCount();
      if (data != null) {
        gpt4MessageCount = data['gpt4_message_count'] as int;
        gpt35MessageCount = data['gpt3_5_message_count'] as int;

        if (mounted) {setState(() {});}

        GlobalState().globalGPT4MessageCount = gpt4MessageCount ?? -1;
        GlobalState().globalGPT35MessageCount = gpt35MessageCount ?? -1;
      }
    } else if (GlobalState().globalGPT4MessageCount != -1) {
      setState(() {
        gpt4MessageCount = GlobalState().globalGPT4MessageCount;
        gpt35MessageCount = GlobalState().globalGPT35MessageCount;
      });
    }
  }

  void _MessageCountRefresh () async {
    final data = await ApiService.getMessageLimitCount();
    if (data != null) {
      gpt4MessageCount = data['gpt4_message_count'] as int;
      gpt35MessageCount = data['gpt3_5_message_count'] as int;

      if (mounted) {setState(() {});}
      
      GlobalState().globalGPT4MessageCount = gpt4MessageCount ?? -1;
      GlobalState().globalGPT35MessageCount = gpt35MessageCount ?? -1;
    }
  }

  Future<void> _launchURL(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch $url');
    }
  }


  @override
  void initState() {
    _MessageCount();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 15, right: 15, top: 5),
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Messages Remaining',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  _MessageCountRefresh();
                },
              ),
            ]
          ),
          SizedBox(height: 10),
          _countTile("GPT 4 Messages",gpt4MessageCount),
          SizedBox(height: 7),
          _countTile("GPT 3.5 Messages", gpt35MessageCount),
          
          SizedBox(height: 15),
          Text(
            'Guide - What to Expect',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 15, bottom: 15, left: 25, right:25),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // centers the children vertically
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("When GPT 4 is selected, conversation works very consistently although when GPT 3.5 turbo is selected"+
                  " it can be much less consistent.", textAlign: TextAlign.left),
                SizedBox(height: 7),
                Text("GPT 3.5 works well most of the time but it can, for example, forget to give the translation"+
                  " or feedback. A semi-precise format is needed for app functionality and GPT 3.5 may often forget"+
                  " to put it in a format as a conversation progresses.", textAlign: TextAlign.left),
                SizedBox(height: 7),
                Text("Again, GPT 4 is very consistant \ncompared to GPT 3.5 regarding this.", textAlign: TextAlign.left),
                SizedBox(height: 15),
                Text("Other things to note:"),
                SizedBox(height: 10),
                for (var item in ['The message count is set to 0 if you already have a different account.'
                , 'Only the last 5 replies will be saved.'
                , 'Training data for GPT-4 goes up to April 2023, GPT 3.5 up to  September 2021'
                , 'If an error occurs with recieving a message, the message count can go down in the app, but the message won\'t actually be taken off your account server-side. You can press the refresh button at the top of this page to get your message count from the server.'])
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '• ', // Bullet point
                            style: TextStyle(
                              fontSize: 20,
                              height: 1,
                            ),
                          ),
                          Expanded(
                            child: Text(item),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                    ]
                  ),
                SizedBox(height: 7),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Join our ',
                      ),
                      TextSpan(
                        text: 'Discord',
                        style: TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _launchURL(Uri.parse('https://discord.gg/5KEAEUmRsP'));
                          },
                      ),
                      TextSpan(
                        text: ' if you need any help.',
                      ),
                    ],
                  ),
                ),
              ]
            ),
          ),
          SizedBox(height: 15),
          Text(
            'Information for API Key Creation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              children: [
                //"Create your own api key: https://platform.openai.com "
                //"GPT 4 will not be accessable until you have a payment history with openai, see the following: "
                //"https://help.openai.com/en/articles/7102672-how-can-i-access-gpt-4"
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Create an openai account: ',
                      ),
                      TextSpan(
                        text: 'platform.openai.com',
                        style: TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _launchURL(Uri.parse('https://platform.openai.com/account/api-keys'));
                          },
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 7),
                Text("GPT 4 will not be accessable until you have a payment history with openai, see the following: ", textAlign: TextAlign.center),
                SizedBox(height: 7),
                InkWell(
                  onTap: () => _launchURL(Uri.parse('https://help.openai.com/en/articles/7102672-how-can-i-access-gpt-4')),
                  child: Text(
                    "https://help.openai.com/en/articles",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            )
          ),
        ],
      ),
    );
  }

  Widget _countTile(String title, int? count) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 15, bottom: 15, left: 25, right: 50),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16),
          ),
          Spacer(),
          count == null 
            ? SizedBox(
                width: 20.0, // specify the width of the circle
                height: 18.0, // specify the height of the circle
                child: LoadingAnimationWidget.staggeredDotsWave(color: Colors.white, size: 27)
              )
            : Text(
                count.toString(), 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )
        ]
      ),
    );
  }
}