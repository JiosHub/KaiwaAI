import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:unichat_ai/services/shared_preferences_helper.dart';
import 'package:unichat_ai/widgets/bottom_menu.dart';
import 'pages/login.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  bool isLoggedIn = await SharedPreferencesHelper.getIsLoggedIn();
  await Firebase.initializeApp();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

// REMEMBER TO UPDATE GLOBAL STATE FOR COUNT AFTER PURCHASE

class MyApp extends StatelessWidget {

  final bool isLoggedIn;
  MyApp({required this.isLoggedIn});

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
      home: isLoggedIn ? BottomMenuRibbon() : WelcomePage(), // Change `HomeScreen()` to your main app screen
    );
  }
}
