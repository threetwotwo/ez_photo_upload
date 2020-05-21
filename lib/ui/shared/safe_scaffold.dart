import 'package:flutter/material.dart';

class SafeScaffold extends StatelessWidget {
  final Widget child;
  final AppBar appBar;
  const SafeScaffold({Key key, this.child, this.appBar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: child,
      ),
    );
  }
}
