import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:magpie_app/widgets/magpieBottomAppBar.dart';

import '../database_helper.dart';
import '../screens/nestCreatorScreen.dart';
import '../sortMode.dart';
import '../widgets/magpieSearch.dart';
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
  MagpieSearch _magpieSearch = MagpieSearch();

  SortMode _sortMode = SortMode.SortByDate;
  bool _asc = true;
  bool _onlyFavored = false;

  Icon _searchIcon = Icon(
    Icons.search,
    color: Colors.amber,
  );
  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  List<Nest> _names = new List();
  List<Nest> _filteredNames = new List();
  Widget _searchTitle = Text("");

  @override
  initState() {
    super.initState();
    _buildNests();
  }

  _HomeScreenState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          _filteredNames = _names;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  void _fillList(snapshot) {
    _names =
        List.generate(snapshot.data.length, (index) => snapshot.data[index]);
    _filteredNames = _names;
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
        future: db.getNests(_sortMode, _asc, _onlyFavored),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                StartMessage(message: "Du hast noch kein Nest angelegt."),
                StartMessage(message: "Klicke auf den Button,"),
                StartMessage(message: "um dein erstes Nest anzulegen."),
              ],
            ));
          _fillList(snapshot);
          return GridView.count(
              padding: const EdgeInsets.all(8),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              crossAxisCount: 2,
              childAspectRatio: 1.05,
              children:
                  _magpieSearch.filterList(_searchText, _filteredNames, true));
        },
      ),
      bottomNavigationBar: MagpieBottomAppBar(
        searchPressed: _searchPressed,
        showFavorites: _showFavorites,
        switchSortOrder: _switchSortOrder,
        sortMode: _sortMode,
        asc: _asc,
        onlyFavored: _onlyFavored,
        searchIcon: _searchIcon,
        searchTitle: _searchTitle,
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

  void _switchSortOrder(SortMode result) {
    if (_sortMode != result) {
      setState(() {
        _asc = true;
        _sortMode = result;
      });
    } else {
      setState(() {
        _asc ^= true;
      });
    }
  }

  void _showFavorites() {
    setState(() {
      _onlyFavored ^= true;
    });
  }

  Future _openNestCreator() async {
    await Navigator.of(context).push(MaterialPageRoute<Nest>(
        builder: (BuildContext context) {
          return NestCreator();
        },
        fullscreenDialog: true));
  }

  Future<List<Future<Nest>>> _buildNests() async {
    return List.generate(await DatabaseHelper.instance.getNestCount(),
        (int index) => DatabaseHelper.instance.getNest(index));
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._searchTitle = new TextField(
            style: TextStyle(color: Colors.white),
            controller: _filter,
            decoration: new InputDecoration(
              hintText: 'Suchen...',
              hintStyle: TextStyle(color: Colors.white),
            ));
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._searchTitle = new Text('');
        _filteredNames = _names;
        _filter.clear();
      }
    });
  }
}
