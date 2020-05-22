import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezphotoupload/models/album.dart';
import 'package:ezphotoupload/models/photo.dart';
import 'package:ezphotoupload/services/auth.dart';
import 'package:ezphotoupload/services/cloud_storage.dart';
import 'package:ezphotoupload/services/firestore.dart';
import 'package:ezphotoupload/ui/screens/gallery_screen.dart';
import 'package:ezphotoupload/ui/shared/action_button.dart';
import 'package:ezphotoupload/ui/shared/safe_scaffold.dart';
import 'package:ezphotoupload/ui/widgets/photo_list_item.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class UploadScreen extends StatefulWidget {
  final List<Asset> initialAssets;

  static MaterialPageRoute route(List<Asset> photos) => MaterialPageRoute(
      builder: (_) => UploadScreen(
            initialAssets: photos,
          ));

  const UploadScreen({Key key, this.initialAssets}) : super(key: key);

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  List<Photo> photos = [];

  List<StorageUploadTask> tasks = [];

  List<String> downloadUrls = [];

  bool isUploading = false;

  bool isFinished = false;

  Album _album;

  final titleController = TextEditingController();

  @override
  void initState() {
    photos.addAll(Photo.fromAssets(widget.initialAssets));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      appBar: AppBar(
        title: Text('Select Photos'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Scrollbar(
              child: ReorderableListView(
                onReorder: (int oldIndex, int newIndex) {
                  _reorder(oldIndex, newIndex);
                },
                header: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: titleController,
                        decoration:
                            InputDecoration(hintText: 'Enter Album Title'),
                      ),
                    ),
                    ListTile(
                      title: Text('Photos (${photos.length})',
                          style: TextStyle(fontSize: 18)),
                      trailing: isFinished || isUploading
                          ? SizedBox()
                          : OutlineActionButton(
                              onPressed: _addMorePhotos,
                              title: 'Add photo',
                              icon: Icons.add_to_photos,
                            ),
                    ),
                  ],
                ),
                children: photos.isEmpty
                    ? [
                        Padding(
                          padding: const EdgeInsets.all(36),
                          key: ValueKey('empty'),
                          child: Text(
                            'No photos',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      ]
                    : _buildItems(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ActionButton(
              onPressed: isFinished
                  ? () async {
                      await Navigator.of(context).maybePop();
                      if (_album != null) GalleryScreen.show(context, _album);
                    }
                  : _upload,
              isLoading: isUploading,
              color: isFinished ? Colors.greenAccent[700] : null,
              title: isFinished ? 'Finish' : 'Upload',
            ),
          ),
        ],
      ),
    );
  }

  void _reorder(int oldIndex, int newIndex) {
    final old = photos[oldIndex];
    if (oldIndex > newIndex) {
      for (int i = oldIndex; i > newIndex; i--) {
        photos[i] = photos[i - 1];
      }
      photos[newIndex] = old;
    } else {
      for (int i = oldIndex; i < newIndex - 1; i++) {
        photos[i] = photos[i + 1];
      }
      photos[newIndex - 1] = old;
    }
    setState(() {});
  }

  Future<void> _addMorePhotos() async {
    try {
      final result = await MultiImagePicker.pickImages(maxImages: 40)
        ..removeWhere((element) => photos.contains(photos.firstWhere(
            (p) => p.asset.name == element.name,
            orElse: () => null)));

      setState(() {
        photos.insertAll(0, Photo.fromAssets(result));
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _upload() async {
    if (photos.length < 10) {
      showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: Text('Please add 10 photos minimum'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text('OK'),
                    isDefaultAction: true,
                    onPressed: () => Navigator.of(context).maybePop(),
                  )
                ],
              ));
    } else {
      setState(() {
        isUploading = true;
      });

      final user = await Auth.currentUser();
      final ref = FirestoreService.createAlbumRef(user.uid);
      final result = await CloudStorage.uploadPhotos(
          ref.documentID, photos.map((e) => e.asset).toList());
      setState(() {
        tasks = result;
      });

      final urls = await CloudStorage.getDownloadUrls(tasks);

      setState(() {
        isUploading = false;
        downloadUrls = List<String>.from(urls);
      });

      final album = Album(
          albumId: ref.documentID,
          title: titleController.text.trim(),
          photoUrls: downloadUrls,
          createdAt: Timestamp.now());
      FirestoreService.uploadToAlbum(album);

      setState(() {
        _album = album;
        isFinished = true;
      });
    }
  }

  List<Widget> _buildItems() {
    return photos.asMap().entries.map((e) {
      final index = e.key;
      final photo = e.value;
      return IgnorePointer(
        key: ValueKey(photo),
        ignoring: isUploading || isFinished,
        child: StreamBuilder<StorageTaskEvent>(
            stream: tasks.isEmpty ? null : tasks[index].events,
            builder: (context, snapshot) {
              final event = snapshot?.data?.snapshot;
              double progressPercent = event != null
                  ? event.bytesTransferred / event.totalByteCount
                  : 0;

              return PhotoListItem(
                uploadProgress: progressPercent,
                isUploading: isUploading,
                isFinished: isFinished,
                index: index + 1,
                photo: photo,
                onDelete: () {
                  setState(() {
                    photos.remove(photo);
                  });
                },
                onRefresh: () {
                  setState(() {
                    photos[index] = photo;
                  });
                },
                onMoveUp: () {
                  return index == 0 ? null : _reorder(index, index - 1);
                },
                onMoveDown: () {
                  return index == photos.length - 1
                      ? null
                      : _reorder(index, index + 2);
                },
              );
            }),
      );
    }).toList();
  }
}
