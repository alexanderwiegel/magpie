import 'package:flutter/material.dart';
import '../widgets/nest.dart';

class NestCreator extends StatefulWidget {
  @override
  _NestCreatorState createState() => _NestCreatorState();
}

class _NestCreatorState extends State<NestCreator> {
  final _formKey = GlobalKey<FormState>();
  String _name;
  String _note;

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
    _nameEditingController = TextEditingController(text: _name);
    _noteEditingController = TextEditingController(text: _note);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Neues Nest"),
          actions: [
            FlatButton(
              onPressed: () {
                if (_formKey.currentState.validate())
                  Navigator.of(context).pop(Nest(
                    name: _name,
                    note: _note,
                  ));
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
        body: Form(
          key: _formKey,
          child: Column(children: [
            ListTile(
              leading: Icon(Icons.title, color: Colors.amber),
              title: TextFormField(
                validator: (value) => value.isEmpty
                    ? "Bitte gib Deiner Sammlung einen Namen"
                    : null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: "Name *",
                  hintText: 'Gib Deiner Sammlung einen Namen',
                ),
                controller: _nameEditingController,
                onChanged: (value) => _name = value,
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
                onChanged: (value) => _note = value,
              ),
            ),
          ]),
        ));
  }
}
