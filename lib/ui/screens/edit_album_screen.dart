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

class EditAlbumScreen extends StatefulWidget {
  final Album album;

  static MaterialPageRoute route(Album album) =>
      MaterialPageRoute(builder: (_) => EditAlbumScreen(album: album));

  const EditAlbumScreen({Key key, this.album}) : super(key: key);

  @override
  _EditAlbumScreenState createState() => _EditAlbumScreenState();
}

class _EditAlbumScreenState extends State<EditAlbumScreen> {
  final titleController = TextEditingController();

  List<Photo> photos = [];
  List<StorageUploadTask> tasks = [];

  //Newly added assets
//  List<Photo> newPhotoAssets = [];
  //Urls to be deleted
  List<String> deletedUrls = [];

  bool isUploading = false;
  bool isFinished = false;
  bool isDeleting = false;

  Album _album;

  @override
  void initState() {
    titleController.text = widget.album.title;
    photos = Photo.fromUrls(widget.album.photoUrls);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      appBar: AppBar(
        title: Text('Edit Album'),
        actions: <Widget>[
          isDeleting
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CupertinoActivityIndicator(),
                )
              : IconButton(
                  onPressed: () => _showDialog(context),
                  icon: Icon(Icons.delete_outline),
                )
        ],
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
              title: isFinished ? 'Finish' : 'Save Album',
            ),
          ),
        ],
      ),
    );
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
      //Save to existing ref
      final ref = FirestoreService.albumRef(user.uid, widget.album.albumId);
      //Delete any deleted photo urls
      if (deletedUrls.isNotEmpty) {
        CloudStorage.deleteUrls(user.uid, deletedUrls);
      }
      //Upload any new assets
      for (var i = 0; i < photos.length; i++) {
        final p = photos[i];
        if (p.asset != null && p.url == null) {
          final task = await CloudStorage.uploadTaskForAsset(
              user.uid, widget.album.albumId, p.asset);

          setState(() {
            photos[i] = p.copyWith(task: task);
          });
        }
      }

      for (var i = 0; i < photos.length; i++) {
        final p = photos[i];
        if (p.task != null && p.url == null) {
          final url = await CloudStorage.getDownloadUrl(p.task);
          setState(() {
            photos[i] = p.copyWith(url: url);
          });
        }
      }

      setState(() {
        isUploading = false;
      });

      final album = Album(
          albumId: ref.documentID,
          title: titleController.text.trim(),
          photoUrls: photos.map((e) => e.url).toList(),
          createdAt: Timestamp.now());

      await FirestoreService.uploadToAlbum(album);

      setState(() {
        _album = album;
        isFinished = true;
      });
    }
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
      final result = await MultiImagePicker.pickImages(maxImages: 100)
        ..removeWhere((element) => photos.contains(photos.firstWhere(
            (p) => p.asset == null ? false : p.asset.name == element.name,
            orElse: () => null)));

      final assetPhotos = Photo.fromAssets(result);

      setState(() {
        photos.insertAll(0, assetPhotos);
      });
    } catch (e) {
      print(e);
    }
  }

  List<Widget> _buildItems() {
    return photos.asMap().entries.map((e) {
      final index = e.key;
      final photo = e.value;

      final task = photos[index].task;

      return IgnorePointer(
        key: ValueKey(photo),
        ignoring: isUploading || isFinished,
        child: StreamBuilder<StorageTaskEvent>(
            stream: task == null ? null : task.events,
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
                    if (photo.url != null) deletedUrls.add(photo.url);
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

  void _showDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          content: Text('Delete Album?'),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: _deleteAlbum,
              child: Text('Delete'),
              isDefaultAction: true,
            ),
          ],
        );
      },
    );
  }

  void _deleteAlbum() async {
    setState(() {
      isDeleting = true;
    });
    final user = await Auth.currentUser();

    await FirestoreService.deleteAlbum(user.uid, widget.album.albumId);
    CloudStorage.deleteAlbum(user.uid, widget.album);

    setState(() {
      isDeleting = false;
    });
    return Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
