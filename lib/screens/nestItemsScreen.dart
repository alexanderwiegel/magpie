import 'package:flutter/material.dart';
import 'package:magpie_app/sortMode.dart';

import '../database_helper.dart';
import '../widgets/magpieButton.dart';
import '../widgets/nest.dart';
import '../widgets/nestItem.dart';
import '../widgets/startMessage.dart';
import 'nestDetailScreen.dart';
import 'nestItemCreatorScreen.dart';

// ignore: must_be_immutable
class NestItems extends StatefulWidget {
  NestItems({@required this.nest});

  Nest nest;

  @override
  _NestItemsState createState() => _NestItemsState();
}

class _NestItemsState extends State<NestItems> {
  DatabaseHelper db = DatabaseHelper.instance;
  SortMode sortMode = SortMode.SortById;

  @override
  initState() {
    super.initState();
    buildNestItems();
  }

  Future<void> _initiateNest() async {
    widget.nest = await DatabaseHelper.instance.getNest(widget.nest.id - 1);
  }

  @override
  Widget build(BuildContext context) {
    _initiateNest();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nest.name),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NestDetail(nest: widget.nest)),
              );
            },
            child: Text(
              'DETAILS',
              style: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ),
          PopupMenuButton<SortMode>(
            onSelected: (SortMode result) {
              setState(() {
                sortMode = result;
              });
            },
            initialValue: sortMode,
            itemBuilder: (BuildContext contect) => <PopupMenuEntry<SortMode>>[
              const PopupMenuItem<SortMode>(
                  value: SortMode.SortById,
                  child: Text("Nach Erstelldatum sortieren")),
              const PopupMenuItem<SortMode>(
                  value: SortMode.SortByName,
                  child: Text("Nach Name sortieren")),
              const PopupMenuItem<SortMode>(
                  value: SortMode.SortByWorth,
                  child: Text("Nach Wert sortieren")),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<NestItem>>(
        future: db.getNestItems(widget.nest.id, sortMode),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new StartMessage(
                    message: "Du hast noch keinen Gegenstand angelegt."),
                new StartMessage(message: "Klicke auf den Button,"),
                new StartMessage(
                    message: "um deinen ersten Gegenstand anzulegen."),
              ],
            ));

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
        title: "Neuen Gegenstand anlegen",
        icon: Icons.add_circle,
      ),
    );
  }

  Future _openNestCreator() async {
    await Navigator.of(context).push(MaterialPageRoute<Nest>(
        builder: (BuildContext context) {
          return NestItemCreator(nest: widget.nest);
        },
        fullscreenDialog: true));
  }

  Future<List<Future<NestItem>>> buildNestItems() async {
    return List.generate(
        await DatabaseHelper.instance.getNestItemCount(widget.nest.id),
        (int index) => DatabaseHelper.instance.getNestItem(index));
  }
}
