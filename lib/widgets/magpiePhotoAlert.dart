import 'package:flutter/material.dart';

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
            ),
          ),
        );
      },
    );
  }
}
