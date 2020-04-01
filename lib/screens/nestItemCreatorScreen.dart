import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../database_helper.dart';
import '../widgets/magpieForm.dart';
import '../widgets/magpiePhotoAlert.dart';
import '../widgets/nest.dart';
import '../widgets/nestItem.dart';

class NestItemCreator extends StatefulWidget {
  NestItemCreator({@required this.nest});

  final Nest nest;

  @override
  _NestItemCreatorState createState() => _NestItemCreatorState();
}

class _NestItemCreatorState extends State<NestItemCreator> {
  final formatter = DateFormat("dd.MM.yyyy");
  MagpiePhotoAlert _magpiePhotoAlert = MagpiePhotoAlert();
  PermissionStatus _status;
  final _formKey = GlobalKey<FormState>();

  int _nestId;
  File _photo;
  String _name;
  String _note;
  int _worth;
  DateTime _date = DateTime.now();

  TextEditingController _nameEditingController;
  TextEditingController _noteEditingController;
  TextEditingController _worthEditingController;

  @override
  void dispose() {
    _nameEditingController.dispose();
    _noteEditingController.dispose();
    _worthEditingController.dispose();
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
    _worthEditingController =
        TextEditingController(text: _worth != null ? "$_worth" : "");
  }

  void insertNestItem() async {
    _nestId = widget.nest.id;
    NestItem nestItem = NestItem(
      nestId: _nestId,
      photo: _photo,
      name: _name,
      note: _note,
      worth: _worth != null ? _worth : 0,
      date: _date,
    );
    await DatabaseHelper.instance.insertItem(nestItem);
    widget.nest.totalWorth =
        await DatabaseHelper.instance.getTotalWorth(widget.nest);
    DatabaseHelper.instance.update(widget.nest);
    Navigator.of(context).pop(widget.nest);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Neuer Gegenstand"),
        actions: [
          FlatButton(
            onPressed: () {
              if (_formKey.currentState.validate()) {
                if (_photo != null)
                  insertNestItem();
                else
                  _magpiePhotoAlert.displayPhotoAlert(context);
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
        file: _photo,
        formKey: _formKey,
        isNest: false,
        nameEditingController: _nameEditingController,
        noteEditingController: _noteEditingController,
        setField: _setField,
        worthEditingController: _worthEditingController,
        worthVisible: true,
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
      case "worth":
        if (_worth != value) {
          setState(() {
            _worth = value;
          });
        }
        break;
    }
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
    if (_photo != image) {
      setState(() {
        _photo = image;
      });
    }
  }
}
