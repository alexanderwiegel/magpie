import 'package:flutter/material.dart';
import '../screens/nestCreatorScreen.dart';
import '../widgets/nest.dart';
import '../widgets/magpieButton.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Nest> nestEntries = new List();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Magpie"),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: nestEntries.length,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (context, index) {
          return Nest(name: nestEntries[index].name);
        },
      ),
      floatingActionButton: MagpieButton(
        onPressed: () {
          setState(() {
            _openNestCreator();
          });
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
    if (nest.name != null) {
      setState(() {
        nestEntries.add(nest);
      });
    }
  }
}
