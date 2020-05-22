import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class PhotoListItem extends StatelessWidget {
  final Asset photo;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final double uploadProgress;

  final bool isUploading;
  final bool isFinished;

  const PhotoListItem(
      {Key key,
      this.photo,
      this.onDelete,
      this.onRefresh,
      this.onMoveUp,
      this.onMoveDown,
      this.index,
      this.uploadProgress,
      this.isUploading = false,
      this.isFinished = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
//    return ListTile(
//      leading: AssetThumb(
//        height: 48,
//        width: 48,
//        asset: photo,
//      ),
//      title: Text(
//        photo.name,
//        overflow: TextOverflow.ellipsis,
//      ),
//    );
    return SizedBox(
      height: 124,
      child: Card(
        elevation: 6,
        margin: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(index.toString() + '.'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 96,
                width: 96,
                child: AssetThumb(
                  height: 96,
                  width: 96,
                  asset: photo,
                  spinner: Container(
                    height: 96,
                    width: 96,
                    color: Colors.grey[300],
                    child: CupertinoActivityIndicator(),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (index == 1)
                      Text(
                        'Cover Photo',
                        style: TextStyle(color: Colors.yellow[700]),
                      ),
                    Text(
                      photo.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    !isUploading
                        ? SizedBox()
                        : uploadProgress >= 1.0
                            ? Text(
                                'OK',
                                style: TextStyle(color: Colors.greenAccent),
                              )
                            : LinearProgressIndicator(
                                value: uploadProgress,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.greenAccent),
                                backgroundColor: Colors.grey[200],
                              ),
                  ],
                ),
              ),
            ),
            if (!isUploading && !isFinished)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    onPressed: onMoveUp,
                    icon: Icon(Icons.keyboard_arrow_up),
                  ),
                  IconButton(
                    onPressed: onMoveDown,
                    icon: Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            if (!isUploading && !isFinished)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
