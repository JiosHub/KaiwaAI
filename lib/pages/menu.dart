import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unichat_ai/constants/topic_list.dart';
import 'package:unichat_ai/pages/messaging.dart';
import 'package:unichat_ai/constants/api_consts.dart';
import 'package:unichat_ai/services/global_state.dart';
import 'package:unichat_ai/widgets/bottom_menu.dart';

class MenuPage extends StatefulWidget {
  static String topicContent = "";
  final Function(String)? updateTopicCallback;
  MenuPage({this.updateTopicCallback});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late List<Map<String, String>> topics = [];
  String selectedTopic = 'Option 1';
  late String selectedLanguage;

  @override
  void initState() {
    super.initState();
    topics = getTopics();
  }

  void _selectTopic(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedLanguage = prefs.getString('selectedLanguage') ?? " ";
    if (selectedLanguage == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text('Please select a language first.'),
        ),
      );
    } else {
      GlobalState().clearMessageList();
      MenuPage.topicContent = topics[index]['content'] ?? '';
      BottomMenuRibbon.cachedMessengerPage = MessengerPage(topicContent: MenuPage.topicContent);
      print("2: ${BottomMenuRibbon.cachedMessengerPage!.topicContent}");
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BottomMenuRibbon.cachedMessengerPage!,
        ),
      );
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Make a New Topic"),
                      content: SingleChildScrollView( // Use SingleChildScrollView to avoid overflow issues
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(style: TextStyle(fontSize: 15),"Create a custom topic following the examples provided in the info button to the right. Clicking \"Load Chat\" will redirect to chat using the custom topic."),
                            SizedBox(height: 10),
                            Text("Saved Topics:"),
                            Align(
                              alignment: Alignment.centerRight,
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedTopic,
                                onChanged: (String? selection) {
                                  // Update the state accordingly
                                  selectedTopic = selection!;
                                },
                                items: <String>['Option 1', 'Option 2', 'Option 3']
                                  .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  })
                                  .toList(),
                              ),
                            ),
                            SizedBox(height: 20),
                            Text("Leave the text fields blank if using a saved topic. Create new topic:"),
                            TextField(
                              decoration: InputDecoration(
                                hintText: "short title",
                              ),
                            ),
                            TextField(
                              maxLines: null, // Makes it multiline
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                hintText: "full topic description following example",
                                hintStyle: TextStyle(
                                  fontSize: 14.0, // Adjust the size as needed
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // Handle button press
                                },
                                child: Text("Save"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text("Load Chat"),
                          onPressed: () {
                            // Add the functionality for what should happen when "Load Chat" is pressed
                          },
                        ),
                        TextButton(
                          child: Text("Close"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                height: 75,
                width: 185,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  color: const Color.fromARGB(255, 75, 75, 75),
                  child: Row(
                    children: [
                      // This Expanded ensures the text takes as much space as available
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Custom",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Container for the decorative Icon with a different background color
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: Colors.deepOrange[300],
                            border: Border(
                              left: BorderSide(
                                color: Colors.black,
                                width: 3.0,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 3),
                            child: Image.asset(
                              'assets/cog.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 15),
            IconButton(
              color: Colors.grey[500],
              icon: Icon(Icons.info),
              iconSize: 40,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('How to Make a Topic'),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(
                              'You can type a custom topic for language practice, but make sure it closely follows the format of the following examples:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 15),  // Add some spacing
                            SelectableText('You (assistant) should act like a shop clerk. I (the user) will respond as the customer.'),
                            SizedBox(height: 10),  // Add some spacing
                            SelectableText('You (assistant) should act like a language teacher meeting me (the user) one-on-one for the first time. The user will respond as the pupil.'),
                            SizedBox(height: 10),  // Add some spacing
                            SelectableText('You (assistant) are a Job Interviewer, I (the user) will respond as a Candidate who arrived late.')
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ]
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: topics.isNotEmpty
              ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 5.5,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: topics.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    //String selectedTopicContent = topics[index]['content'] ?? '';
                    _selectTopic(index);
                  },
                  child:Card(
                    clipBehavior: Clip.antiAlias,
                    color: const Color.fromARGB(255, 75, 75, 75),
                    child: Row(
                      children: [
                        // This Expanded ensures the text takes as much space as available
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                topics[index]['title'] ?? 'error getting topic',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Container for the decorative Icon with a different background color
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            height: double.infinity,  // takes up full height of its parent
                            decoration: BoxDecoration(
                              color: Colors.cyan[700],
                              border: Border(
                                left: BorderSide(
                                  color: Colors.black,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3),
                              child: Image.asset(
                                topics[index]['icon'] ?? '',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            )
            : Center(child: CircularProgressIndicator()),
          ),
        ),
      ]
    );
  }
}