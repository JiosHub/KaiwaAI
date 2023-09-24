import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unichat_ai/services/api.dart';
import 'package:unichat_ai/services/global_state.dart';

// guide, gpt 4 works very consistently, gpt 3.5 works most of the time, but can sometimes
// forgot to give a translation, feedback or even the main message

// create your own api key https://platform.openai.com
// GPT 4 will not be accessable until you have a payment history with openai, see the following:
// https://help.openai.com/en/articles/7102672-how-can-i-access-gpt-4'

// message count

// REMEMBER TO UPDATE GLOBAL STATE FOR COUNT AFTER PURCHASE

/*if (messages.isEmpty && prefs.getString("personalAPIKey") == "" && GlobalState().globalGPT4MessageCount == -1) {
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
    }*/

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {

  int? gpt4MessageCount;
  int? gpt35MessageCount;
  late String? selectedGPT;

  Future<void> _MessageCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Check if it's a new conversation
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subheader',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10),
          _infoTile('Info Tile 1'),
          SizedBox(height: 10),
          _infoTile('Info Tile 2'),
          SizedBox(height: 10),
          _infoTile('Info Tile 3'),
          SizedBox(height: 20),
          Text(
            'Another Subheader',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10),
          _infoTile("GPT 4 Messages Left: ${gpt4MessageCount ?? ""}"),
          _infoTile("GPT 3.5 Messages Left: ${gpt35MessageCount ?? ""}"),
        ],
      ),
    );
  }

  Widget _infoTile(String title) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
  
}