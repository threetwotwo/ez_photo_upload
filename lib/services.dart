import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class Auth {
  static final shared = FirebaseAuth.instance;

  static Future<FirebaseUser> currentUser() async => shared.currentUser();

  static Stream<FirebaseUser> userStream() => shared.onAuthStateChanged;

  static Future<void> signOut() => shared.signOut();

  static Future<String> loginWithEmail(String email, String password) async {
    try {
      shared.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      if (e is PlatformException) return e.message;
    }

    return null;
  }

  static Future<String> signUpWithEmail(String email, String password) async {
    try {
      shared.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      if (e is PlatformException) return e.message;
    }

    return null;
  }
}

class FirestoreService {
  static final shared = Firestore.instance;

  static CollectionReference userColRef() => shared.collection('users');

  static CollectionReference albumColRef(String uid) =>
      userRef(uid).collection('albums');

  static DocumentReference userRef(String uid) => userColRef().document(uid);

  static createAlbumRef(String uid) => albumColRef(uid).document();
}

class CloudStorageService {
  static final shared = FirebaseStorage.instance;

  static String albumPath(String albumId) {}

  static Future<StorageUploadTask> uploadTask(
      String filepath, Asset photo) async {
    final data = (await photo.getByteData(quality: 60)).buffer.asUint8List();
    return shared.ref().child(filepath).putData(data);
  }
}
