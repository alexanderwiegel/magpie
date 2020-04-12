import 'package:flutter/material.dart';
import 'package:magpie_app/widgets/home/magpiePhotoAlert.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/nest.dart';
import '../../models/nestItem.dart';
import '../../services/database_helper.dart';
import '../../widgets/home/magpieForm.dart';

class NestItemCreator extends StatefulWidget {
  NestItemCreator({this.nest});

  final Nest nest;

  @override
  _NestItemCreatorState createState() => _NestItemCreatorState();
}

class _NestItemCreatorState extends State<NestItemCreator> {
  MagpiePhotoAlert _magpiePhotoAlert = MagpiePhotoAlert();
  PermissionStatus _status;
  final _formKey = GlobalKey<FormState>();

  int _nestId;
  dynamic _photo;
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

  void _updateStatus(PermissionStatus value) {
    if (value != _status) {
      setState(() {
        _status = value;
      });
    }
  }

  void insertNestItem() async {
    _nestId = widget.nest.id;
    NestItem nestItem = NestItem(
      userId: widget.nest.userId,
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
        changeImage: _changeImage,
        date: _date,
        photo: _photo,
        formKey: _formKey,
        isNest: false,
        nameEditingController: _nameEditingController,
        noteEditingController: _noteEditingController,
        setField: _setField,
        updateStatus: _updateStatus,
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

  void _changeImage(var image) {
    if (_photo != image) {
      setState(() {
        _photo = image;
      });
    }
  }
}
