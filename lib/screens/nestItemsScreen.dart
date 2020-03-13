import 'package:flutter/material.dart';
import 'package:magpie_app/sortMode.dart';

import '../database_helper.dart';
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

  Icon _searchIcon = Icon(
    Icons.search,
    color: Colors.amber,
  );
  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  List<NestItem> names = new List();
  List<NestItem> filteredNames = new List();

  Widget searchTitle = Text("");

  @override
  initState() {
    super.initState();
    _initiateNest();
    buildNestItems();
  }

  _NestItemsState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          filteredNames = names;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  Future<void> _initiateNest() async {
    widget.nest = await DatabaseHelper.instance.getNest(widget.nest.id - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nest.name),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            tooltip: "Details anzeigen",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NestDetail(nest: widget.nest)),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<NestItem>>(
        future: db.getNestItems(widget.nest),
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
          fillList(snapshot);
          return GridView.count(
              padding: const EdgeInsets.all(8),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              crossAxisCount: 2,
              childAspectRatio: 1.05,
              children: filterList());
        },
      ),
      bottomNavigationBar: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: BottomAppBar(
            clipBehavior: Clip.antiAlias,
            color: Colors.teal,
            shape: CircularNotchedRectangle(),
            notchMargin: 4.0,
            child: Row(children: <Widget>[
              PopupMenuButton<SortMode>(
                icon: Icon(
                  Icons.sort_by_alpha,
                  color: Colors.amber,
                ),
                tooltip: "Sortiermodus auswählen",
                onSelected: (SortMode result) {
                  switchSortOrder(result);
                },
                initialValue: widget.nest.sortMode,
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<SortMode>>[
                  menuItem(SortMode.SortByDate, "Nach Erstelldatum sortieren"),
                  PopupMenuDivider(),
                  menuItem(SortMode.SortByName, "Nach Name sortieren"),
                  PopupMenuDivider(),
                  menuItem(SortMode.SortByWorth, "Nach Wert sortieren"),
                  PopupMenuDivider(),
                  menuItem(SortMode.SortByFavored, "Nach Favoriten sortieren"),
                ],
              ),
              IconButton(
                color: Colors.amber,
                tooltip: "Nur Favoriten anzeigen",
                icon: widget.nest.onlyFavored
                    ? Icon(Icons.favorite)
                    : Icon(Icons.favorite_border),
                onPressed: showFavorites,
              ),
              IconButton(
                color: Colors.amber,
                tooltip: "Gegenstand suchen",
                padding: const EdgeInsets.only(left: 12.0),
                alignment: Alignment.centerLeft,
                icon: _searchIcon,
                onPressed: _searchPressed,
              ),
              Expanded(child: searchTitle)
            ])),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: "Neuen Gegenstand anlegen",
        onPressed: () {
          _openNestCreator();
        },
        child: Icon(
          Icons.add,
          color: Colors.amber,
        ),
      ),
    );
  }

  void switchSortOrder(result) async {
    if (widget.nest.sortMode != result) {
      setState(() {
        widget.nest.asc = true;
        widget.nest.sortMode = result;
      });
    } else {
      setState(() {
        widget.nest.asc = !widget.nest.asc;
      });
    }
    DatabaseHelper.instance.update(widget.nest);
  }

  Widget menuItem(SortMode value, String txt) {
    return PopupMenuItem<SortMode>(
      value: value,
      child: Row(
        children: <Widget>[
          widget.nest.sortMode == value
              ? Icon(
                  widget.nest.asc ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.amber)
              : Icon(null),
          Padding(
            padding: const EdgeInsets.only(left: 2.0),
          ),
          Text(txt)
        ],
      ),
    );
  }

  void showFavorites() {
    setState(() {
      widget.nest.onlyFavored ^= true;
    });
    DatabaseHelper.instance.update(widget.nest);
  }

  List<NestItem> filterList() {
    if (_searchText.isNotEmpty) {
      List<NestItem> tempList = new List();
      for (int i = 0; i < filteredNames.length; i++) {
        if (filteredNames[i]
            .name
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          tempList.add(filteredNames[i]);
        }
      }
      filteredNames = tempList;
    }
    return filteredNames;
  }

  void fillList(snapshot) {
    names =
        List.generate(snapshot.data.length, (index) => snapshot.data[index]);
    filteredNames = names;
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this.searchTitle = new TextField(
            style: TextStyle(color: Colors.white),
            controller: _filter,
            decoration: new InputDecoration(
              hintText: 'Suchen...',
              hintStyle: TextStyle(color: Colors.white),
            ));
      } else {
        this._searchIcon = new Icon(Icons.search);
        this.searchTitle = new Text('');
        filteredNames = names;
        _filter.clear();
      }
    });
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
