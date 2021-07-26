import 'package:flutter/material.dart';
import 'package:magpie_app/constants.dart' as Constants;
import 'package:magpie_app/widgets/home/magpieGridView.dart';

import '../../models/nest.dart';
import '../../services/database_helper.dart';
import '../../sortMode.dart';
import '../../widgets/home/magpieBottomAppBar.dart';
import '../../widgets/home/navDrawer.dart';
import '../../widgets/home/startMessage.dart';
import 'nestCreatorScreen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  HomeScreen({this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DatabaseHelper db = DatabaseHelper.instance;
  String _userId;
  Color iconColor = Constants.COLOR2;

  SortMode _sortMode = SortMode.SortById;
  bool _asc = true;
  bool _onlyFavored = false;

  Icon _searchIcon = Icon(Icons.search, color: Colors.white);
  final TextEditingController _filter = TextEditingController();
  String _searchText = "";
  List<Nest> _names = List();
  List<Nest> _filteredNames = List();
  Widget _searchTitle = Text("");

  @override
  initState() {
    super.initState();
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
    _userId = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      drawer: NavDrawer(userId: _getUserId()),
      appBar: AppBar(
        title: Text("Übersicht"),
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
        backgroundColor: Constants.COLOR1,
        tooltip: "Neues Nest anlegen",
        onPressed: () {
          _openNestCreator();
        },
        child: Icon(
          Icons.add,
          color: Constants.COLOR3,
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
    setState(() {});
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = Icon(Icons.close, color: Colors.white);
        this._searchTitle = TextField(
            style: TextStyle(color: iconColor),
            controller: _filter,
            decoration: InputDecoration(
              hintText: 'Suchen...',
              hintStyle: TextStyle(color: Colors.white),
            ));
      } else {
        this._searchIcon = Icon(Icons.search, color: Colors.white);
        this._searchTitle = Text('');
        _filteredNames = _names;
        _filter.clear();
      }
    });
  }
}
