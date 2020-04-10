import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:magpie_app/constants.dart' as Constants;

class MagpieImageSelector extends StatelessWidget {
  final Function changeImage;
  final BuildContext context;
  final dynamic photo;
  final Function updateStatus;
  final Color color = Constants.COLOR1;

  MagpieImageSelector({
    @required this.changeImage,
    @required this.context,
    @required this.photo,
    @required this.updateStatus,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _displayOptionsDialog();
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            clipBehavior: Clip.antiAlias,
            child: photo != null
                ? photo.toString().startsWith("http")
                  ? Image.network(
                      photo,
                      fit: BoxFit.cover,
                      width: 400,
                      height: 250,
                    )
                  : Image.file(
                      photo,
                      fit: BoxFit.cover,
                      width: 400,
                      height: 250,
                    )
                : Image.asset(
                    "pics/placeholder.jpg",
                    fit: BoxFit.cover,
                    width: 400,
                    height: 250,
                  )
        ),
      ),
    );
  }

  void _displayOptionsDialog() async {
    await _optionsDialogBox();
  }

  Future<void> _optionsDialogBox() {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            contentPadding: const EdgeInsets.all(0),
            content: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.all(color: color, width: 4)
              ),
              child: SingleChildScrollView(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    option(_imageSelectorCamera, Icons.photo_camera,
                        ["Bild mit", "Kamera", "aufnehmen"]),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(height: 150, width: 1, color: Colors.grey),
                    ),
                    option(_imageSelectorGallery, Icons.image,
                        ["Bild aus", "Galerie", "wählen"]),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(height: 150, width: 1, color: Colors.grey),
                    ),
                    option(_imageSelectorUnsplash, Icons.web,
                        ["Bild auf", "Unsplash", "suchen"]),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget option(Function onTap, IconData icon, List texts) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 85,
          child: Column(
            children: [
              Icon(icon, color: color, size: 60,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
              ),
              Column(children: <Widget>[
                Text(texts[0]),
                Text(texts[1], style: TextStyle(fontWeight: FontWeight.bold)),
                Text(texts[2]),
              ])
            ]
          ),
        ));
  }

  void _imageSelectorCamera() async {
    Navigator.pop(context);
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    changeImage(image);
  }

  void _imageSelectorGallery() async {
    Navigator.pop(context);
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    changeImage(image);
  }

  void _imageSelectorUnsplash() async {
    Navigator.pop(context);
    var image = await Navigator.pushNamed(context, "/unsplash");
    changeImage(image);
  }
}
