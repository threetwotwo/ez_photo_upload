import 'package:ezphotoupload/styles.dart';
import 'package:ezphotoupload/ui/screens/upload_screen.dart';
import 'package:ezphotoupload/ui/shared/action_button.dart';
import 'package:ezphotoupload/ui/shared/safe_scaffold.dart';
import 'package:ezphotoupload/ui/widgets/photo_list_item.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class FeedScreen extends StatefulWidget {
  final ScrollController controller;

  const FeedScreen({Key key, this.controller}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Asset> photos = [];

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('EZ Photo'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_to_photos),
            onPressed: () async {
              final images = await MultiImagePicker.pickImages(maxImages: 10);
              setState(() {
                photos = images;
              });
            },
          )
        ],
      ),
      child: Center(
        child: photos.isEmpty
            ? Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.photo_album, size: 128),
                  Text('You do not have any photo albums'),
                  SizedBox(height: 16),
                  ActionButton(onPressed: _pickPhotos, title: 'Create Album'),
                ],
              )
            : ListView.builder(
                controller: widget.controller,
                itemCount: photos.length,
                itemBuilder: (_, index) {
                  final photo = photos[index];

                  return PhotoListItem(
                    photo: photo,
                    onDelete: () {
                      print('_FeedScreenState.build');
                    },
                  );
                },
              ),
      ),
    );
  }

  Future _pickPhotos() async {
    try {
      final images = await MultiImagePicker.pickImages(maxImages: 10);
      return Navigator.of(context).push(UploadScreen.route(images));
    } catch (e) {
      print(e);
    }
//    return Navigator.of(context).push(FeedScreen());
  }
}
