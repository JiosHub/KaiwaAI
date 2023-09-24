
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:unichat_ai/pages/info.dart';
import 'package:unichat_ai/pages/menu.dart';
import 'package:unichat_ai/pages/messaging.dart';
import 'package:unichat_ai/pages/profile.dart';

class BottomMenuRibbon extends StatefulWidget {
  static MessengerPage? cachedMessengerPage;
  @override
  _BottomMenuRibbonState createState() => _BottomMenuRibbonState();
}

class _BottomMenuRibbonState extends State<BottomMenuRibbon> {
  int _selectedIndex = 2;
  String topicContent = "";

  // List of pages to navigate to

  final List<Widget> _pages = [
      // Replace these with your actual pages
      InfoPage(),
      ProfilePage(),
      MenuPage(),
      Text('Please select a topic')
    ];
    

  final List<AppBar> _appBars = [
    AppBar(
      title: Text('Info'),
      toolbarHeight: 50.0,
      backgroundColor: Colors.cyan,
    ),
    AppBar(
      title: Text('Profile'),
      toolbarHeight: 50.0,
      backgroundColor: Colors.cyan,
    ),
    AppBar(
      title: Text('Menu'),
      toolbarHeight: 50.0,
      backgroundColor: Colors.cyan,
    ),
    AppBar(
      title: Text('Current Chat'),
      toolbarHeight: 50.0,
      backgroundColor: Colors.cyan,
    ),
    // Add more AppBars as needed
  ];

  /*void updateTopicContent(String newTopicContent) {
  setState(() {
    topicContent = newTopicContent;
  });
  }*/

  void _onItemTapped(int index) {
    //print("1: ${BottomMenuRibbon.cachedMessengerPage!.topicContent}");
    if (index == 3) { // If the Chat icon is tapped
      if (BottomMenuRibbon.cachedMessengerPage != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BottomMenuRibbon.cachedMessengerPage!,
          ),
        );
        return;
      } else {
        // Show a dialog or toast to inform the user to select a topic first
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a topic first.'),
          ),
        );
        return;
      }
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: _appBars.elementAt(_selectedIndex),
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[300],
        elevation: 10.0,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.cyan,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
