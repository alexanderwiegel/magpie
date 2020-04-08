import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MagpieImageSelector extends StatelessWidget {
  final Function changeImage;
  final BuildContext context;
  final File file;
  final Function updateStatus;

  MagpieImageSelector({
    @required this.changeImage,
    @required this.context,
    @required this.file,
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
            child: file != null
                ? Image.file(
                    file,
                    fit: BoxFit.cover,
                    width: 400.0,
                    height: 200.0,
                  )
                : Image.asset("pics/placeholder.jpg")),
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
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                      onTap: _askPermission,
                      child: Row(
                        children: [
                          Icon(Icons.photo_camera, color: Colors.amber),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          Text('Neues Bild aufnehmen'),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  GestureDetector(
                      onTap: _imageSelectorGallery,
                      child: Row(
                        children: [
                          Icon(Icons.image, color: Colors.amber),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          Text('Bild aus Galerie wählen'),
                        ],
                      )),
                ],
              ),
            ),
          );
        });
  }

  void _askPermission() {
    PermissionHandler()
        .requestPermissions([PermissionGroup.camera]).then(_onStatusRequested);
  }

  void _onStatusRequested(Map<PermissionGroup, PermissionStatus> value) {
    final status = value[PermissionGroup.camera];
    if (status == PermissionStatus.granted) {
      _imageSelectorCamera();
    } else {
      updateStatus(status);
    }
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
}
