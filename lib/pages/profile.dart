import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? selectedLanguage;
  TextEditingController apiKeyController = TextEditingController();

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
              Text('Username'),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  // Logout logic here
                },
                child: Text('Logout'),
              ),
            ],
          ),
          SizedBox(height: 32),
          ListTile(
            leading: Text("Chat Language"), 
            title: Container(
              width: double.infinity,
              alignment: Alignment.centerRight,
              child: Transform.translate(
                offset: Offset(0, -5),  // Adjust the y-coordinate as needed
                child: Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    return ["Option 1", "Option 2"].where((String option) {
                      return option.contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    print("You selected: " + selection);
                  },
                ),
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.info),
              onPressed: () {
                // Info button logic here
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
                IconButton(
                  icon: Icon(Icons.info),
                  onPressed: () {
                    // Info button logic here
                  },
                ),
              ],
            ),
          ),
          ListTile(
            trailing: Icon(Icons.info),
            title: Text('Buy API Access'),
            onTap: () {
              // Navigate to contact page
            },
          ),
          ListTile(
            trailing: Icon(Icons.arrow_forward),
            title: Text('Settings'),
            onTap: () {
              // Navigate to settings page
            },
          ),
          ListTile(
            trailing: Icon(Icons.arrow_forward),
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
