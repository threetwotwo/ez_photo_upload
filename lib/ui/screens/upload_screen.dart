import 'package:ezphotoupload/ui/screens/confirm_screen.dart';
import 'package:ezphotoupload/ui/shared/action_button.dart';
import 'package:ezphotoupload/ui/shared/safe_scaffold.dart';
import 'package:ezphotoupload/ui/widgets/photo_list_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class UploadScreen extends StatefulWidget {
  final List<Asset> initialPhotos;

  static MaterialPageRoute route(List<Asset> photos) => MaterialPageRoute(
      builder: (_) => UploadScreen(
            initialPhotos: photos,
          ));

  const UploadScreen({Key key, this.initialPhotos}) : super(key: key);

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  List<Asset> photos = [];

  @override
  void initState() {
    photos.addAll(widget.initialPhotos);

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
                    ListTile(
                      title: Text('Photos (${photos.length})',
                          style: TextStyle(fontSize: 18)),
                      trailing: OutlineActionButton(
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
                    : <Widget>[
                        for (final photo in photos)
                          PhotoListItem(
                            key: ValueKey(photo),
                            uploadProgress: 0.6,
                            index: photos.indexOf(photo) + 1,
                            photo: photo,
                            onDelete: () {
                              setState(() {
                                photos.remove(photo);
                              });
                            },
                            onRefresh: () {
                              setState(() {
                                photos[photos.indexOf(photo)] = photo;
                              });
                            },
                            onMoveUp: () {
                              final index = photos.indexOf(photo);
                              return index == 0
                                  ? null
                                  : _reorder(index, index - 1);
                            },
                            onMoveDown: () {
                              final index = photos.indexOf(photo);
                              return index == photos.length - 1
                                  ? null
                                  : _reorder(index, index + 2);
                            },
                          )
                      ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ActionButton(
              onPressed: () {
                Navigator.of(context).push(ConfirmScreen.route(photos));
              },
              title: 'Next',
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
      final result = await MultiImagePicker.pickImages(maxImages: 20)
        ..removeWhere((element) => photos.contains(photos
            .firstWhere((p) => p.name == element.name, orElse: () => null)));

      setState(() {
        photos.insertAll(0, result);
      });
    } catch (e) {
      print(e);
    }
  }

  void _upload() {
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
    }
  }
}
