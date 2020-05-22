import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class Auth {
  static final shared = FirebaseAuth.instance;

  static Future<FirebaseUser> currentUser() async => shared.currentUser();

  static Stream<FirebaseUser> userStream() => shared.onAuthStateChanged;

  static Future<void> signOut() => shared.signOut();

  static Future<void> updateProfilePhoto(String photoUrl) async {
    print('Auth.updateProfilePhoto $photoUrl');
    final user = await currentUser();

    user.updateProfile(UserUpdateInfo()..photoUrl = photoUrl);

    user.reload();
  }

  static Future<String> recoverPassword(String email) async {
    try {
      await shared.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (e is PlatformException) return e.message;
    }

    return null;
  }

  static Future<String> loginWithEmail(String email, String password) async {
    try {
      await shared.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      if (e is PlatformException) return e.message;
    }

    return null;
  }

  static Future<String> signUpWithEmail(String email, String password) async {
    try {
      await shared.createUserWithEmailAndPassword(
          email: email, password: password);
      return null;
    } catch (e) {
      if (e is PlatformException) return e.message;
    }
  }
}
