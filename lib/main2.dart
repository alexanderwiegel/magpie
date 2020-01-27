import 'package:flutter/material.dart';
import 'nest.dart';

void main() => runApp(Magpie());

class Magpie extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magpie',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: HomeScreen(title: 'Übersicht'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool zeroNests = true;
  int _nestCounter = 0;



  Widget _createNest() {
    if (_nestCounter == 0) {
      _firstNest();
    }
    setState(() {
      _nestCounter++;
    });

    return Nest();
  }

  // Deactivates the default message and displays the first nest
  void _firstNest() {
    setState(() {
      zeroNests = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              zeroNests ? 'Du hast noch kein Nest angelegt.' : '',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Klicke auf den Button, um ein neues Nest anzulegen.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNest,
        tooltip: 'Erzeuge ein neues Nest',
        child: Icon(Icons.add),
      ),
    );
  }
}
