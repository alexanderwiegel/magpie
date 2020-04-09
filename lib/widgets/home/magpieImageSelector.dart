import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MagpieImageSelector extends StatelessWidget {
  final Function changeImage;
  final BuildContext context;
  final dynamic photo;
  final Function updateStatus;

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
                ? photo.toString().startsWith("http") ? Image.network(photo) : Image.file(
              photo,
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
                  option(_askPermission, Icons.photo_camera, 'Neues Bild aufnehmen'),
                  Container(height: 1, width: 10, color: Colors.grey),
                  option(_imageSelectorGallery, Icons.image, 'Bild aus Galerie wählen'),
                  Container(height: 1, width: 10, color: Colors.grey),
                  option(_imageSelectorUnsplash, Icons.web, 'Bild von Unsplash wählen'),
                ],
              ),
            ),
          );
        });
  }

  Widget option(Function onTap, IconData icon, String text) {
    return GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.amber),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              Text(text)
            ]
          ),
        ));
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

  void _imageSelectorUnsplash() async {
    Navigator.pop(context);
    var image = await Navigator.pushNamed(context, "/unsplash");
    changeImage(image);
  }
}
