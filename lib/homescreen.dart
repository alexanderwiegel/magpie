import 'package:flutter/material.dart';
import 'nestCreator.dart';
import 'nest.dart';
import 'magpieButton.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int count = 0;

  //var nestEntries = List(30);

  @override
  Widget build(BuildContext context) {
    //List<Nest> nests = List.generate(count, (int i) => Nest(name: nestEntries[count-1],));
    List<Nest> nests = List.generate(count, (int i) => Nest(name: images[i]));

    return Scaffold(
      appBar: AppBar(
        title: Text("Übersicht"),
      ),
      body: GridView.count(
        primary: false,
        padding: const EdgeInsets.all(10),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 3,
        children: nests,
      ),
      floatingActionButton: MagpieButton(
        onPressed: () {
          setState(() {
            count++;
          });
          //_openNestCreator();
        },
        title: "Neues Nest anlegen",
      ),
    );
  }

  Future _openNestCreator() async {
    Nest nest = await Navigator.of(context).push(MaterialPageRoute<Nest>(
        builder: (BuildContext context) {
          return NestCreator();
        },
        fullscreenDialog: true));
    if (nest != null) {
      setState(() {
        //nestEntries[count].add(nest.name);
        count++;
      });
    }
  }
}

List images = [
  "Busenhalter",
  "Buttons",
  "Bücher",
  "Fotos",
  "Kameras",
  "Kassetten",
  "Modellautos",
  "Muscheln",
  "Rahmen",
  "Schallplatten",
  "Schatullen",
  "Uhren"
];

