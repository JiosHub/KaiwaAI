import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unichat_ai/services/auth_service.dart';
import 'package:unichat_ai/services/shared_preferences_helper.dart';
import 'package:unichat_ai/widgets/bottom_menu.dart';
import 'package:device_info/device_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  RegExp regexEmail = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
  RegExp regexPassword = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');
  final _formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();
  bool _isEmailLoginVisible = false;
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  bool signInCheck = false;
  bool signUpCheck = false;
  bool signInFailed = false;
  bool signUpFailed = false;
  String _email = '';
  String _password = '';
  final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();

  Future<void> _googleSignIn() async {
    try {
      final user = await authService.signInWithGoogle();
      SharedPreferencesHelper.setUsername(user?.displayName ?? user?.email ?? 'username not found');
      // After successful Google authentication
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      var deviceInfo = await deviceInfoPlugin.androidInfo;
      final uniqueID = deviceInfo.androidId;  // Use this ID as the unique device identifier
      final userRef = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
      
      await userRef.set({
        'deviceID': uniqueID,
        'email': FirebaseAuth.instance.currentUser!.email,  // <-- Save the email here
      }, SetOptions(merge: true));  // Using merge: true to ensure we don't overwrite existing data

      SharedPreferencesHelper.setIsLoggedIn(true);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => BottomMenuRibbon()));

    } catch (e) {
      print("Sign in failed, Error: $e");
    }
  }

  Future<void> _emailSignUp() async {
    try {

      signUpCheck = false;
      User? user = await authService.signUpWithEmail(_email, _password);
      SharedPreferencesHelper.setUsername(user?.email ?? 'username not found');
      // After successful Google authentication
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      var deviceInfo = await deviceInfoPlugin.androidInfo;
      final uniqueID = deviceInfo.androidId;  // Use this ID as the unique device identifier
      final userRef = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);

      await userRef.set({
        'deviceID': uniqueID,
        'email': FirebaseAuth.instance.currentUser!.email,  // <-- Save the email here
      }, SetOptions(merge: true));  // Using merge: true to ensure we don't overwrite existing data
      
      if (user != null) {
        signUpFailed = false;
        SharedPreferencesHelper.setIsLoggedIn(true);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => BottomMenuRibbon()));
      }

    } catch (e) {
      signUpFailed = true;
      setState(() {
        _autoValidate = AutovalidateMode.always;
      });
      print("Sign up failed, Error: $e");
    }
  }

  Future<void> temp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  @override
  void initState() {
    super.initState();
    //temp();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _sizeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login'), toolbarHeight: 50.0),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: _autoValidate,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/unichat-icon.png',   // Replace with the actual path to your logo in the assets
                      width: MediaQuery.of(context).size.width * 0.6,   // 60% of screen width, adjust as necessary
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: SignInButton(
                        Buttons.Google,
                        onPressed: () async {
                          _googleSignIn();
                        },
                      ),
                    ),
                    SizedBox(height: 10.0),
                    if (!_isEmailLoginVisible)
                      SignInButton(
                        Buttons.Email,
                        onPressed: () {
                          setState(() {
                            _isEmailLoginVisible = !_isEmailLoginVisible;
                          });
                          if (_isEmailLoginVisible) {
                            _controller.forward();
                          } else {
                            _controller.reverse();
                          }
                        },
                      )
                    else
                      SizeTransition(
                        sizeFactor: _sizeAnimation,
                        child: Column(
                          children: [
                            SizedBox(height: 20.0),
                            Center(
                              child: Container(
                                width: 300,
                                child: TextFormField(
                                  decoration: InputDecoration(labelText: 'Email'),
                                  validator: (value) {
                                    if (signUpCheck == true && (value == null || value.isEmpty)) {
                                      return 'Enter email to create account';
                                    } else if (signUpCheck == true && !regexEmail.hasMatch(value!)) {
                                      return 'Enter valid email to create account';
                                    }
                                    if (signInCheck = true && (value == null || value.isEmpty)) {
                                      return 'Please enter your email';
                                    } else if (signInCheck == true && !regexEmail.hasMatch(value!)) {
                                      return 'Enter valid email to create account';
                                    }
                                    if (signInFailed == true) {
                                      return 'email or password incorrect';
                                    } else if (signUpFailed == true) {
                                      return 'account creation failed';
                                    }
                                    return null;
                                  },
                                  
                                  onSaved: (value) => _email = value!,
                                ),
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Container(
                              width: 300,
                              child: TextFormField(
                                decoration: InputDecoration(labelText: 'Password'),
                                obscureText: true,
                                validator: (value) {
                                  if (signUpCheck == true && (value == null || value.isEmpty)) {
                                    return 'Please make a new password';
                                  } else if (signUpCheck == true && !regexPassword.hasMatch(value!)) {
                                    return 'Must have 1 uppercase, 1 number, at least 8 characters';
                                  }
                                  if (signInCheck = true && (value == null || value.isEmpty)) {
                                    return 'Please enter your password';
                                  }
                                  if (signInFailed == true) {
                                    return 'email or password incorrect';
                                  } else if (signUpFailed == true) {
                                    return 'account creation failed';
                                  }
                                  return null;
                                },
                                onSaved: (value) => _password = value!,
                              ),
                            ),
                            SizedBox(height: 30.0),
                            TextButton(
                              onPressed: () async {
                                signUpCheck = true;
                                signInCheck = false;
                                signInFailed = false;
                                signUpFailed = false;
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  _emailSignUp();
                                }
                              },
                              child: Text(
                                'Create account',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.white,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Removes extra padding
                                minimumSize: Size(0, 0), // Removes space
                              ),
                            ),
                            SizedBox(height: 20.0),
                            TextButton(
                              onPressed: () {
                                // Show a dialog or input field to enter the user's email address
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    TextEditingController emailController = TextEditingController();
                                    return AlertDialog(
                                      title: Text('Reset Password'),
                                      content: TextField(
                                        controller: emailController,
                                        decoration: InputDecoration(
                                          hintText: 'Enter your email',
                                        ),
                                        keyboardType: TextInputType.emailAddress,
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Send Reset Link'),
                                          onPressed: () async {
                                            if (emailController.text.isNotEmpty) {
                                              // Send password reset email
                                              try {
                                                await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
                                                // Show a success message
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Password reset link sent. (check junk folder)'),
                                                    backgroundColor: Colors.green,
                                                  ),
                                                );
                                              } catch (e) {
                                                // If there is an error, show an error message
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Error occurred. Email may be wrong or doesnt exist.'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            } else {
                                              // Prompt the user to enter their email
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Please enter your email address.'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                            Navigator.of(context).pop(); // Close the dialog
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Text(
                                'Reset password',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.white,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Removes extra padding
                                minimumSize: Size(0, 0), // Removes space
                              ),
                            ),
                            SizedBox(height: 15.0),
                            ElevatedButton(
                              onPressed: () async {
                                signInCheck = true;
                                signUpCheck = false;
                                signInFailed = false;
                                signUpFailed = false;
                                if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                  AuthService authService = AuthService();
                                  User? user = await authService.signInWithEmail(_email, _password);
                                  SharedPreferencesHelper.setUsername(user?.email ?? 'username not found');
                                  if (user != null) {
                                    SharedPreferencesHelper.setIsLoggedIn(true);
                                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => BottomMenuRibbon()));
                                  } else {
                                    signInFailed = true;
                                    setState(() {
                                      _autoValidate = AutovalidateMode.always;
                                    });
                                  }
                                }
                              }, // Define your _submit method
                              child: Text('Login'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );  
  }
}