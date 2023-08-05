import 'package:flutter/material.dart';
import 'package:kaiwaai/pages/messaging.dart';

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the messenger screen when this button is pressed
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => MessengerPage()));
          },
          child: Text('Go to Messenger'),
        ),
      ),
    );
  }
}