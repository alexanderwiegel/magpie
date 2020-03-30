import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../database_helper.dart';
import '../sortMode.dart';
import '../widgets/magpieForm.dart';
import '../widgets/nest.dart';

class NestCreator extends StatefulWidget {
  @override
  _NestCreatorState createState() => _NestCreatorState();
}

class _NestCreatorState extends State<NestCreator> {
  PermissionStatus _status;
  final _formKey = GlobalKey<FormState>();

  int _id;
  File _albumCover;
  String _name;
  String _note;
  DateTime _date = DateTime.now();

  TextEditingController _nameEditingController;
  TextEditingController _noteEditingController;

  @override
  void dispose() {
    _nameEditingController.dispose();
    _noteEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    PermissionHandler()
        .checkPermissionStatus(PermissionGroup.camera)
        .then(_updateStatus);

    _nameEditingController = TextEditingController(text: _name);
    _noteEditingController = TextEditingController(text: _note);
  }

  void insertNest() async {
    Nest nest = Nest(
      albumCover: _albumCover,
      name: _name,
      note: _note,
      date: _date,
      totalWorth: 0,
      favored: false,
      sortMode: SortMode.SortByDate,
      asc: true,
      onlyFavored: false,
    );
    _id = await DatabaseHelper.instance.insert(nest);
    Navigator.of(context).pop(Nest(
      id: _id,
      albumCover: _albumCover,
      name: _name,
      note: _note,
      date: _date,
      totalWorth: 0,
      favored: false,
      sortMode: SortMode.SortByDate,
      asc: true,
      onlyFavored: false,
    ));
  }

  void _displayPhotoAlert() async {
    await _photoAlert();
  }

  Future<void> _photoAlert() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Neues Nest"),
        actions: [
          FlatButton(
            onPressed: () {
              if (_formKey.currentState.validate()) {
                if (_albumCover != null) {
                  insertNest();
                } else
                  _displayPhotoAlert();
              }
            },
            child: Text(
              'ANLEGEN',
              style: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      body: MagpieForm(
        date: _date,
        displayOptionsDialog: _displayOptionsDialog,
        file: _albumCover,
        formKey: _formKey,
        isNest: true,
        nameEditingController: _nameEditingController,
        noteEditingController: _noteEditingController,
        setField: _setField,
        worthVisible: false,
      ),
    );
  }

  void _setField(String field, value) {
    switch (field) {
      case "name":
        if (_name != value) {
          setState(() {
            _name = value;
          });
        }
        break;
      case "note":
        if (_note != value) {
          setState(() {
            _note = value;
          });
        }
        break;
    }
  }

  void _displayOptionsDialog() async {
    /*
    File file = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return PhotoDialog(context: context);
    }));
    setState(() {
      _albumCover = file;
    });
    */

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
      setState(() {
        _status = value;
      });
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
    if (_albumCover != image) {
      setState(() {
        _albumCover = image;
      });
    }
  }
}
