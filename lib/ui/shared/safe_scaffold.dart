import 'package:flutter/material.dart';

class SafeScaffold extends StatelessWidget {
  final Widget child;
  final AppBar appBar;
  final Color backgroundColor;

  const SafeScaffold({Key key, this.child, this.appBar, this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.white,
      appBar: appBar,
      body: SafeArea(
        child: child,
      ),
    );
  }
}
