import 'package:ezphotoupload/services.dart';
import 'package:ezphotoupload/ui/shared/safe_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: StreamBuilder<FirebaseUser>(
            stream: Auth.userStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox();

              final user = snapshot.data;

              return ListView(
                children: <Widget>[
                  //avatar
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Center(child: Text(user.email)),
                  SizedBox(height: 16),

                  OutlineButton(
                    onPressed: () {
                      _showDialog(context);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.red)),
                    child: Text('Sign out'),
                  ),
                ],
              );
            }),
      ),
    );
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
}
