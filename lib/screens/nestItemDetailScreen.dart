import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../database_helper.dart';
import '../widgets/magpieButton.dart';
import '../widgets/magpieDeleteDialogue.dart';
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
  MagpieDeleteDialogue _magpieDeleteDialogue = MagpieDeleteDialogue();
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

  void _updateStatus(PermissionStatus value) {
    if (value != _status) {
      setState(() {
        _status = value;
      });
    }
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
        changeImage: _changeImage,
        date: widget.nestItem.date,
        file: widget.nestItem.photo,
        formKey: _formKey,
        isNest: false,
        nameEditingController: _nameEditingController,
        noteEditingController: _noteEditingController,
        setField: _setField,
        updateStatus: _updateStatus,
        worthEditingController: _worthEditingController,
        worthVisible: true,
      ),
      floatingActionButton: MagpieButton(
        onPressed: () {
          _magpieDeleteDialogue.displayDeleteDialogue(
              context, _delete, "Diesen Gegenstand");
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

  Future _delete() async {
    DatabaseHelper.instance.deleteNestItem(widget.nestItem.id);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _changeImage(var image) {
    if (widget.nestItem.photo != image) {
      setState(() {
        widget.nestItem.photo = image;
      });
      DatabaseHelper.instance.updateItem(widget.nestItem);
    }
  }
}
