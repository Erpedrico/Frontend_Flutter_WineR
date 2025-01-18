import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // El usuario canceló el inicio de sesión
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      print('Error during Google sign-in: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Error during sign out: $e');
    }
  }
}
