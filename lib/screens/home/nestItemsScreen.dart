import 'package:flutter/material.dart';
import 'package:magpie_app/widgets/home/magpieGridView.dart';
import '../../models/nest.dart';
import '../../models/nestItem.dart';
import '../../services/database_helper.dart';
import '../../widgets/home/magpieBottomAppBar.dart';
import '../../widgets/home/startMessage.dart';
import 'nestDetailScreen.dart';
import 'nestItemCreatorScreen.dart';

// ignore: must_be_immutable
class NestItems extends StatefulWidget {
  Nest nest;

  NestItems({@required this.nest});

  @override
  _NestItemsState createState() => _NestItemsState();
}

class _NestItemsState extends State<NestItems> {
  DatabaseHelper db = DatabaseHelper.instance;

  Icon _searchIcon = Icon(
    Icons.search,
    color: Colors.white,
  );
  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  List<NestItem> _names = new List();
  List<NestItem> _filteredNames = new List();
  Widget _searchTitle = Text("");

  @override
  initState() {
    super.initState();
    _initiateNest();
    _buildNestItems();
  }

  _NestItemsState() {
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

  Future<void> _initiateNest() async {
    widget.nest = await DatabaseHelper.instance.getNest(widget.nest.id);
  }

  void _fillList(snapshot) {
    _names =
        List.generate(snapshot.data.length, (index) => snapshot.data[index]);
    _filteredNames = _names;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nest.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            tooltip: "Bearbeiten",
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
                StartMessage(
                    message: "Du hast noch keinen Gegenstand angelegt."),
                StartMessage(message: "Klicke auf den Button,"),
                StartMessage(message: "um deinen ersten Gegenstand anzulegen."),
              ],
            ));
          _fillList(snapshot);
          return MagpieGridView(
            filteredNames: _filteredNames,
            isNest: false,
            searchText: _searchText,
          );
        },
      ),
      bottomNavigationBar: MagpieBottomAppBar(
        searchPressed: _searchPressed,
        showFavorites: _showFavorites,
        switchSortOrder: _switchSortOrder,
        sortMode: widget.nest.sortMode,
        asc: widget.nest.asc,
        onlyFavored: widget.nest.onlyFavored,
        searchIcon: _searchIcon,
        searchTitle: _searchTitle,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: "Neuen Gegenstand anlegen",
        onPressed: () {
          _openNestCreator();
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _switchSortOrder(result) async {
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

  void _showFavorites() {
    setState(() {
      widget.nest.onlyFavored ^= true;
    });
    DatabaseHelper.instance.update(widget.nest);
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

  Future _openNestCreator() async {
    await Navigator.of(context).push(MaterialPageRoute<Nest>(
        builder: (BuildContext context) {
          return NestItemCreator(nest: widget.nest);
        },
        fullscreenDialog: true));
  }

  Future<List<Future<NestItem>>> _buildNestItems() async {
    return List.generate(
        await DatabaseHelper.instance.getNestItemCount(widget.nest.id),
        (int index) => DatabaseHelper.instance.getNestItem(index));
  }
}
