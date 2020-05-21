import 'dart:typed_data';

import 'package:ezphotoupload/ui/shared/action_button.dart';
import 'package:ezphotoupload/ui/shared/safe_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class ConfirmScreen extends StatefulWidget {
  final List<Asset> photos;

  static MaterialPageRoute route(List<Asset> photos) =>
      MaterialPageRoute(builder: (_) => ConfirmScreen(photos: photos));

  const ConfirmScreen({Key key, this.photos}) : super(key: key);

  @override
  _ConfirmScreenState createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  final titleController = TextEditingController();
  List<Uint8List> photoData = [];

  @override
  void initState() {
    _getPhotoDatas();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      appBar: AppBar(
        title: Text('New Album'),
      ),
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: titleController,
                    decoration: InputDecoration(hintText: 'Enter Album Title'),
                  ),
                ),
                ActionButton(
                  onPressed: () {},
                  title: 'Upload Now',
                ),
              ],
            ),
          ),
          ListTile(
            title: Text('Photos (${widget.photos.length})',
                style: TextStyle(fontSize: 18)),
          ),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: photoData.length,
            itemBuilder: (_, index) {
              final photo = photoData[index];

              return ListTile(
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text((index + 1).toString() + '.'),
                      ),

                      SizedBox(
                        height: 36,
                        width: 36,
//                        child: AssetThumb(
//                          height: 36,
//                          width: 36,
//                          asset: photo,
//                        ),
                        child: Image.memory(photo),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
//                              Text(photo.name),
                              SizedBox(height: 4),
                              LinearProgressIndicator(),
                            ],
                          ),
                        ),
                      ),
//                Expanded(
//                    child: Padding(
//                  padding: const EdgeInsets.all(8.0),
//                  child: LinearProgressIndicator(
//                    valueColor: AlwaysStoppedAnimation(Colors.green),
//                    value: 1,
//                  ),
//                )),
                    ],
                  ),
                ),
                trailing: Icon(Icons.check),
              );
            },
          ),
        ],
      ),
    );
  }

  void _getPhotoDatas() async {
    final futures = widget.photos
        .map((photo) async =>
            (await photo.getByteData(quality: 60)).buffer.asUint8List())
        .toList();

    final result = await Future.wait(futures);

    setState(() {
      photoData = result;
    });
  }
}
