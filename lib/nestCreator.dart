import 'package:flutter/material.dart';
import 'nest.dart';

class NestCreator extends StatefulWidget {
  @override
  _NestCreatorState createState() => _NestCreatorState();
}

class _NestCreatorState extends State<NestCreator> {
  String _name;
  String _note;

  TextEditingController _nameEditingController;
  TextEditingController _noteEditingController;

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
                Navigator.of(context).pop(Nest(name: _name, note: _note,));
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
        body: Column(children: [
          ListTile(
            leading: Icon(Icons.title, color: Colors.amber),
            title: TextField(
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: "Name *",
                hintText: 'Gib deiner Sammlung einen Namen',
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
        ]));
  }
}
