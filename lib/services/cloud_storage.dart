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
      try {
        final ref = await shared.getReferenceFromUrl(url);
        ref.delete();
      } catch (e) {
        print(e);
      }
    }

    return;
  }

  static Future<void> deleteUrls(String uid, List<String> urls) async {
    for (var url in urls) {
      try {
        final ref = await shared.getReferenceFromUrl(url);
        ref.delete();
      } catch (e) {
        print(e);
      }
    }
    return;
  }

  static Future<StorageUploadTask> uploadTaskForAsset(
      String uid, String albumId, Asset asset) async {
    final date = DateTime.now().microsecondsSinceEpoch;

    final storagePath = 'users/$uid/albums/$albumId/photos/$date.jpg';

    final task = shared
        .ref()
        .child(storagePath)
        .putData((await asset.getByteData(quality: 25)).buffer.asUint8List());

    return task;
  }

  static Future<List<StorageUploadTask>> uploadPhotos(
      String albumId, List<Asset> photos) async {
    final currentUser = await Auth.currentUser();

    List<StorageUploadTask> tasks = [];

    for (int i = 0; i < photos.length; i++) {
      final date = DateTime.now().microsecondsSinceEpoch;

      final storagePath =
          'users/${currentUser.uid}/albums/$albumId/photos/$date.jpg';

      final task = shared.ref().child(storagePath).putData(
          (await photos[i].getByteData(quality: 25)).buffer.asUint8List());
      tasks.add(task);
    }

    return tasks;
  }

  static Future<dynamic> getDownloadUrl(StorageUploadTask task) async {
    final snap = await task.onComplete;

    return snap.ref.getDownloadURL();
  }

  static Future<List<dynamic>> getDownloadUrls(
      List<StorageUploadTask> tasks) async {
    final futureSnaps = tasks.map((e) => e.onComplete).toList();

    final result = await Future.wait(futureSnaps);

    final r2 = result.map((e) => e.ref.getDownloadURL()).toList();

    return Future.wait(r2);
  }
}
