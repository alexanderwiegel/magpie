import 'dart:io';

import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../screens/nestItemsScreen.dart';

class Nest extends StatefulWidget {
  Nest({this.id, this.albumCover, @required this.name, this.note});

  int id;
  File albumCover;
  String name;
  String note;

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'albumCover' : albumCover,
      'name': name,
      'note': note,
    };
  }

  Nest.fromMap(dynamic obj) {
    this.id = obj["id"];
    String path = obj["albumCover"].toString();
    path = path.substring(path.indexOf("s"), path.length - 2);
    this.albumCover = File(path);
    this.name = obj["name"];
    this.note = obj["note"];
  }

  @override
  _NestState createState() => _NestState();
}

class _NestState extends State<Nest> {
  void openNestDetailScreen() async {
    Nest oldNest = Nest(id: widget.id, albumCover: widget.albumCover, name: widget.name, note: widget.note);
    Nest newNest = await Navigator.push(
      context,
        MaterialPageRoute(builder: (context) => NestItems(nest: oldNest)),
    );
    if (newNest != null) {
      await DatabaseHelper.instance.update(newNest);
      //widget.albumCover = newNest.albumCover;
      //widget.name = newNest.name;
      //widget.note = newNest.note;
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
        openNestDetailScreen();
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
              // TODO Anzahl Items aus Datenbank holen
              child: Text(
                "Anzahl Items",
              ),
            ),
          ),
        ),
        child: image,
      ),
    );
  }
}
