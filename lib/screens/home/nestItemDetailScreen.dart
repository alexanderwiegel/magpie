import 'package:flutter/material.dart';
import 'package:magpie_app/widgets/home/magpieButton.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/nest.dart';
import '../../models/nestItem.dart';
import '../../services/database_helper.dart';
import '../../widgets/home/magpieDeleteDialogue.dart';
import '../../widgets/home/magpieForm.dart';

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
    Nest nest = await DatabaseHelper.instance.getNest(widget.nestItem.nestId);
    nest.totalWorth = await DatabaseHelper.instance.getTotalWorth(nest);
    await DatabaseHelper.instance.update(nest);
    Navigator.of(context).pop(widget.nestItem);
    // TODO: Nestgesamtwert wird nicht aktualisiert angezeigt
    //  sobald man hiernach den NestDetail Screen aufruft,
    //  sondern erst beim Homescreen. Wo ist der Fehler? Async?
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
        photo: widget.nestItem.photo,
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
        onPressed: () => _magpieDeleteDialogue.displayDeleteDialogue(
            context, false, widget.nestItem.id),
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

  void _changeImage(var image) {
    if (widget.nestItem.photo != image) {
      setState(() {
        widget.nestItem.photo = image;
      });
      DatabaseHelper.instance.updateItem(widget.nestItem);
    }
  }
}
