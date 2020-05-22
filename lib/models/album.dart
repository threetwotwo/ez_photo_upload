import 'package:cloud_firestore/cloud_firestore.dart';

class Album {
  final String albumId;
  final String title;
  final List<String> photoUrls;
  final Timestamp createdAt;

  Album({this.albumId, this.title, this.photoUrls, this.createdAt});

  factory Album.fromDoc(DocumentSnapshot doc) {
    return Album(
      albumId: doc.documentID,
      title: doc['title'] ?? '',
      photoUrls: List<String>.from(doc['photo_urls'] ?? []),
      createdAt: doc['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'album_id': this.albumId,
      'title': this.title,
      'photo_urls': this.photoUrls,
      'created_at': createdAt,
    };
  }
}
