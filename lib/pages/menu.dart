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
  //String selectedCustomTopic = 'No saved topics.';
  //List<String> savedTopicTitles = [];
  //List<String> savedTopicDesc = [];
  ValueNotifier<List<String>> savedTopicsNotifier = ValueNotifier<List<String>>(["No saved topics."]);
  final _formKey = GlobalKey<FormState>();
  late String selectedLanguage = "";
  String selectedCustomTopic = "";
  bool isFirstRun = true;
  bool loadCustom = false;
  bool topicExists = false;

  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    topics = getTopics();
    _loadCustomTopicsToNotifier(); 
    _initializeSelectedTopic();
  }

  void _initializeSelectedTopic() {
    List<String> savedTopicTitles = savedTopicsNotifier.value.map((e) => e.split('|||').first).toList();
    setState(() {
      selectedCustomTopic = savedTopicTitles.isNotEmpty ? savedTopicTitles[0] : 'No saved topics.';
    });
  }

  void _loadCustomTopicsToNotifier() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> fullTopics = prefs.getStringList('savedTopics') ?? ["No saved topics."];
    savedTopicsNotifier.value = fullTopics;  // This will trigger the ValueListenableBuilder to rebuild
  }

  void _selectTopic(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedLanguage = prefs.getString('selectedLanguage') ?? "";
    if (selectedLanguage == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text('Please select a language first.'),
        ),
      );
    } else if(loadCustom) {
      GlobalState().clearMessageList();
      MenuPage.topicContent = descController.text;
      BottomMenuRibbon.cachedMessengerPage = MessengerPage(topicContent: MenuPage.topicContent);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BottomMenuRibbon.cachedMessengerPage!,
        ),
      );
      loadCustom = false;
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
                    return Form(
                      key: _formKey,
                      child: AlertDialog(
                        title: Text("Make a New Topic"),
                        content: ValueListenableBuilder<List<String>>(
                          valueListenable: savedTopicsNotifier,
                          builder: (context, savedTopics, child) {
                            return StatefulBuilder(
                              builder: (BuildContext context, StateSetter setState) {
                                List<String> savedTopicTitles = savedTopics.map((e) => e.split('|||').first).toList();
                                List<String> savedTopicDesc = savedTopics.map((e) => e.split('|||').last).toList();
                                //String selectedCustomTopic = savedTopicTitles.isNotEmpty ? savedTopicTitles[0] : 'No saved topics.';
                                
                                void _loadCustomTopics() async {
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  List<String> fullTopics = prefs.getStringList('savedTopics') ?? ["No saved topics."];
                                  print("5");
                                  savedTopicTitles.clear();
                                  savedTopicDesc.clear();
                                  print("6");
                                  if (fullTopics[0] != "No saved topics.") {
                                    print("7");
                                    for (String topic in fullTopics) {
                                      List<String> parts = topic.split('|||');
                                      if (parts.length == 2) {  // Ensure there are exactly 2 parts
                                        savedTopicTitles.add(parts[0]);
                                        savedTopicDesc.add(parts[1]);
                                      }
                                    }
                                  } else {
                                    print("8");
                                    savedTopicTitles = [fullTopics[0]];
                                  }
                                }
                                  void _deleteCustomTopic() async {
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  List<String> fullTopics = prefs.getStringList('savedTopics') ?? ["No saved topics."];
                                    int? indexToRemove;
                                  for (int i = 0; i < fullTopics.length; i++) {
                                    if (fullTopics[i].startsWith(titleController.text)) {
                                      indexToRemove = i;
                                      break;
                                    }
                                  }
                                  
                                  if (indexToRemove != null) {
                                    fullTopics.removeAt(indexToRemove);
                                    savedTopicTitles.removeAt(indexToRemove);
                                    savedTopicDesc.removeAt(indexToRemove);
                                    titleController.clear();
                                    descController.clear();
                                    setState(() {
                                      if (fullTopics.isEmpty) {
                                        fullTopics.add("No saved topics.");
                                        savedTopicTitles.add("No saved topics.");
                                        savedTopicDesc.add("No saved topics.");
                                        selectedCustomTopic = savedTopicTitles[0];
                                      } else {
                                        selectedCustomTopic = savedTopicTitles[0];
                                        titleController.text = savedTopicTitles[0];
                                        descController.text = savedTopicDesc[0];
                                      }
                                    });
                                  }
                                  prefs.setStringList('savedTopics', fullTopics);
                                  savedTopicsNotifier.value = fullTopics;
                                  _loadCustomTopics();
                                }

                                void _saveTopic(String topic) async {
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  print("1");
                                  List<String> existingList = prefs.getStringList('savedTopics') ?? [];
                                  List<String> parts = topic.split('|||');
                                  print(parts[0]);
                                  print("2");
                                  existingList.add(topic);
                                  if (existingList.contains("No saved topics.")){
                                    existingList.remove("No saved topics.");
                                    print("3");
                                    setState(() {
                                      selectedCustomTopic = parts[0];
                                    });
                                  }
                                  print("4");
                                  prefs.setStringList('savedTopics', existingList);
                                  savedTopicsNotifier.value = existingList;
                                  _loadCustomTopics();
                                }
                                  if (isFirstRun) {
                                  _loadCustomTopics();
                                  setState(() {
                                    selectedCustomTopic = savedTopicTitles.isNotEmpty ? savedTopicTitles[0] : 'No saved topics.';
                                    for (int i = 0; i < savedTopicTitles.length; i++) {
                                      if (savedTopicTitles[i] == selectedCustomTopic) {
                                        titleController.text = savedTopicTitles[i];
                                        descController.text = savedTopicDesc[i];
                                      }
                                    }
                                  });                                
                                  isFirstRun = false;
                                }
                                
                                return SingleChildScrollView( // Use SingleChildScrollView to avoid overflow issues
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
                                          value: selectedCustomTopic,
                                          onChanged: (String? selection) {
                                            // Update the state accordingly
                                            setState(() {
                                              selectedCustomTopic = selection!;
                                            });
                                            selectedCustomTopic = selection!;
                                            if (selectedCustomTopic != "No saved topics.") {
                                              int index = savedTopicTitles.indexOf(selectedCustomTopic);
                                              if (index != -1) {  // Ensure the index is valid
                                                titleController.text = savedTopicTitles[index];
                                                descController.text = savedTopicDesc[index];
                                              }
                                            }
                                          },
                                          items: savedTopicTitles
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
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: titleController,
                                              decoration: InputDecoration(
                                                hintText: "Short title.",
                                                hintStyle: TextStyle(
                                                  fontSize: 14.0, // Adjust the size as needed
                                                ),
                                                contentPadding: EdgeInsets.only(right:20),
                                              ),
                                              validator: (value) {
                                                if (value == null || value.isEmpty) { 
                                                  return "Field can't be blank.";
                                                } else if (topicExists) {
                                                  topicExists = false;
                                                  return "Topic already exists.";
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.clear),
                                            onPressed: () {
                                              setState(() {
                                                titleController.clear();
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: descController,
                                              maxLines: null, // Makes it multiline
                                              keyboardType: TextInputType.multiline,
                                              decoration: InputDecoration(
                                                hintText: "Description (following examples).",
                                                hintStyle: TextStyle(
                                                  fontSize: 14.0, // Adjust the size as needed
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return "Field can't be blank";
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.clear),
                                            onPressed: () {
                                              setState(() {
                                                descController.clear();
                                              });
                                            },
                                          )
                                        ],
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Row(
                                          children: [
                                            Spacer(),
                                            TextButton(
                                              onPressed: () {
                                                if (_formKey.currentState!.validate() 
                                                && titleController.text == selectedCustomTopic) {
                                                  _deleteCustomTopic();
                                                }
                                              },
                                              child: Text("Delete"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                for (int i = 0; i < savedTopicTitles.length; i++) {
                                                  if (savedTopicTitles[i] == titleController.text) {
                                                    topicExists = true;
                                                  }
                                                }
                                                if (_formKey.currentState!.validate()){
                                                  setState(() {
                                                    selectedCustomTopic = titleController.text;
                                                  });
                                                  if (titleController.text != "" && descController.text != ""){
                                                    print(titleController.text+'|||'+descController.text);
                                                    _saveTopic(titleController.text+'|||'+descController.text);
                                                    print("done save");
                                                  }
                                                }
                                              },
                                              child: Text("Save"),
                                            ),
                                          ]
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                        ),
                        actions: [
                          TextButton(
                            child: Text("Load Chat"),
                            onPressed: () {
                              if (_formKey.currentState!.validate()){
                                loadCustom = true;
                                _selectTopic(0);
                              }
                            },
                          ),
                          TextButton(
                            child: Text("Close"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
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