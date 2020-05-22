import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezphotoupload/models/album.dart';
import 'package:ezphotoupload/services/auth.dart';
import 'package:ezphotoupload/services/firestore.dart';
import 'package:ezphotoupload/ui/screens/upload_screen.dart';
import 'package:ezphotoupload/ui/shared/action_button.dart';
import 'package:ezphotoupload/ui/shared/safe_scaffold.dart';
import 'package:ezphotoupload/ui/widgets/album_grid_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class FeedScreen extends StatefulWidget {
  final ScrollController controller;

  const FeedScreen({Key key, this.controller}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('EZ Photo'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_to_photos),
            onPressed: _pickPhotos,
          )
        ],
      ),
      child: FutureBuilder<FirebaseUser>(
          future: Auth.currentUser(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();

            final user = snapshot.data;

            return StreamBuilder<QuerySnapshot>(
                stream: FirestoreService.albumsStream(user.uid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());

                  final docs = snapshot.data.documents;

                  return ListView(
                    controller: widget.controller,
                    children: <Widget>[
                      ListTile(
                        title: Text('My Albums (${docs.length})'),
                      ),
                      Divider(),
                      Center(
                          child: docs.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.photo_album, size: 128),
                                      Text('You do not have any photo albums'),
                                      SizedBox(height: 16),
                                      ActionButton(
                                          onPressed: _pickPhotos,
                                          title: 'Create Album'),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    itemCount: docs.length,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 2,
                                      mainAxisSpacing: 2,
                                    ),
                                    itemBuilder: (_, index) {
                                      final doc = docs[index];
                                      return AlbumGridItem(
                                          album: Album.fromDoc(doc));
                                    },
                                  ),
                                )),
                    ],
                  );
                });
          }),
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
