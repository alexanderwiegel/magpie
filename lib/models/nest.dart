import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:magpie_app/constants.dart' as Constants;
import '../screens/home/nestItemsScreen.dart';
import '../services/database_helper.dart';
import '../sortMode.dart';

// ignore: must_be_immutable
class Nest extends StatefulWidget {
  int id;
  String userId;
  dynamic albumCover;
  String name;
  String note;
  int totalWorth;
  bool favored;
  DateTime date;
  SortMode sortMode;
  bool asc;
  bool onlyFavored;

  Nest(
      {this.id,
      this.userId,
      this.albumCover,
      @required this.name,
      this.note,
      this.totalWorth,
      this.favored,
      this.date,
      this.sortMode,
      this.asc,
      this.onlyFavored});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'albumCover': albumCover.toString(),
      'name': name,
      'note': note,
      'totalWorth': totalWorth ?? 0,
      'favored': favored == null ? 0 : favored ? -1 : 0,
      'date': date.millisecondsSinceEpoch,
      'sortMode': sortMode.toString(),
      'asc': asc ? 1 : 0,
      'onlyFavored': onlyFavored ? 1 : 0
    };
  }

  Nest.fromMap(dynamic obj) {
    this.id = obj["id"];
    this.userId = obj["userId"];
    String path = obj["albumCover"].toString();
    if (!path.startsWith("http")) {
      path = path.substring(path.indexOf("/"), path.length - 1);
      this.albumCover = File(path);
    } else {
      this.albumCover = path;
    }
    this.name = obj["name"];
    this.note = obj["note"];
    this.totalWorth = obj["totalWorth"];
    this.favored = obj["favored"] == 0 ? false : true;
    this.date = DateTime.fromMillisecondsSinceEpoch(obj["date"]);
    switch (obj["sortMode"]) {
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
    this.asc = obj["asc"] == 0 ? false : true;
    this.onlyFavored = obj["onlyFavored"] == 0 ? false : true;
  }

  @override
  _NestState createState() => _NestState();
}

class _NestState extends State<Nest> {
  void openNestItemsScreen() async {
    Nest oldNest = Nest(
      id: widget.id,
      userId: widget.userId,
      albumCover: widget.albumCover,
      name: widget.name,
      note: widget.note,
      totalWorth: widget.totalWorth,
      favored: widget.favored,
      date: widget.date,
      asc: widget.asc,
      sortMode: widget.sortMode,
      onlyFavored: widget.onlyFavored,
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
      child: widget.albumCover.toString().startsWith("http")
          ? CachedNetworkImage(
              imageUrl: widget.albumCover+"fit=crop&w=200&dpr=2",
              fit: BoxFit.cover)
          : Image.file(widget.albumCover, fit: BoxFit.cover)
    );

    return GestureDetector(
      onTap: () => openNestItemsScreen(),
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
                  color: Constants.COLOR2,
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
                  color: Constants.COLOR2,
                ),
              ),
            ),
          ),
        ),
        child: image,
        header: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.topStart,
          child: IconButton(
            tooltip: widget.favored
                ? "Als Favorit entfernen"
                : "Als Favorit markieren",
            alignment: AlignmentDirectional.centerStart,
            icon: widget.favored
                ? Icon(
                    Icons.favorite,
                    color: Constants.COLOR2,
                  )
                : Icon(
                    Icons.favorite_border,
                    color: Constants.COLOR2,
                  ),
            onPressed: toggleFavored,
          ),
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
      userId: widget.userId,
      albumCover: widget.albumCover,
      name: widget.name,
      note: widget.note,
      totalWorth: widget.totalWorth,
      favored: widget.favored,
      date: widget.date,
      sortMode: widget.sortMode,
      asc: widget.asc,
      onlyFavored: widget.onlyFavored,
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
