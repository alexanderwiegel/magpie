import 'package:flutter/material.dart';
import 'package:magpie_app/database_helper.dart';
import '../widgets/nest.dart';

class NestDetail extends StatefulWidget {
  NestDetail({this.id, @required this.name, @required this.note});

  int id;
  String name;
  String note;

  static const routeName = '/extractNest';
  @override
  _NestDetailState createState() => _NestDetailState();
}

class _NestDetailState extends State<NestDetail> {
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
  Widget build(BuildContext context) {
    //final Nest nest = ModalRoute.of(context).settings.arguments;
    _nameEditingController = TextEditingController(text: widget.name);
    _noteEditingController = TextEditingController(text: widget.note);

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
          actions: [
            FlatButton(
              onPressed: () {
                if (_formKey.currentState.validate())
                  Navigator.of(context).pop(Nest(id: widget.id, name: widget.name, note: widget.note,));
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
              Material(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                clipBehavior: Clip.antiAlias,
                child: Image.asset("pics/" + widget.name + ".jpg",
                  fit: BoxFit.cover,
                ),
              ),
              ListTile(
                leading: Icon(Icons.title, color: Colors.amber),
                title: TextFormField(
                  validator: (value) => value.isEmpty
                      ? "Bitte gib Deiner Sammlung einen Namen"
                      : null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: "Name *",
                  ),
                  controller: _nameEditingController,
                  // TODO Kein Duplikat erlauben -> Datenbank durchsuchen
                  onChanged: (value) => widget.name = value,
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
                  onChanged: (value) => widget.note = value,
                ),
              ),
            ]),
          ),
        ));
  }
}
