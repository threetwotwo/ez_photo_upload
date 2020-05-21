import 'package:cloud_firestore/cloud_firestore.dart';

class Album {
  final String albumId;
  final List<String> photoUrls;
  final Timestamp createdAt;

  Album({this.albumId, this.photoUrls, this.createdAt});
}
