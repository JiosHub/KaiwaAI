
import 'package:flutter/material.dart';
import 'package:kaiwaai/pages/menu.dart';
import 'package:kaiwaai/pages/messaging.dart';

class BottomMenuRibbon extends StatefulWidget {
  @override
  _BottomMenuRibbonState createState() => _BottomMenuRibbonState();
}

class _BottomMenuRibbonState extends State<BottomMenuRibbon> {
  int _selectedIndex = 2;
  String? topicContent;

  // List of pages to navigate to

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    final List<Widget> _pages = [
      // Replace these with your actual pages
      Text('Info Page'),
      Text('Profile Page'),
      MenuPage(),
      topicContent != null ? 
          MessengerPage(topicContent: topicContent!) : 
          Text('Messenger Page'), //MessengerPage(topicContent: topicContent)
    ];

    return Scaffold(
      appBar: _appBars.elementAt(_selectedIndex),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
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
            icon: Icon(Icons.person),
            label: 'Profile',
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
