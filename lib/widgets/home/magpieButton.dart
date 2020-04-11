import 'package:flutter/material.dart';
import 'package:magpie_app/constants.dart' as Constants;

class MagpieButton extends StatelessWidget {
  const MagpieButton({@required this.onPressed, @required this.title, @required this.icon});

  final GestureTapCallback onPressed;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      fillColor: Constants.COLOR1,
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
              icon,
              color: Colors.white,
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
