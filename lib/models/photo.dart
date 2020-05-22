import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class Photo {
  final String url;
  final Asset asset;
  final Uint8List data;
  final StorageUploadTask task;

  Photo({this.url, this.asset, this.data, this.task});

  static List<Photo> fromAssets(List<Asset> assets) =>
      assets.map((e) => Photo(asset: e)).toList();

  static List<Photo> fromUrls(List<String> urls) =>
      urls.map((e) => Photo(url: e)).toList();

  Photo copyWith({String url, StorageUploadTask task}) => Photo(
        asset: this.asset,
        url: url ?? this.url,
        task: task ?? this.task,
      );
}
