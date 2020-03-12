import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../database_helper.dart';
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
  //TextEditingController _dateController;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _nameEditingController.dispose();
    _noteEditingController.dispose();
    _worthEditingController.dispose();
    //_dateController.dispose();
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
    //_dateController = TextEditingController(text: formatter.format(_date));
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
          title: Text("Neuer Gegenstand"),
          actions: [
            FlatButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  if (_photo != null)
                    insertNestItem();
                  else
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
                      child: _photo != null
                          ? Image.file(_photo, fit: BoxFit.cover)
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
                      ? "Bitte gib dem Gegenstand einen Namen"
                      : null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: "Name *",
                    icon: Icon(Icons.title, color: Colors.amber),
                    hintText: 'Gib dem Gegenstand einen Namen',
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
                title: TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                      labelText: "Wert (optional)",
                      icon: Icon(Icons.euro_symbol, color: Colors.amber)),
                  controller: _worthEditingController,
                  onChanged: (value) {
                    setState(() {
                      _worth = int.parse(value);
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
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
                //onTap: () => _selectDate(context),
                //controller: _dateController,
                initialValue: formatter.format(_date),
                enabled: false,
                decoration: InputDecoration(
                  labelText: "Erstelldatum",
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

  /*
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
   */

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
    setState(() {
      _photo = image;
    });
  }
}
