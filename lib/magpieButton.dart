import 'package:flutter/material.dart';

class MagpieButton extends StatelessWidget {
  const MagpieButton({@required this.onPressed, @required this.title});

  final GestureTapCallback onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      fillColor: Colors.teal,
      splashColor: Colors.teal[700],
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.add_circle,
              color: Colors.amber,
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              title,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      onPressed: onPressed,
      shape: const StadiumBorder(),
    );
  }
}
