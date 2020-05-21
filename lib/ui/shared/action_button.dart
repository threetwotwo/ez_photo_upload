import 'package:flutter/material.dart';

final kColor = Colors.amberAccent[700];

class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final bool isEnabled;

  const ActionButton(
      {Key key, this.onPressed, this.title, this.isEnabled = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: isEnabled ? onPressed : null,
      shape: StadiumBorder(),
      color: Colors.amberAccent[700],
      child: Text(
        title,
        style: TextStyle(color: Colors.white),
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
            child: Text(
              title,
              style: TextStyle(color: kColor),
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
            label: Text(
              title,
              style: TextStyle(color: kColor),
            ),
          );
  }
}
