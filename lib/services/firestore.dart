import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezphotoupload/models/album.dart';
import 'package:ezphotoupload/services/auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreService {
  static final shared = Firestore.instance;

  static CollectionReference userColRef() => shared.collection('users');

  static CollectionReference albumColRef(String uid) =>
      userRef(uid).collection('albums');

  static DocumentReference userRef(String uid) => userColRef().document(uid);

  static Stream<DocumentSnapshot> userStream(String uid) =>
      userRef(uid).snapshots();

  static DocumentReference createAlbumRef(String uid) =>
      albumColRef(uid).document();

  static DocumentReference albumRef(String uid, String albumId) =>
      albumColRef(uid).document(albumId);

  static Future<void> deleteAlbum(String uid, String albumId) =>
      albumRef(uid, albumId).delete();

  static Stream<QuerySnapshot> albumsStream(String uid) {
    final query = albumColRef(uid).orderBy('created_at', descending: true);
    return query.snapshots();
  }

  static Future<void> uploadToAlbum(Album album) async {
    final user = await Auth.currentUser();
    final ref = albumRef(user.uid, album.albumId);
    return ref.setData(album.toMap());
  }

  static Future<void> updateProfilePhoto(String url) async {
    final user = await Auth.currentUser();
    final ref = userRef(user.uid);

    return ref.setData({'photo_url': url}, merge: true);
  }
}
