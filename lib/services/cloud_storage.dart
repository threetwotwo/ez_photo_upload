import 'package:ezphotoupload/models/album.dart';
import 'package:ezphotoupload/services/auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class CloudStorage {
  static final shared = FirebaseStorage.instance;

  static Future<dynamic> updateProfilePhoto(Asset photo) async {
    final currentUser = await Auth.currentUser();

    final storagePath = 'users/${currentUser.uid}/profile.jpg';

    final snap = shared
        .ref()
        .child(storagePath)
        .putData((await photo.getByteData(quality: 8)).buffer.asUint8List());

    final url = (await snap.onComplete).ref.getDownloadURL();

    return url;
  }

  static Future<void> deleteAlbum(String uid, Album album) async {
    for (var url in album.photoUrls) {
      final ref = await shared.getReferenceFromUrl(url);
      ref.delete();
    }

    return;
  }

  static Future<List<StorageUploadTask>> uploadPhotos(
      String albumId, List<Asset> photos) async {
    final currentUser = await Auth.currentUser();

    List<StorageUploadTask> tasks = [];

    for (int i = 0; i < photos.length; i++) {
      final storagePath =
          'users/${currentUser.uid}/albums/$albumId/photos/$i.jpg';

      final task = shared.ref().child(storagePath).putData(
          (await photos[i].getByteData(quality: 15)).buffer.asUint8List());
      tasks.add(task);
    }

    return tasks;
  }

  static Future<List<dynamic>> getDownloadUrls(
      List<StorageUploadTask> tasks) async {
    final futureSnaps = tasks.map((e) => e.onComplete).toList();

    final result = await Future.wait(futureSnaps);

    final r2 = result.map((e) => e.ref.getDownloadURL()).toList();

    return Future.wait(r2);
  }
}
