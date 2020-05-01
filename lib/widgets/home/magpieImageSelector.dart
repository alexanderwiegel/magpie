import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:magpie_app/constants.dart' as Constants;
import 'package:path_provider/path_provider.dart';

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
                    ? CachedNetworkImage(
                        imageUrl: photo + "&fit=crop&w=400&dpr=2",
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
                  )),
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
                borderRadius: BorderRadius.all(Radius.circular(10))),
            contentPadding: const EdgeInsets.all(0),
            content: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.all(color: color, width: 4)),
              child: SingleChildScrollView(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    option(_imageSelectorCamera, Icons.photo_camera,
                        ["Bild mit", "Kamera", "aufnehmen"]),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child:
                          Container(height: 150, width: 1, color: Colors.grey),
                    ),
                    option(_imageSelectorGallery, Icons.image,
                        ["Bild aus", "Galerie", "wählen"]),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child:
                          Container(height: 150, width: 1, color: Colors.grey),
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
          child: Column(children: [
            Icon(
              icon,
              color: color,
              size: 60,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
            ),
            Column(children: <Widget>[
              Text(texts[0]),
              Text(texts[1], style: TextStyle(fontWeight: FontWeight.bold)),
              Text(texts[2]),
            ])
          ]),
        ));
  }

  Future<File> compressFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
        file.path, targetPath + "minW400minH250.jpg",
        minWidth: 400, minHeight: 250, quality: 100);
    return result;
  }

  void _imageSelectorCamera() async {
    Navigator.pop(context);
    var file = await ImagePicker.pickImage(source: ImageSource.camera);
    var compressedFile =
        await compressFile(file, file.path.substring(0, file.path.length - 4));
    file.deleteSync();
    changeImage(compressedFile);
  }

  void _imageSelectorGallery() async {
    Navigator.pop(context);
    var file = await ImagePicker.pickImage(source: ImageSource.gallery);
    var targetDirectory = await getExternalStorageDirectory();
    var targetPath = targetDirectory.toString();
    targetPath = targetPath
            .toString()
            .substring(targetPath.indexOf("/"), targetPath.length - 1) +
        "/";
    var fileName = file.toString();
    fileName = fileName.substring(
        fileName.lastIndexOf("/") + 1, fileName.lastIndexOf("."));
    file = await compressFile(file, targetPath + fileName);
    changeImage(file);
  }

  void _imageSelectorUnsplash() async {
    Navigator.pop(context);
    var image = await Navigator.pushNamed(context, "/unsplash");
    changeImage(image);
  }
}
