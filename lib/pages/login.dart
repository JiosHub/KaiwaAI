import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:unichat_ai/pages/menu.dart';
import 'package:unichat_ai/services/auth_service.dart';
import 'package:unichat_ai/services/shared_preferences_helper.dart';
import 'package:unichat_ai/widgets/bottom_menu.dart';

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

  void _submit() {
    //if (_formKey.currentState!.validate()) {
      //_formKey.currentState!.save();
      // Assuming the login is successful, navigate to the MenuPage
      SharedPreferencesHelper.setIsLoggedIn(true);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => BottomMenuRibbon()));
    //}
  }

  @override
  void initState() {
    super.initState();

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
      body: Container(
        child: Form(
          key: _formKey,
          autovalidateMode: _autoValidate,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: SignInButton(
                  Buttons.Google,
                  onPressed: () async {
                    final user = await authService.signInWithGoogle();
                    SharedPreferencesHelper.setUsername(user?.displayName ?? user?.email ?? 'username not found');
                    if (user != null) {
                      SharedPreferencesHelper.setIsLoggedIn(true);
                      print("Successfully signed in with Google: ${user.displayName}");
                      _submit();
                    } else {
                      print("Failed to sign in with Google");
                    }
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
                              print("yooooooooooooooooooooooooooooooooooooooo");
                              //if (!regex.hasMatch(value!)) {
                              //  return 'Enter a valid email address';
                              //}
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
                              
                              print("yooooooooooooooooooooooooooooooooooooooo1");
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
                          print("yooooooooooooooooooooooooooooooooooooooo22");
                          signUpCheck = true;
                          signInCheck = false;
                          signInFailed = false;
                          signUpFailed = false;
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            AuthService authService = AuthService();
                            User? user = await authService.signUpWithEmail(_email, _password);
                            SharedPreferencesHelper.setUsername(user?.email ?? 'username not found');
                            if (user != null) {
                              print("yooooooooooooooooooooooooooooooooooooooo2");
                              //signUpCorrect = true;
                              SharedPreferencesHelper.setIsLoggedIn(true);
                              _submit();
                            } else {
                              print("yooooooooooooooooooooooooooooooooooooooo3");
                              signUpFailed = true;
                              setState(() {
                                _autoValidate = AutovalidateMode.always;
                              });
                              print("---------------sign in failed-----------------");
                            }
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
                          // Handle button press
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
                          print("yooooooooooooooooooooooooooooooooooooooo33");
                          signInCheck = true;
                          signUpCheck = false;
                          signInFailed = false;
                          signUpFailed = false;
                          if (_formKey.currentState!.validate()) {
                            print("yooooooooooooooooooooooooooooooooooooooo");
                              _formKey.currentState!.save();
                            AuthService authService = AuthService();
                            User? user = await authService.signInWithEmail(_email, _password);
                            SharedPreferencesHelper.setUsername(user?.email ?? 'username not found');
                            if (user != null) {
                              print("yooooooooooooooooooooooooooooooooooooooo5");
                              SharedPreferencesHelper.setIsLoggedIn(true);
                              _submit();
                            } else {
                              print("yooooooooooooooooooooooooooooooooooooooo6");
                              signInFailed = true;
                              setState(() {
                                _autoValidate = AutovalidateMode.always;
                              });
                              print("---------------sign in failed-----------------");
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
  }
}