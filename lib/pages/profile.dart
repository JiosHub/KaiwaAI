import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unichat_ai/pages/login.dart';
import 'package:unichat_ai/services/auth_service.dart';
import 'package:unichat_ai/services/global_state.dart';
import 'package:unichat_ai/services/iap_service.dart';
import 'package:unichat_ai/services/shared_preferences_helper.dart';
import 'package:cloud_functions/cloud_functions.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  
  
  //List<IAPItem> items = await FlutterInappPurchase.instance.getProducts(['your_product_id']);
  TextEditingController apiKeyController = TextEditingController();
  //FocusNode focusNode = FocusNode();  // And here
  TextEditingController languageController = TextEditingController();
  late String selectedLanguage;
  late String selectedGPT;
  late String personalAPIKey;
  final IAPService _iapService = IAPService();
  bool errorCheck = false;

  @override
  void initState() {
    super.initState();
    selectedLanguage = "";
    selectedGPT = "gpt-4-1106-preview";
    personalAPIKey = "";
    apiKeyController = TextEditingController(text: personalAPIKey);
    _loadPreference();
  }

  @override
  void dispose() {
    _iapService.dispose();
    super.dispose();
  }

  void startPurchase(int product_id) async {
    errorCheck = false;
    if (_iapService.products != null && _iapService.products!.isNotEmpty) {
      //print('Attempting to purchase product with ID: ${_iapService.products![product_id].id}');
      errorCheck = await _iapService.buyProduct(_iapService.products![product_id]);
      
      if (errorCheck) {
        setState(() {errorCheck = true;});
        Future.delayed(Duration(seconds: 5), () {
          // After 5 seconds, update errorCheck
          setState(() {errorCheck = false;});
        });
      } else if (product_id == 0){
        GlobalState().globalGPT4MessageCount += 100;
        GlobalState().globalGPT35MessageCount = 2000;
        print(GlobalState().globalGPT4MessageCount);
      } else if (product_id == 1){
        GlobalState().globalGPT4MessageCount += 500;
        GlobalState().globalGPT35MessageCount = 2000;
        print(GlobalState().globalGPT4MessageCount);
      }

      _iapService.resetPurchaseCompleter();
    }
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
        selectedGPT = "gpt-4-1106-preview";
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

  void showContactDialog(BuildContext context) {
    TextEditingController messageController = TextEditingController();

    showDialog(
    context: context,
    builder: (BuildContext context) {
      String messageStatus = '';
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {

          Future<void> sendMessage(String message) async {
            
            User? user = FirebaseAuth.instance.currentUser;

            if (user != null && user.email != null) {
              try {
                FirebaseFunctions functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
                //functions.useFunctionsEmulator('localhost', 5001);
                print("-----------------1");
                final callable = functions.httpsCallable('sendEmail');
                print("-----------------2");
                // Call the function and pass both the message and the user's email
                final results = await callable.call({
                  'message': message,
                  'email': user.email, // Include the email in the call
                });
                print("-----------------3 ${results.data['success']}");
                setState(() {
                  messageStatus = results.data['success'] ? 'Message sent successfully' : 'Error sending message';
                });
              } on FirebaseFunctionsException catch (e) {
                // Handle if the function throws an error
                print("-----------------\n $e");
                setState(() {
                  messageStatus = 'Error sending message';
                });
              }
            } else {
              // Handle the case when the user is not logged in or doesn't have an email
              print("User is not logged in or doesn't have an email.");
              setState(() {
                messageStatus = "User is not logged in or doesn't have an email.";
              });
            }
          }

          return AlertDialog(
            title: Text('Contact Us'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('If you have any issues or feedback, please leave us a message below.', style: TextStyle(fontSize: 15)),
                  SizedBox(height: 10),
                  Text('A reply will be sent to your email.', style: TextStyle(fontSize: 14)),
                  SizedBox(height: 20),
                  TextField(
                    controller: messageController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Your message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (messageStatus.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Text(
                        messageStatus,
                        style: TextStyle(
                          color: messageStatus == 'Message sent successfully' ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      text: 'For more info, join our ',
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Discord',
                          style: TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()..onTap = () {
                            // Insert the URL of your FAQ page
                            launchUrl(Uri.parse('https://discord.gg/5KEAEUmRsP'));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Send'),
                onPressed: () async {
                  sendMessage(messageController.text);
                },
              ),
            ],
          );
        },
      );
    },
  );
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
                      GlobalState().globalGPT35MessageCount=-1;
                      GlobalState().globalGPT4MessageCount=-1;
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
                          print(selection);
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
                              onSubmitted: (String value) {
                                languageController.text = value;
                                GlobalState().globalLanguage = value;
                                print(value);
                                _saveLanguagePreference(value);
                              },
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
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Information'),
                              content: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    SelectableText('You can type any language you want instead of the preset options, but note all the listed languages are what GPT is most proficient in.'),
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
                              selectedGPT = selection ?? "gpt-4-1106-preview";
                              _saveGPTPreference(selection);
                            });
                          },
                          items: <String>["gpt-4-1106-preview",'gpt-3.5-turbo']
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
                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
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
                                        title: Text("GPT4 +100 for £1.49"),  //${item100?.price ?? "£4.99"}
                                        onTap: () async {
                                          startPurchase(0);
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
                                        title: Text("GPT4 +500 for £6.99"), //${item500?.price ?? "£16.99"}
                                        onTap: () async {
                                          startPurchase(1);
                                        },
                                      )
                                    )
                                  ),
                                  SizedBox(height: 15),
                                  errorCheck ? Text("Purchase Unsuccessful",
                                    style: TextStyle(color: Colors.red)) : Container(),
                                  SizedBox(height: 15),
                                  SelectableText("Both options will set GPT-3.5's message limit to 2000."),
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
                        }
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
                  showContactDialog(context);
                }
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
