import 'package:cached_network_image/cached_network_image.dart';
import 'package:ezphotoupload/models/album.dart';
import 'package:ezphotoupload/ui/screens/gallery_screen.dart';
import 'package:flutter/material.dart';

class AlbumGridItem extends StatelessWidget {
  final Album album;

  const AlbumGridItem({Key key, this.album}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => GalleryScreen.show(context, album),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            color: Colors.grey[200],
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: album.photoUrls.first,
                    fit: BoxFit.cover,
                  ),
                ),
                Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          color: Colors.black.withOpacity(0.7),
                          padding: const EdgeInsets.all(6.0),
                          child: Text(
                            album.title.isEmpty ? 'Untitled' : album.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    )),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
//                  width: 36,
                    padding: const EdgeInsets.all(6),
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      album.photoUrls.length.toString(),
//                    style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
