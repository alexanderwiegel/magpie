import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../database_helper.dart';
import '../widgets/magpieButton.dart';
import '../widgets/nest.dart';

// ignore: must_be_immutable
class NestDetail extends StatefulWidget {
  NestDetail({@required this.nest});

  Nest nest;

  @override
  _NestDetailState createState() => _NestDetailState();
}

class _NestDetailState extends State<NestDetail> {
  final formatter = DateFormat("dd.MM.yyyy");
  PermissionStatus _status;
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameEditingController;
  TextEditingController _noteEditingController;
  //TextEditingController _dateController;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _nameEditingController.dispose();
    _noteEditingController.dispose();
    //_dateController.dispose();
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
    //_dateController =
    //    TextEditingController(text: formatter.format(widget.nest.date));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nest.name),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                DatabaseHelper.instance.update(widget.nest);
                Navigator.of(context).pop(widget.nest);
              }
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 70),
          child: Column(children: [
            GestureDetector(
              onTap: () {
                _displayOptionsDialog();
                //PhotoDialog(nest: widget.nest);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  clipBehavior: Clip.antiAlias,
                  child: Image.file(
                    widget.nest.albumCover,
                    fit: BoxFit.cover,
                  ),
                ),
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
                    icon: Icon(Icons.title, color: Colors.amber)),
                controller: _nameEditingController,
                onChanged: (value) => widget.nest.name = value,
              ),
            ),
            ListTile(
              title: TextFormField(
                enabled: false,
                initialValue: widget.nest.totalWorth == null
                    ? "?"
                    : "${widget.nest.totalWorth}",
                decoration: InputDecoration(
                    labelText: "Gesamtwert",
                    icon: Icon(Icons.euro_symbol, color: Colors.amber)),
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
                onChanged: (value) => widget.nest.note = value,
              ),
            ),
            ListTile(
                title: TextFormField(
              //onTap: () => _selectDate(context),
              //controller: _dateController,
              initialValue: formatter.format(widget.nest.date),
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

  /*
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        locale: Locale("de", "DE"),
        context: context,
        initialDate: widget.nest.date,
        firstDate: DateTime(1900),
        lastDate: DateTime.now());
    if (picked != null && picked != widget.nest.date) {
      widget.nest.date = picked;
      setState(() {
        _dateController.text = formatter.format(widget.nest.date);
      });
    }
  }
   */

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
