
import 'package:flutter/material.dart';

class BottomMenuRibbon extends StatefulWidget {
  @override
  _BottomMenuRibbonState createState() => _BottomMenuRibbonState();
}

class _BottomMenuRibbonState extends State<BottomMenuRibbon> {
  int _selectedIndex = 0;

  // List of pages to navigate to
  final List<Widget> _pages = [
    // Replace these with your actual pages
    Text('Info Page'),
    Text('Profile Page'),
    Text('Menu Page'),
    Text('Current Conversation Page'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
