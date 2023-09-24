import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unichat_ai/services/api.dart';
import 'package:unichat_ai/services/global_state.dart';

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
        setState(() {
          gpt4MessageCount = data['gpt4_message_count'] as int;
          gpt35MessageCount = data['gpt3_5_message_count'] as int;
        });
      }
    } else if (GlobalState().globalGPT4MessageCount != -1) {
      setState(() {
        gpt4MessageCount = GlobalState().globalGPT4MessageCount;
        gpt35MessageCount = GlobalState().globalGPT35MessageCount;
      });
    }
  }

  @override
  void initState() {
    _MessageCount();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 15, right: 15, top: 15),
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Messages Remaining',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10),
          _countTile("GPT 4 Messages",gpt4MessageCount),
          SizedBox(height: 10),
          _countTile("GPT 3.5 Messages", gpt35MessageCount),
          
          SizedBox(height: 15),
          Text(
            'Guide - What to Expect',
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
            child: Text(
              "When GPT 4 is selected, conversation works very consistently although when GPT 3.5 turbo is selected"+
              " it can be much less consistent. It works well most of the time but it can, for example, forgot to "+
              "give the translation or feedback. A semi-precise format is needed for app functionality and GPT 3.5 may"+
              " often forget to put it in a format as a conversation progresses. Again GPT 4 is very consistant"+
              " compared to GPT 3.5 regarding this. Also note GPT will only have a memory of the last 5 replies.",
              style: TextStyle(color: Colors.white),
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
            child: Text(
              "Create your own api key: https://platform.openai.com " +
              "GPT 4 will not be accessable until you have a payment history with openai, see the following: "+
              "https://help.openai.com/en/articles/7102672-how-can-i-access-gpt-4",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _countTile(String title, int? count) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 18, bottom: 18, left: 25, right: 50),
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
                child: CircularProgressIndicator(
                  strokeWidth: 2.0, // adjust the thickness of the circular progress bar
                ),
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