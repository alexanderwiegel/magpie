import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../database_helper.dart';
import '../widgets/magpieButton.dart';
import '../widgets/magpieForm.dart';
import '../widgets/nest.dart';
import '../widgets/nestItem.dart';

class NestItemDetail extends StatefulWidget {
  NestItemDetail({@required this.nestItem});

  final NestItem nestItem;

  @override
  _NestItemDetailState createState() => _NestItemDetailState();
}

class _NestItemDetailState extends State<NestItemDetail> {
  final formatter = DateFormat("dd.MM.yyyy");
  PermissionStatus _status;
  final _formKey = GlobalKey<FormState>();

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
  }

  void _updateNest() async {
    await DatabaseHelper.instance.updateItem(widget.nestItem);
    Nest nest =
        await DatabaseHelper.instance.getNest(widget.nestItem.nestId - 1);
    nest.totalWorth = await DatabaseHelper.instance.getTotalWorth(nest);
    await DatabaseHelper.instance.update(nest);
    Navigator.of(context).pop(widget.nestItem);
  }

  @override
  Widget build(BuildContext context) {
    _nameEditingController = TextEditingController(text: widget.nestItem.name);
    _noteEditingController = TextEditingController(text: widget.nestItem.note);
    _worthEditingController = TextEditingController(
        text: widget.nestItem.worth != null ? "${widget.nestItem.worth}" : "");

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nestItem.name),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            tooltip: "Speichern",
            onPressed: () {
              if (_formKey.currentState.validate()) _updateNest();
            },
          ),
        ],
      ),
      body: MagpieForm(
        date: widget.nestItem.date,
        displayOptionsDialog: _displayOptionsDialog,
        file: widget.nestItem.photo,
        formKey: _formKey,
        isNest: false,
        nameEditingController: _nameEditingController,
        noteEditingController: _noteEditingController,
        setField: _setField,
        worthEditingController: _worthEditingController,
        worthVisible: true,
      ),
      floatingActionButton: MagpieButton(
        onPressed: () {
          _displayDeleteDialogue();
        },
        title: "Gegenstand löschen",
        icon: Icons.delete,
      ),
    );
  }

  void _setField(String field, value) {
    switch (field) {
      case "name":
        if (widget.nestItem.name != value) {
          setState(() {
            widget.nestItem.name = value;
          });
        }
        break;
      case "note":
        if (widget.nestItem.note != value) {
          setState(() {
            widget.nestItem.note = value;
          });
        }
        break;
      case "worth":
        if (widget.nestItem.worth != value) {
          setState(() {
            widget.nestItem.worth = value;
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
                  "Diesen Gegenstand für immer löschen?",
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
    DatabaseHelper.instance.deleteNestItem(widget.nestItem.id);
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
    if (widget.nestItem.photo != image) {
      setState(() {
        widget.nestItem.photo = image;
      });
      DatabaseHelper.instance.updateItem(widget.nestItem);
    }
  }
}
