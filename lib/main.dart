import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'pages/login.dart'; // Adjust the import path based on your project structure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App', 
      theme: ThemeData(
        //textTheme: TextTheme(Colors.black),
        primarySwatch: Colors.cyan,
        brightness: Brightness.dark,
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
