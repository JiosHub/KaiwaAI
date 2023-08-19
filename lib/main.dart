
import 'package:flutter/material.dart';
import 'pages/login.dart'; // Adjust the import path based on your project structure

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        brightness: Brightness.light,
        fontFamily: 'Poppins',
        // ... other theme properties ...
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        // ... other theme properties for dark mode ...
      ),
      home: WelcomePage(),
    );
  }
}
