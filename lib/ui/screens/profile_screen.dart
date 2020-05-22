import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezphotoupload/services/auth.dart';
import 'package:ezphotoupload/services/cloud_storage.dart';
import 'package:ezphotoupload/services/firestore.dart';
import 'package:ezphotoupload/ui/shared/action_button.dart';
import 'package:ezphotoupload/ui/shared/safe_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isUpdating = false;
  FirebaseUser user;

  @override
  void initState() {
    _getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirestoreService.userStream(user.uid ?? ''),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox();

          final Map doc =
              snapshot.data == null ? {} : snapshot.data?.data ?? {};

          final photoUrl = doc['photo_url'] ?? '';

          return ListView(
            children: <Widget>[
              SizedBox(height: 48),

              //avatar
              Stack(
                children: <Widget>[
                  GestureDetector(
                    onTap: _updatePhoto,
                    child: Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 128,
                            width: 128,
                            child: CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              child: ClipOval(
                                child: Container(
                                  color: Colors.grey[300],
                                  height: 128,
                                  width: 128,
                                  child: photoUrl == null || photoUrl.isEmpty
                                      ? Image.asset('assets/images/user.png')
                                      : CachedNetworkImage(
                                          imageUrl: photoUrl,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isUpdating)
                    Positioned.fill(
                        child: Center(child: CircularProgressIndicator())),
                ],
              ),
              SizedBox(height: 8),
              Center(child: Text(user.email)),
              SizedBox(height: 36),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ActionButton(
                    onPressed: _updatePhoto, title: 'Edit Profile Picture'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlineActionButton(
                  onPressed: () => _showDialog(context),
                  title: 'Sign Out',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future _updatePhoto() async {
    try {
      final photos = await MultiImagePicker.pickImages(maxImages: 1);
      setState(() {
        isUpdating = true;
      });
      final String url = await CloudStorage.updateProfilePhoto(photos.first);
      setState(() {
        isUpdating = false;
      });
      final a = await FirestoreService.updateProfilePhoto(url);
    } catch (e) {
      print(e);
    }
    setState(() {
      isUpdating = false;
    });
  }

  void _showDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          content: Text('Do you want to sign out?'),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).maybePop();
                return Auth.signOut();
              },
              child: Text('Sign Out'),
              isDefaultAction: true,
            ),
          ],
        );
      },
    );
  }

  void _getUser() async {
    final result = await Auth.currentUser();
    setState(() {
      user = result;
    });
  }
}
