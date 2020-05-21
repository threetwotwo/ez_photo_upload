import 'dart:typed_data';

import 'package:multi_image_picker/multi_image_picker.dart';

class Photo {
  final String url;
  final Asset asset;
  final Uint8List data;

  Photo({this.url, this.asset, this.data});
}
