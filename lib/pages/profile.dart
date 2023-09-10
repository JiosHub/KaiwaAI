import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unichat_ai/pages/login.dart';
import 'package:unichat_ai/services/auth_service.dart';
import 'package:unichat_ai/services/shared_preferences_helper.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  
  TextEditingController apiKeyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  //FocusNode focusNode = FocusNode();
  late TextEditingController textEditingController;  // And here
  bool _showLabel = true;
  late String selectedLanguage;

  @override
  void initState() {
    super.initState();
    selectedLanguage = "...";
    _loadLanguagePreference();
    textEditingController = TextEditingController(text: selectedLanguage);
  }

  Future<String> _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? 'username not found';
    return username;
  }

  _loadLanguagePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selectedLanguage') ?? "English";
      textEditingController = TextEditingController(text: selectedLanguage);
    });
  }

  _saveLanguagePreference(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedLanguage', language);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 15, right: 15, top: 40),
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            //mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.person, size: 50),
              SizedBox(width: 16),
              FutureBuilder<String>(
                future: _getUsername(),
                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Text('${snapshot.data}');
                  }
                },
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: TextButton.icon(
                  icon: Icon(Icons.logout),
                  label: Text("Logout"),
                  onPressed: () async {
                    AuthService authService = AuthService();
                    await authService.signOut();
                    SharedPreferencesHelper.setIsLoggedIn(false);
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => WelcomePage()));
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 32),
          ListTile(
            leading: Text("Chat Language"), 
            title: Container(
              child: Transform.translate(
                offset: Offset(0, -5),  // Adjust the y-coordinate as needed
                child: GestureDetector(
                  onTap: () {
                    _showLabel = false;
                  },
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      if (_showLabel) Text(selectedLanguage),  // _showLabel is a bool you would control
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            setState(() {
                              _showLabel = true;  // Show label when field is empty
                            });
                          } else {
                            setState(() {
                              _showLabel = false;  // Hide label otherwise
                            });
                          }
                          return ["English", "Japanese", "Korean", "Spanish", "French", "German", "Swedish","Italian", "Russian", "Dutch", "Danish", "Portuguese","Chinese (Simplified)", "Arabic"].where((String option) {
                            return option.contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        onSelected: (String selection) {
                          setState(() {
                            selectedLanguage = selection;
                            _saveLanguagePreference(selection);
                            _showLabel = true;  // Hide label when something is selected
                          });
                        },
                        optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                          //TextField(controller: textEditingController, onTap: () {textEditingController.clear();});
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              //elevation: 4.0,
                              child: SizedBox(
                                width: 175, // Set the width to match your field
                                height: 200, // Set the maximum height
                                
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final String option = options.elementAt(index);
                                      return GestureDetector(
                                        onTap: () {
                                          onSelected(option);
                                        },
                                        child: Container(
                                          height: 40, // Adjust the height of each option here
                                          child: ListTile(
                                            title: Text(option),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  /*child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      return ["English", "Japanese", "Chinese (Simplified)", "Korean", "Spanish", "French", "German", "Swedish","Italian", "Russian", "Dutch", "Danish", "Portuguese", "Arabic"].where((String option) {
                        return option.contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (value) {
                      print("You selected: " + value);
                    },
                    optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                      //TextField(controller: textEditingController, onTap: () {textEditingController.clear();});
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          //elevation: 4.0,
                          child: SizedBox(
                            width: 200, // Set the width to match your field
                            height: 200, // Set the maximum height
                            
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final String option = options.elementAt(index);
                                  return GestureDetector(
                                    onTap: () {
                                      onSelected(option);
                                    },
                                    child: Container(
                                      height: 40, // Adjust the height of each option here
                                      child: ListTile(
                                        title: Text(option),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            
                          ),
                        ),
                      );
                    },
                  ),*/
                ),
              ),
            ),
          
            trailing: IconButton(
              icon: Icon(Icons.info),
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
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: apiKeyController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      border: OutlineInputBorder(),
                      labelText: 'Personal OpenAI API Key',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 11.0),
                  child: IconButton(
                    icon: Icon(Icons.info),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Information'),
                            content: Text('This is a pop-up dialog.'),
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
                ),
              ],
            ),
          ),
          ListTile(
            trailing: Padding(
              padding: EdgeInsets.only(right: 11.0), // Add some right padding to move the icon
              child: Icon(Icons.info),
            ),
            title: Text('Buy API Access'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                   return AlertDialog(
                    title: Text('Information'),
                    content: Text('This is a pop-up dialog.'),
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
          ListTile(
            trailing: Padding(
              padding: EdgeInsets.only(right: 11.0), // Add some right padding to move the icon
              child: Icon(Icons.arrow_forward),
            ),
            title: Text('Settings'),
            onTap: () {
              // Navigate to settings page
            },
          ),
          ListTile(
            trailing: Padding(
              padding: EdgeInsets.only(right: 11.0), // Add some right padding to move the icon
              child: Icon(Icons.arrow_forward),
            ),
            title: Text('Contact'),
            onTap: () {
              // Navigate to contact page
            },
          ),
        ],
      ),
    );
  }

  Widget infoField(String label, Widget field) {
    return Row(
      children: [
        Text(label),
        Expanded(
          child: field,
        ),
        IconButton(
          icon: Icon(Icons.info),
          onPressed: () {
            // Show info popup
          },
        ),
      ],
    );
  }
}
