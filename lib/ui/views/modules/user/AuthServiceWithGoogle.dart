import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServiceWithGoogle {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        try {
          await _googleSignIn.disconnect();
        } catch (e) {
          print("Warning: couldn't disconnect previous Google session: $e");
        }
      }

      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();

      if (gUser == null) {
        // user canceled
        return null;
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;

      return {
        'displayName': user?.displayName,
        'email': user?.email,
        'photoURL': user?.photoURL,
        'phone': user?.phoneNumber,
      };
    } catch (e) {
      print("Error during Google sign-in: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signOut();
    }
  }
}
