import 'package:flutter/material.dart';
import 'package:magpie_app/sortMode.dart';
import '../screens/nestCreatorScreen.dart';
import '../widgets/nest.dart';
import '../widgets/magpieButton.dart';
import '../database_helper.dart';
import '../widgets/startMessage.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = "/home";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DatabaseHelper db = DatabaseHelper.instance;
  SortMode sortMode = SortMode.SortById;

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
        future: db.getNests(sortMode),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new StartMessage(message: "Du hast noch kein Nest angelegt."),
                    new StartMessage(message: "Klicke auf den Button,"),
                    new StartMessage(message: "um dein erstes Nest anzulegen."),
                  ],
                )
            );

          return GridView.count(
              padding: const EdgeInsets.all(8),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              crossAxisCount: 2,
              childAspectRatio: 1.05,
              children: List.generate(
                  snapshot.data.length, (index) => snapshot.data[index]));
        },
      ),
      floatingActionButton: MagpieButton(
        onPressed: () {
          setState(() {
            _openNestCreator();
          });
        },
        title: "Neues Nest anlegen",
        icon: Icons.add_circle,
      ),
    );
  }

  Future _openNestCreator() async {
    await Navigator.of(context).push(MaterialPageRoute<Nest>(
        builder: (BuildContext context) {
          return NestCreator();
        },
        fullscreenDialog: true));
  }

  Future<List<Future<Nest>>> buildNests() async {
    return List.generate(await DatabaseHelper.instance.getNestCount(),
        (int index) => DatabaseHelper.instance.getNest(index));
  }
}
