import 'package:cached_network_image/cached_network_image.dart';
import 'package:ezphotoupload/models/album.dart';
import 'package:ezphotoupload/services/auth.dart';
import 'package:ezphotoupload/services/cloud_storage.dart';
import 'package:ezphotoupload/services/firestore.dart';
import 'package:ezphotoupload/ui/shared/safe_scaffold.dart';
import 'package:flutter/material.dart';

class GalleryScreen extends StatefulWidget {
  final Album album;

//  static MaterialPageRoute route(List<String> urls) => MaterialPageRoute(
//      builder: (_) => GalleryScreen(
//            urls: urls,
//          ));

  static Future<dynamic> show(BuildContext context, Album album) =>
      showModalBottomSheet(
          useRootNavigator: true,
          isScrollControlled: true,
          context: context,
          builder: (context) => GalleryScreen(
                album: album,
              ));

  const GalleryScreen({Key key, this.album}) : super(key: key);

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int index = 0;

  bool isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final urls = widget.album.photoUrls;

    return SafeScaffold(
      backgroundColor: Colors.black,
      child: Column(
        children: <Widget>[
          SizedBox(height: 32),
          ListTile(
//            leading:
            title: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.clear, color: Colors.white),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      widget.album.title.isEmpty
                          ? 'Untitled'
                          : widget.album.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Expanded(child: SizedBox()),
              ],
            ),
//            trailing:
          ),
          Expanded(
            child: PageView.builder(
                onPageChanged: (val) {
                  setState(() {
                    index = val;
                  });
                },
                itemCount: urls.length,
                itemBuilder: (_, index) {
                  final url = urls[index];

                  return Center(
                    child: CachedNetworkImage(
                      imageUrl: url,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      fit: BoxFit.cover,
                    ),
                  );
                }),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: isDeleting
                      ? Center(child: CircularProgressIndicator())
                      : FlatButton(
                          onPressed: _delete,
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      (index + 1).toString() + ' / ' + urls.length.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FlatButton(
                    onPressed: () {},
                    child: Text(
                      'Edit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _delete() async {
    setState(() {
      isDeleting = true;
    });
    final user = await Auth.currentUser();

    await FirestoreService.deleteAlbum(user.uid, widget.album.albumId);
    CloudStorage.deleteAlbum(user.uid, widget.album);

    setState(() {
      isDeleting = false;
    });
    return Navigator.of(context).pop();
  }
}
