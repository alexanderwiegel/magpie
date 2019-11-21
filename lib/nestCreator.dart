import 'package:flutter/material.dart';
import 'nest.dart';

class NestCreator extends StatefulWidget {
  @override
  _NestCreatorState createState() => _NestCreatorState();
}

class _NestCreatorState extends State<NestCreator> {
  String _name;
  TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: _name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Neues Nest"),
          actions: [
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop(Nest(name: _name));
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
            leading: Icon(
                Icons.speaker_notes,
                color: Colors.amber
            ),
            title: TextField(
              decoration: InputDecoration(
                hintText: 'Gib deiner Sammlung einen Namen',
              ),
              controller: _textEditingController,
              onChanged: (value) => _name = value,
            ),
          ),
        ]));
  }
}
