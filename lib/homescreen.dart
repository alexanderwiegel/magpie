import 'package:flutter/material.dart';
import 'nest.dart';
import 'magpieButton.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> collections =
        List.generate(count, (int i) => Nest(name: images[i]));

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
        children:
        collections,
      ),
      floatingActionButton: MagpieButton(
        onPressed: () {
          setState(() {
            count++;
          });
        },
        title: "Neues Nest anlegen",
      ),
    );
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