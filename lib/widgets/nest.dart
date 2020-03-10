import 'dart:io';

import 'package:flutter/material.dart';

import '../database_helper.dart';
import '../screens/nestItemsScreen.dart';

// ignore: must_be_immutable
class Nest extends StatefulWidget {
  Nest(
      {this.id,
      this.albumCover,
      @required this.name,
      this.note,
      this.totalWorth,
      this.favored});

  int id;
  File albumCover;
  String name;
  String note;
  int totalWorth;
  bool favored;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'albumCover': albumCover,
      'name': name,
      'note': note,
      'totalWorth': totalWorth,
      'favored': favored
    };
  }

  Nest.fromMap(dynamic obj) {
    this.id = obj["id"];
    String path = obj["albumCover"].toString();
    path = path.substring(path.indexOf("s"), path.length - 2);
    this.albumCover = File(path);
    this.name = obj["name"];
    this.note = obj["note"];
    this.totalWorth = obj["totalWorth"];
    this.favored = obj["favored"] == 0 ? false : true;
  }

  @override
  _NestState createState() => _NestState();
}

class _NestState extends State<Nest> {
  void openNestItemsScreen() async {
    Nest oldNest = Nest(
      id: widget.id,
      albumCover: widget.albumCover,
      name: widget.name,
      note: widget.note,
      totalWorth: widget.totalWorth,
      favored: widget.favored,
    );
    Nest newNest = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NestItems(nest: oldNest)),
    );
    if (newNest != null) {
      await DatabaseHelper.instance.update(newNest);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget image = Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      clipBehavior: Clip.antiAlias,
      child: Image.file(
        widget.albumCover,
        fit: BoxFit.cover,
      ),
    );

    return GestureDetector(
      onTap: () {
        openNestItemsScreen();
      },
      child: GridTile(
        footer: Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
          ),
          clipBehavior: Clip.antiAlias,
          child: GridTileBar(
            backgroundColor: Colors.black45,
            title: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                widget.name,
                style: TextStyle(
                  color: Colors.amber,
                ),
              ),
            ),
            subtitle: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: FutureBuilder<Text>(
                future: getText(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Text("0 Gegenstände");
                  return snapshot.data;
                },
              ),
            ),
            trailing: FittedBox(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                "${widget.totalWorth}€",
                style: TextStyle(
                  color: Colors.amber,
                ),
              ),
            ),
          ),
        ),
        child: image,
        header: IconButton(
          tooltip: "Als Favorit markieren",
          alignment: AlignmentDirectional.centerStart,
          icon: widget.favored
              ? Icon(
                  Icons.favorite,
                  color: Colors.amber,
                )
              : Icon(
                  Icons.favorite_border,
                  color: Colors.amber,
                ),
          onPressed: toggleFavored,
        ),
      ),
    );
  }

  void toggleFavored() async {
    setState(() {
      widget.favored ^= true;
    });
    Nest nest = Nest(
      id: widget.id,
      albumCover: widget.albumCover,
      name: widget.name,
      note: widget.note,
      totalWorth: widget.totalWorth,
      favored: widget.favored,
    );
    await DatabaseHelper.instance.update(nest);
  }

  Future<Text> getText() async {
    int count = await DatabaseHelper.instance.getNestItemCount(widget.id);
    Text text;
    count == 1
        ? text = Text("$count Gegenstand")
        : text = Text("$count Gegenstände");
    return text;
  }
}
