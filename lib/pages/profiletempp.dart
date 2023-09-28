import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final options = ['English', 'Spanish', 'French', 'German'];
  late TextEditingController _controller;
  String initialOption = 'English';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Text('Chat Language:'),
            SizedBox(width: 20),
            Expanded(
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return options.where((option) =>
                      option.contains(textEditingValue.text));
                },
                onSelected: (String selection) {
                  _controller.text = selection;
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: 'Select language',
                    ),
                    onTap: () {
                      if (textEditingController.text == initialOption) {
                        textEditingController.clear();
                      }
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
            )
          ],
        ),
      
    );
  }
}