import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:magpie_app/widgets/nestItem.dart';
import 'package:permission_handler/permission_handler.dart';
import '../database_helper.dart';
import '../widgets/nest.dart';

class NestItemCreator extends StatefulWidget {
  NestItemCreator({@required this.nest});

  final Nest nest;

  @override
  _NestItemCreatorState createState() => _NestItemCreatorState();
}

class _NestItemCreatorState extends State<NestItemCreator> {
  PermissionStatus _status;
  final _formKey = GlobalKey<FormState>();
  int _nestId;
  File _photo;
  String _name;
  String _note;

  TextEditingController _nameEditingController;
  TextEditingController _noteEditingController;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
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

  void insertNestItem() async {
    _nestId = widget.nest.id;
    NestItem nestItem = NestItem(
      nestId: _nestId,
      photo: _photo,
      name: _name,
      note: _note,
    );
    await DatabaseHelper.instance.insertItem(nestItem);
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
                  insertNestItem();
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
                        : Image.asset(
                            "pics/placeholder.jpg",
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.title, color: Colors.amber),
                title: TextFormField(
                  validator: (value) => value.isEmpty
                      ? "Bitte gib dem Gegenstand einen Namen"
                      : null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: "Name *",
                    hintText: 'Gib dem Gegenstand einen Namen',
                  ),
                  controller: _nameEditingController,
                  onChanged: (value) => _name = value,
                ),
              ),
              ListTile(
                leading: Icon(Icons.speaker_notes, color: Colors.amber),
                title: TextField(
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: "Beschreibung (optional)",
                    border: OutlineInputBorder(),
                  ),
                  controller: _noteEditingController,
                  onChanged: (value) => _note = value,
                ),
              ),
            ]),
          ),
        ));
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
    _photo = image;
  }
}
