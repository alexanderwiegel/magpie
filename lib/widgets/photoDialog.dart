import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import '../screens/nestCreatorScreen.dart';
import 'package:permission_handler/permission_handler.dart';
import '../database_helper.dart';
import 'nest.dart';
import 'nestItem.dart';

// ignore: must_be_immutable
class PhotoDialog extends StatelessWidget {
  PhotoDialog({@required this.context, this.nest, this.nestItem});

  final BuildContext context;
  final Nest nest;
  final NestItem nestItem;
  PermissionStatus _status;

  @override
  // ignore: missing_return
  Widget build(BuildContext context) {
    optionsDialogBox();
  }

  Future<void> optionsDialogBox() {
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
                      onTap: imageSelectorGallery,
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
      imageSelectorCamera();
    } else {
      _updateStatus(status);
    }
  }

  _updateStatus(PermissionStatus value) {
    if (value != _status) {
        _status = value;
    }
  }

  void imageSelectorCamera() async {
    Navigator.pop(context);
    var image = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );
    changeImage(image);
  }

  void imageSelectorGallery() async {
    Navigator.pop(context);
    var image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    changeImage(image);
  }

  void changeImage(var image) {
    //Navigator.pop(context);
    if (nest != null) {
        nest.albumCover = image;
      DatabaseHelper.instance.update(nest);
    }
    else if (nestItem != null) {
        nestItem.photo = image;
      DatabaseHelper.instance.updateItem(nestItem);
    }
  }
}
