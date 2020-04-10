import 'package:flutter/material.dart';
import 'package:magpie_app/widgets/home/magpieButton.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/nest.dart';
import '../../services/database_helper.dart';
import '../../widgets/home/magpieDeleteDialogue.dart';
import '../../widgets/home/magpieForm.dart';

// ignore: must_be_immutable
class NestDetail extends StatefulWidget {
  Nest nest;

  NestDetail({this.nest});

  @override
  _NestDetailState createState() => _NestDetailState();
}

class _NestDetailState extends State<NestDetail> {
  MagpieDeleteDialogue _magpieDeleteDialogue = MagpieDeleteDialogue();
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

  void _updateStatus(PermissionStatus value) {
    if (value != _status) {
      setState(() {
        _status = value;
      });
    }
  }

  Future<void> _initiateNest() async {
    widget.nest = await DatabaseHelper.instance.getNest(widget.nest.id);
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
        changeImage: _changeImage,
        date: widget.nest.date,
        photo: widget.nest.albumCover,
        formKey: _formKey,
        nameEditingController: _nameEditingController,
        isNest: true,
        noteEditingController: _noteEditingController,
        setField: _setField,
        totalWorth: widget.nest.totalWorth,
        updateStatus: _updateStatus,
        worthVisible: true,
      ),
      floatingActionButton: MagpieButton(
        onPressed: () => _magpieDeleteDialogue.displayDeleteDialogue(
            context, true, widget.nest.id),
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

  void _changeImage(var image) {
    if (widget.nest.albumCover != image) {
      setState(() {
        widget.nest.albumCover = image;
      });
      DatabaseHelper.instance.update(widget.nest);
    }
  }
}
