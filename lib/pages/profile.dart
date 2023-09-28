import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unichat_ai/pages/login.dart';
import 'package:unichat_ai/services/auth_service.dart';
import 'package:unichat_ai/services/global_state.dart';
import 'package:unichat_ai/services/shared_preferences_helper.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  
  
  //List<IAPItem> items = await FlutterInappPurchase.instance.getProducts(['your_product_id']);
  late List<IAPItem> items;
  TextEditingController apiKeyController = TextEditingController();
  //FocusNode focusNode = FocusNode();  // And here
  TextEditingController languageController = TextEditingController();
  late String selectedLanguage;
  late String selectedGPT;
  late String personalAPIKey;

  @override
  void initState() {
    super.initState();
    _initInAppPurchase();
    _fetchProducts();
    selectedLanguage = "";
    selectedGPT = "gpt-4";
    personalAPIKey = "";
    apiKeyController = TextEditingController(text: personalAPIKey);
    _loadPreference();
  }

  Future<void> _initInAppPurchase() async {
    await FlutterInappPurchase.instance.initialize();
  }

  _fetchProducts() async {
    items = await FlutterInappPurchase.instance.getProducts(['your_product_id']);
  } 

  _buyProduct() async {
    FlutterInappPurchase.instance.requestPurchase('your_product_id');
  }

  Future<String> _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? 'username not found';
    return username;
  }

  _loadPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selectedLanguage') ?? "";
      languageController = TextEditingController(text: selectedLanguage);
      selectedGPT = prefs.getString('selectedGPT') ?? "";
      if (selectedGPT == "") {
        selectedGPT = "gpt-4";
        SharedPreferencesHelper.setSelectedGPT(selectedGPT);
      }

      personalAPIKey = prefs.getString('personalAPIKey') ?? '';
      apiKeyController = TextEditingController(text: personalAPIKey);
    });
  }

  _saveLanguagePreference(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedLanguage', language);
  }

  _saveGPTPreference(String? selectedGPT) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedGPT', selectedGPT ?? 'gpt-3.5-turbo');
  }

  _saveAPIKey(String APIKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('personalAPIKey', APIKey);
  }

  Future<String?> _getAPIKey() async {
    String? API_KEY = await SharedPreferencesHelper.getAPIKey();
    return API_KEY;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 15, right: 15, top: 40),
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color:  Colors.grey[800],
              borderRadius: BorderRadius.circular(5)
            ),
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 15),
                Icon(Icons.person, size: 50),
                SizedBox(width: 10),
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
          ),
          SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              color:  Colors.grey[800],
              borderRadius: BorderRadius.circular(5)
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(width: 15),
                    Text('Chat Language:'),
                    SizedBox(width: 20),
                    Expanded(
                      child: Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          return ["Japanese", "Spanish", "French", "German", "Swedish","Italian", "Russian", "Dutch", "Danish", "Portuguese", "Korean", "Chinese (Simplified)", "Arabic"].where((String option) {
                            return option.contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        onSelected: (String selection) {
                          languageController.text = selection;
                          GlobalState().globalLanguage = selection;
                          _saveLanguagePreference(selection);
                        },
                        fieldViewBuilder: (BuildContext context,
                            TextEditingController textEditingController,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted) {
                            if (textEditingController.text.isEmpty) {
                              textEditingController.text = selectedLanguage;
                            }
                            return TextField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                hintText: 'Select language',
                              ),
                            onTap: () {
                              textEditingController.clear();
                            },
                          );
                        },
                        optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              color: Colors.grey[800],
                              elevation: 4.0,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: 170, // width of the dropdown
                                  maxHeight: 200, // maximum height of the dropdown
                                ),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero, // removing default padding
                                  itemCount: options.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final option = options.elementAt(index);
                                    return GestureDetector(
                                      onTap: () {
                                        onSelected(option);
                                      },
                                      child: Container(
                                        height: 40, // Adjust the height of each option here
                                        padding: EdgeInsets.symmetric(horizontal: 10.0), // added to adjust the text alignment inside the container
                                        alignment: Alignment.centerLeft,
                                        child: Text(option, style: TextStyle(fontSize: 16)),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        }
                      ),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.info),
                      onPressed: () {
                        // Handle info button press
                      },
                    ),
                    SizedBox(width: 15),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 15),
                    Text("GPT version:"),
                    SizedBox(width: 38),
                    Expanded(
                      child: Container(
                        height: 30,
                        child: DropdownButton<String>(
                          value: selectedGPT,
                          isDense: true,
                          isExpanded: true,
                          onChanged: (String? selection) {
                            setState(() {
                              selectedGPT = selection ?? "gpt-4";
                              _saveGPTPreference(selection);
                            });
                          },
                          items: <String>['gpt-4','gpt-3.5-turbo']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Padding(
                                padding: EdgeInsets.only(left: 2),
                                child: Text(value, style: TextStyle(fontSize: 15)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: Icon(Icons.info),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Information'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      SelectableText('ChatGPT 3.5 is an improved version of gpt 3. Responses will be a lot faster and API calls are cheaper.'),
                                      SizedBox(height: 15),
                                      SelectableText('ChatGPT 4 has a more detailed prompt and is much more consistent and accurate but is limited as it costs 20x more'),
                                      SizedBox(height: 15),
                                      SelectableText('If you have purchased API Access, you can see the GPT 4 message limit on the info page')
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
                    ),
                    SizedBox(width: 15),
                  ],
                )
              ]
            ),
          ),
          SizedBox(height: 15),
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
                      suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                        onPressed: () {
                          apiKeyController.clear();
                          _saveAPIKey("");
                        },
                      ),
                    ),
                    
                    onSubmitted: (String value) {
                      _saveAPIKey(value);
                    },
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
                            content: SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(height: 20),
                                SelectableText("If an API Key has been entered, it will always be prioritised over any purchased messages/message limits on the app."),
                                SizedBox(height: 15),
                                SelectableText("If you have selected GPT-4 and your API Key doesn't have access to it, please remove the API Key to use any of your remaining GPT-4 message limits."),
                                SizedBox(height: 20),
                                SelectableText("To see steps for creating your own OpenAI API key, go to the info page."),
                              ]
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
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color:  Colors.grey[800],
              borderRadius: BorderRadius.circular(5)
            ),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                trailing: Padding(
                  padding: EdgeInsets.only(right: 11.0), // Add some right padding to move the icon
                  child: Icon(Icons.info),
                ),
                title: Text('Buy More Messages'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Colors.grey[800],
                        title: Text('Options'),
                        content: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: 15),
                              Container(
                                decoration: BoxDecoration(
                                  color:  Colors.grey[700],
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    trailing: Padding(
                                      padding: EdgeInsets.only(right: 11.0), // Add some right padding to move the icon
                                      child: Icon(Icons.arrow_forward),
                                    ),
                                    title: Text("GPT4 +100 for £3.99"),
                                    onTap: () {
                                      // Navigate to contact page
                                    },
                                  )
                                )
                              ),
                              SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color:  Colors.grey[700],
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    trailing: Padding(
                                      padding: EdgeInsets.only(right: 11.0), // Add some right padding to move the icon
                                      child: Icon(Icons.arrow_forward),
                                    ),
                                    title: Text("GPT4 +500 for £16.99"),
                                    onTap: () {
                                      // Navigate to contact page
                                    },
                                  )
                                )
                              ),
                              SizedBox(height: 20),
                              SelectableText("Both options will set GPT-3.5's message limit to 5000."),
                              SizedBox(height: 15),
                              SelectableText("To see steps for creating your own OpenAI API key, go to the info page.")
                            ]
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
            ),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color:  Colors.grey[800],
              borderRadius: BorderRadius.circular(5)
            ),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                trailing: Padding(
                  padding: EdgeInsets.only(right: 11.0), // Add some right padding to move the icon
                  child: Icon(Icons.arrow_forward),
                ),
                title: Text('Contact'),
                onTap: () {
                  // Navigate to contact page
                },
              )
            )
          )
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
