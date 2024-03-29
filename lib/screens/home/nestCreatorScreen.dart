import 'package:flutter/material.dart';
import 'package:magpie_app/models/nest.dart';
import 'package:magpie_app/services/database_helper.dart';
import 'package:magpie_app/widgets/home/magpieForm.dart';
import 'package:magpie_app/widgets/home/magpiePhotoAlert.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../sortMode.dart';

class NestCreator extends StatefulWidget {
  final String userId;
  NestCreator({this.userId});

  @override
  _NestCreatorState createState() => _NestCreatorState();
}

class _NestCreatorState extends State<NestCreator> {
  MagpiePhotoAlert _magpiePhotoAlert = MagpiePhotoAlert();
  PermissionStatus _status;
  final _formKey = GlobalKey<FormState>();

  int _id;
  dynamic _albumCover;
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
    // PermissionHandler()
    //     .checkPermissionStatus(PermissionGroup.camera)
    //     .then(_updateStatus);
    _nameEditingController = TextEditingController(text: _name);
    _noteEditingController = TextEditingController(text: _note);
  }

  void _updateStatus(PermissionStatus value) {
    if (value != _status) {
      setState(() {
        _status = value;
      });
    }
  }

  void insertNest() async {
    Nest nest = Nest(
      userId: widget.userId,
      albumCover: _albumCover,
      name: _name,
      note: _note,
      date: _date,
      totalWorth: 0,
      favored: false,
      sortMode: SortMode.SortById,
      asc: true,
      onlyFavored: false,
    );
    _id = await DatabaseHelper.instance.insert(nest);
    Navigator.of(context).pop(Nest(
      id: _id,
      userId: widget.userId,
      albumCover: _albumCover,
      name: _name,
      note: _note,
      date: _date,
      totalWorth: 0,
      favored: false,
      sortMode: SortMode.SortById,
      asc: true,
      onlyFavored: false,
    ));
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
        photo: _albumCover,
        formKey: _formKey,
        isNest: true,
        nameEditingController: _nameEditingController,
        noteEditingController: _noteEditingController,
        setField: _setField,
        updateStatus: _updateStatus,
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

  void _changeImage(dynamic image) {
    if (_albumCover != image) {
      setState(() {
        _albumCover = image;
      });
    }
  }
}
