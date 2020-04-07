import 'package:flutter/material.dart';
import 'package:magpie_app/widgets/home/magpieGridView.dart';

import '../../models/nest.dart';
import '../../services/database_helper.dart';
import '../../sortMode.dart';
import '../../widgets/home/magpieBottomAppBar.dart';
import '../../widgets/home/navDrawer.dart';
import '../../widgets/home/startMessage.dart';
import 'nestCreatorScreen.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  final String userId;
  HomeScreen({this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DatabaseHelper db = DatabaseHelper.instance;
  String _userId;

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
    _userId = ModalRoute.of(context).settings.arguments;
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
    print(_getUserId());
    return Scaffold(
      drawer: NavDrawer(userId: _getUserId()),
      appBar: AppBar(
        title: Text(
          "Übersicht",
        ),
      ),
      body: FutureBuilder<List<Nest>>(
        future: db.getNests(_getUserId()),
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
          return MagpieGridView(
            filteredNames: _filteredNames,
            isNest: true,
            searchText: _searchText,
          );
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

  String _getUserId() {
    return _userId == null ? widget.userId : _userId;
  }

  void _switchSortOrder(SortMode result) {
    if (_sortMode != result) {
      setState(() {
        _asc = true;
        _sortMode = result;
      });
      DatabaseHelper.instance
          .updateHome(_asc, _onlyFavored, _sortMode, _getUserId());
    } else {
      setState(() {
        _asc ^= true;
      });
      DatabaseHelper.instance
          .updateHome(_asc, _onlyFavored, _sortMode, _getUserId());
    }
  }

  void _showFavorites() {
    setState(() {
      _onlyFavored ^= true;
    });
    DatabaseHelper.instance
        .updateHome(_asc, _onlyFavored, _sortMode, _getUserId());
  }

  Future _openNestCreator() async {
    await Navigator.of(context).push(MaterialPageRoute<Nest>(
        builder: (BuildContext context) {
          return NestCreator(userId: _getUserId());
        },
        fullscreenDialog: true));
  }

  void _buildNests() async {
    var homeStatus = await DatabaseHelper.instance.getHome(_getUserId());
    if (homeStatus.length != 0) {
      bool asc = homeStatus.first.values.elementAt(0) == 1 ? true : false;
      bool onlyFav = homeStatus.first.values.elementAt(1) == 1 ? true : false;
      String sortModeAsString = homeStatus.first.values.elementAt(2);
      SortMode sortMode =
          SortMode.values.firstWhere((e) => e.toString() == sortModeAsString);
      setState(() {
        _asc = asc;
        _onlyFavored = onlyFav;
        _sortMode = sortMode;
      });
    }
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
