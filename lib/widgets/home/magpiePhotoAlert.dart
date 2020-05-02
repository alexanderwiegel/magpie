import 'package:flutter/material.dart';
import 'package:magpie_app/SizeConfig.dart';

class MagpiePhotoAlert {
  void displayPhotoAlert(BuildContext context) async {
    await _photoAlert(context);
  }

  Future<void> _photoAlert(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Text(
              "Du musst ein eigenes Bild benutzen.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: SizeConfig.isTablet
                      ? SizeConfig.hori * 2
                      : SizeConfig.hori * 4),
            ),
          ),
        );
      },
    );
  }
}
