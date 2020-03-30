import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../database_helper.dart';
import '../widgets/magpieButton.dart';
import '../widgets/magpieForm.dart';
import '../widgets/nest.dart';

// ignore: must_be_immutable
class NestDetail extends StatefulWidget {
  Nest nest;

  NestDetail({@required this.nest});

  @override
  _NestDetailState createState() => _NestDetailState();
}

class _NestDetailState extends State<NestDetail> {
  PermissionStatus _status;
  final _formKey = GlobalKey<FormState>();

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
  }

  Future<void> _initiateNest() async {
    widget.nest = await DatabaseHelper.instance.getNest(widget.nest.id - 1);
  }

  @override
  Widget build(BuildContext context) {
    _initiateNest();
    _nameEditingController = TextEditingController(text: widget.nest.name);
    _noteEditingController = TextEditingController(text: widget.nest.note);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nest.name),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            tooltip: "Speichern",
            onPressed: () {
              if (_formKey.currentState.validate()) {
                DatabaseHelper.instance.update(widget.nest);
                Navigator.of(context).pop(widget.nest);
              }
            },
          ),
        ],
      ),
      body: MagpieForm(
        date: widget.nest.date,
        displayOptionsDialog: _displayOptionsDialog,
        file: widget.nest.albumCover,
        formKey: _formKey,
        nameEditingController: _nameEditingController,
        isNest: true,
        noteEditingController: _noteEditingController,
        setField: _setField,
        totalWorth: widget.nest.totalWorth,
        worthVisible: true,
      ),
      floatingActionButton: MagpieButton(
        onPressed: () {
          _displayDeleteDialogue();
        },
        title: "Nest löschen",
        icon: Icons.delete,
      ),
    );
  }

  void _setField(String field, value) {
    switch (field) {
      case "name":
        if (widget.nest.name != value) {
          setState(() {
            widget.nest.name = value;
          });
        }
        break;
      case "note":
        if (widget.nest.note != value) {
          setState(() {
            widget.nest.note = value;
          });
        }
        break;
    }
  }

  void _displayDeleteDialogue() async {
    await _deleteDialogueBox();
  }

  Future<void> _deleteDialogueBox() {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Dieses Nest für immer löschen?",
                  style: TextStyle(color: Colors.red),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                GestureDetector(
                  onTap: _delete,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.delete_forever,
                        color: Colors.amber,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      Text(
                        "Ja, ich bin mir sicher.",
                        style: TextStyle(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.cancel,
                        color: Colors.amber,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      Text(
                        "Nein, lieber doch nicht.",
                        style: TextStyle(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future _delete() async {
    DatabaseHelper.instance.deleteNest(widget.nest.id);
    Navigator.of(context).popUntil((route) => route.isFirst);
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
    if (widget.nest.albumCover != image) {
      setState(() {
        widget.nest.albumCover = image;
      });
      DatabaseHelper.instance.update(widget.nest);
    }
  }
}
