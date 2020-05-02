import 'package:flutter/material.dart';
import 'package:magpie_app/SizeConfig.dart';

class MagpieButton extends StatelessWidget {
  final GestureTapCallback onPressed;
  final String title;
  final IconData icon;
  MagpieButton(
      {@required this.onPressed, @required this.title, @required this.icon});
  final Color bgColor = SizeConfig.isTablet ? Colors.white : Colors.teal;
  final Color textColor = SizeConfig.isTablet ? Colors.teal : Colors.white;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.hori),
      child: RawMaterialButton(
        fillColor: bgColor,
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
                color: textColor,
                size: SizeConfig.isTablet
                    ? SizeConfig.hori * 3
                    : SizeConfig.hori * 5,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                title,
                style: TextStyle(
                    color: textColor,
                    fontSize: SizeConfig.isTablet
                        ? SizeConfig.hori * 2
                        : SizeConfig.hori * 4),
              ),
            ],
          ),
        ),
        onPressed: onPressed,
        shape: const StadiumBorder(),
      ),
    );
  }
}
