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
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          return GridView.count(
              padding: const EdgeInsets.all(8),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              crossAxisCount: 2,
              childAspectRatio: 1.05,
              children: List.generate(
                  snapshot.data.length, (index) => snapshot.data[index]
              )
          );
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
    print("Die ID der Sammlung lautet: ${nest.id}");
    //print("Vor Einfügen: Die ID der Sammlung lautet: ${nest.id}");
    //nest.id = await DatabaseHelper.instance.insert(nest);
    //print("Nach Einfügen: Die ID der Sammlung lautet: ${nest.id}");
    setState(() {
      nestEntries.add(nest);
    });
  }

  Future<List<Future<Nest>>> buildNests() async {
    return List.generate(await DatabaseHelper.instance.getNestCount(),
        (int index) => DatabaseHelper.instance.getNest(index));
  }
}