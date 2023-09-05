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
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
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
          infoField(
            'Language Selector',
            DropdownButton<String>(
              value: selectedLanguage,
              items: ['English', 'French', 'Spanish']
                  .map((lang) => DropdownMenuItem(
                        child: Text(lang),
                        value: lang,
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value;
                });
              },
            ),
          ),
          SizedBox(height: 16),
          infoField(
            'API Key',
            TextField(
              controller: apiKeyController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter API Key',
              ),
            ),
          ),
          SizedBox(height: 16),
          infoField(
            'Buy API Access',
            ElevatedButton(
              onPressed: () {
                // Navigate to API purchase page
              },
              child: Text('Buy'),
            ),
          ),
          SizedBox(height: 32),
          ListTile(
            leading: Icon(Icons.arrow_forward),
            title: Text('Settings'),
            onTap: () {
              // Navigate to settings page
            },
          ),
          ListTile(
            leading: Icon(Icons.arrow_forward),
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
        IconButton(
          icon: Icon(Icons.info),
          onPressed: () {
            // Show info popup
          },
        ),
        Text(label),
        Expanded(
          child: field,
        ),
      ],
    );
  }
}
