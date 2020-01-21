import 'package:flutter/material.dart';
import '../screens/nestCreatorScreen.dart';
import '../widgets/nest.dart';
import '../widgets/magpieButton.dart';
import '../database_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Nest> nestEntries = new List();
  DatabaseHelper db = DatabaseHelper.instance;

  @override
  initState() {
    super.initState();
    buildNests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Magpie"),
      ),
        body: FutureBuilder<List<Nest>>(
          future: db.getNests(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

            return GridView.count(
              padding: const EdgeInsets.all(10),
                crossAxisCount: 3,
              children: List.generate(snapshot.data.length, (index) => snapshot.data[index])
            );
          },
        ),
      /*
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: nestEntries.length,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (context, index) {
          //return Nest(name: nestEntries[index].name);
          return FutureBuilder<Nest>(
            future: buildNest(index),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else {
                return snapshot.data;
              }
            },
          );
        },
      ),
      */

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
    int id = await DatabaseHelper.instance.insert(nest);
    print("Die ID der Sammlung lautet: $id");
    setState(() {
      nestEntries.add(nest);
    });
  }

  Future<Nest> buildNest(int id) async {
    Nest test = await DatabaseHelper.instance.getNest(id);
    return test;
  }

  Future<List<Future<Nest>>> buildNests() async {
    return List.generate(
        await DatabaseHelper.instance.getNestCount(),
            (int index)
        => buildNest(index));
  }
}
