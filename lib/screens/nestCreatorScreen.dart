import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../database_helper.dart';
import '../widgets/nest.dart';

class NestCreator extends StatefulWidget {
  @override
  _NestCreatorState createState() => _NestCreatorState();
}

class _NestCreatorState extends State<NestCreator> {
  final formatter = DateFormat("dd.MM.yyyy");
  PermissionStatus _status;
  final _formKey = GlobalKey<FormState>();

  int _id;
  File _albumCover;
  String _name;
  String _note;
  DateTime _date = DateTime.now();

  TextEditingController _nameEditingController;
  TextEditingController _noteEditingController;
  TextEditingController _dateController;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _nameEditingController.dispose();
    _noteEditingController.dispose();
    _dateController.dispose();
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
    _dateController = TextEditingController(text: formatter.format(_date));
  }

  void insertNest() async {
    Nest nest = Nest(
      albumCover: _albumCover,
      name: _name,
      note: _note,
      date: _date,
    );
    _id = await DatabaseHelper.instance.insert(nest);
    Navigator.of(context).pop(Nest(
      id: _id,
      albumCover: _albumCover,
      name: _name,
      note: _note,
      date: _date,
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
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(children: [
              GestureDetector(
                onTap: () {
                  _displayOptionsDialog();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      clipBehavior: Clip.antiAlias,
                      child: _albumCover != null
                          ? Image.file(_albumCover, fit: BoxFit.cover)
                          : FadeInImage.assetNetwork(
                              width: 400.0,
                              height: 250.0,
                              placeholder: 'pics/placeholder.jpg',
                              fit: BoxFit.cover,
                              image: 'pics/placeholder.jpg')),
                ),
              ),
              ListTile(
                title: TextFormField(
                  validator: (value) => value.isEmpty
                      ? "Bitte gib Deiner Sammlung einen Namen"
                      : null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: "Name *",
                    icon: Icon(Icons.title, color: Colors.amber),
                    hintText: 'Gib Deiner Sammlung einen Namen',
                  ),
                  controller: _nameEditingController,
                  onChanged: (value) {
                    setState(() {
                      _name = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: TextField(
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: "Beschreibung (optional)",
                    icon: Icon(Icons.speaker_notes, color: Colors.amber),
                    border: OutlineInputBorder(),
                  ),
                  controller: _noteEditingController,
                  onChanged: (value) {
                    setState(() {
                      _note = value;
                    });
                  },
                ),
              ),
              ListTile(
                  title: TextFormField(
                onTap: () => _selectDate(context),
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: "Aufnahmedatum (optional)",
                  icon: Icon(
                    Icons.date_range,
                    color: Colors.amber,
                  ),
                ),
              ))
            ]),
          ),
        ));
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        locale: Locale("de", "DE"),
        context: context,
        initialDate: _date,
        firstDate: DateTime(1900),
        lastDate: DateTime.now());
    if (picked != null && picked != _date) {
      _date = picked;
      setState(() {
        _dateController.text = formatter.format(_date);
      });
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
    setState(() {
      _albumCover = image;
    });
  }
}
