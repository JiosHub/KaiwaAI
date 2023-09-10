import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:unichat_ai/services/shared_preferences_helper.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    print("signInWithGoogle called");
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential authResult = await _auth.signInWithCredential(credential);
        final User? user = authResult.user;

        if (user != null) {
          // Check if user's email is verified
          if (!user.emailVerified) {
            await user.sendEmailVerification();
          }
          await SharedPreferencesHelper.setIsLoggedIn(true);
          return user;
        }
      }
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<void> signOut() async {
    await googleSignIn.signOut();
    await _auth.signOut();
    await SharedPreferencesHelper.setIsLoggedIn(false);
  }
}