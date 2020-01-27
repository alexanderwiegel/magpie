import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magpie_app/database_helper.dart';
import '../widgets/nestItem.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class NestItemDetail extends StatefulWidget {
  NestItemDetail({@required this.nestItem});

  NestItem nestItem;

  @override
  _NestItemDetailState createState() => _NestItemDetailState();
}

class _NestItemDetailState extends State<NestItemDetail> {
  PermissionStatus _status;
  final _formKey = GlobalKey<FormState>();

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
  }

  @override
  Widget build(BuildContext context) {
    _nameEditingController = TextEditingController(text: widget.nestItem.name);
    _noteEditingController = TextEditingController(text: widget.nestItem.note);

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.nestItem.name),
          actions: [
            FlatButton(
              onPressed: () {
                if (_formKey.currentState.validate())
                  DatabaseHelper.instance.updateItem(widget.nestItem);
                  Navigator.of(context).pop(widget.nestItem);
              },
              child: Text(
                'SPEICHERN',
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
                    child: Image.file(
                      widget.nestItem.photo,
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
                  ),
                  controller: _nameEditingController,
                  // TODO Kein Duplikat erlauben -> Datenbank durchsuchen
                  onChanged: (value) => widget.nestItem.name = value,
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
                  onChanged: (value) => widget.nestItem.note = value,
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
    widget.nestItem.photo = image;
    DatabaseHelper.instance.updateItem(widget.nestItem);
  }
}
