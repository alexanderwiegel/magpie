import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../database_helper.dart';
import '../screens/nestCreatorScreen.dart';
import '../sortMode.dart';
import '../widgets/navDrawer.dart';
import '../widgets/nest.dart';
import '../widgets/startMessage.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = "/home";

  /*
  HomeScreen({this.sortMode, this.onlyFavored, this.asc});

  SortMode sortMode;
  bool asc = true;
  bool onlyFavored = false;

  HomeScreen.fromMap(dynamic obj) {
    switch (obj["homeSort"]) {
      case "SortMode.SortByName":
        this.sortMode = SortMode.SortByName;
        break;
      case "SortMode.SortByWorth":
        this.sortMode = SortMode.SortByWorth;
        break;
      case "SortMode.SortByFavored":
        this.sortMode = SortMode.SortByFavored;
        break;
      case "SortMode.SortByDate":
        this.sortMode = SortMode.SortByDate;
    }
    this.asc = obj["homeAsc"] == 0 ? false : true;
    this.onlyFavored = obj["onlyFavored"] == 0 ? false : true;
  }
   */

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DatabaseHelper db = DatabaseHelper.instance;

  SortMode sortMode = SortMode.SortByDate;
  bool asc = true;
  bool onlyFavored = false;

  Icon _searchIcon = Icon(
    Icons.search,
    color: Colors.amber,
  );
  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  List<Nest> names = new List();
  List<Nest> filteredNames = new List();
  Widget searchTitle = Text("");

  @override
  initState() {
    super.initState();
    buildNests();
  }

  _HomeScreenState() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text(
          "Übersicht",
        ),
      ),
      body: FutureBuilder<List<Nest>>(
        future: db.getNests(sortMode, asc, onlyFavored),
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
                  if (sortMode != result) {
                    setState(() {
                      asc = true;
                      sortMode = result;
                    });
                  } else {
                    setState(() {
                      asc ^= true;
                    });
                  }
                },
                initialValue: sortMode,
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<SortMode>>[
                  menuItem(SortMode.SortByDate, "Nach Erstelldatum sortieren"),
                  menuItem(SortMode.SortByName, "Nach Name sortieren"),
                  menuItem(SortMode.SortByWorth, "Nach Wert sortieren"),
                  menuItem(SortMode.SortByFavored, "Nach Favoriten sortieren"),
                ],
              ),
              IconButton(
                color: Colors.amber,
                tooltip: "Nur Favoriten anzeigen",
                icon: onlyFavored
                    ? Icon(Icons.favorite)
                    : Icon(Icons.favorite_border),
                onPressed: showFavorites,
              ),
              IconButton(
                color: Colors.amber,
                tooltip: "Nest suchen",
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
        tooltip: "Neues Nest anlegen",
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

  Widget menuItem(SortMode value, String txt) {
    return PopupMenuItem<SortMode>(
      value: value,
      child: Row(
        children: <Widget>[
          sortMode == value
              ? Icon(asc ? Icons.arrow_upward : Icons.arrow_downward,
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
      onlyFavored ^= true;
    });
  }

  List<Nest> filterList() {
    if (_searchText.isNotEmpty) {
      List<Nest> tempList = new List();
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
}
