import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    topics = getTopics();
    for (int i = 0; i < topics.length; i += 1) {
      print("Attempting to load: ${topics[i]['icon']}");
    }
  }

  void _selectTopic(int index) {
    try {
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
    } catch (e, stacktrace) {
      print("Exception during build: $e");
      print(stacktrace);
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
              Container(
                height: 65,
                width: 175,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  color: Colors.grey[300],
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
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      // Container for the decorative Icon with a different background color
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: Colors.cyan[700],
                            border: Border(
                              left: BorderSide(
                                color: Colors.black,
                                width: 2.0,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 7),
                            child: Image.asset(
                              'assets/cog.png',
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 25),
              IconButton(
                icon: Icon(Icons.info),
                iconSize: 35,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Information'),
                        content: Text('You can type any language you want, but the pre-set options are what ChatGPT has been trained on the most/fluent in'),
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
                      color: Colors.grey[300],
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
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
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