import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final kColor = Colors.amberAccent[700];

class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final bool isLoading;
  final bool isEnabled;
  final Color color;

  const ActionButton(
      {Key key,
      this.onPressed,
      this.title,
      this.isEnabled = true,
      this.isLoading = false,
      this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: isEnabled ? onPressed : null,
      shape: StadiumBorder(),
      color: color ?? Colors.amberAccent[700],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isLoading
            ? CircularProgressIndicator()
            : Text(
                title,
                style: TextStyle(color: Colors.white),
              ),
      ),
    );
  }
}

class OutlineActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final IconData icon;

  const OutlineActionButton({Key key, this.onPressed, this.title, this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return icon == null
        ? OutlineButton(
            onPressed: onPressed,
            shape: StadiumBorder(),
            borderSide: BorderSide(color: kColor),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TextStyle(color: kColor),
              ),
            ),
          )
        : OutlineButton.icon(
            onPressed: onPressed,
            shape: StadiumBorder(),
            borderSide: BorderSide(color: kColor),
            icon: Icon(
              icon,
              color: kColor,
            ),
            label: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TextStyle(color: kColor),
              ),
            ),
          );
  }
}
