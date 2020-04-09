import 'dart:io';

import 'package:flutter/material.dart';

import '../screens/home/nestItemDetailScreen.dart';
import '../services/database_helper.dart';

// ignore: must_be_immutable
class NestItem extends StatefulWidget {
  int nestId;
  int id;
  dynamic photo;
  String name;
  String note;
  int worth;
  bool favored;
  DateTime date;
  
  NestItem(
      {@required this.nestId,
      this.id,
      this.photo,
      @required this.name,
      this.note,
      this.worth,
      this.favored,
      this.date});

  Map<String, dynamic> toMap() {
    return {
      'nestId': nestId,
      'id': id,
      'photo': photo.toString(),
      'name': name,
      'note': note,
      'worth': worth,
      'favored': favored == null ? 0 : favored ? -1 : 0,
      'date': date.millisecondsSinceEpoch,
    };
  }

  NestItem.fromMap(dynamic obj) {
    this.nestId = obj["nestId"];
    this.id = obj["id"];
    String path = obj["photo"].toString();
    if (!path.startsWith("http")) {
      path = path.substring(path.indexOf("s"), path.length - 1);
      this.photo = File(path);
    } else {
      this.photo = path;
    }
    this.name = obj["name"];
    this.note = obj["note"];
    this.worth = obj["worth"];
    this.favored = obj["favored"] == 0 ? false : true;
    this.date = DateTime.fromMillisecondsSinceEpoch(obj["date"]);
  }

  @override
  _NestItemState createState() => _NestItemState();
}

class _NestItemState extends State<NestItem> {
  void openNestItemDetailScreen() async {
    NestItem oldNestItem = NestItem(
        nestId: widget.nestId,
        id: widget.id,
        photo: widget.photo,
        name: widget.name,
        note: widget.note,
        worth: widget.worth,
        favored: widget.favored,
        date: widget.date);
    NestItem newNestItem = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NestItemDetail(nestItem: oldNestItem)),
    );
    if (newNestItem != null) {
      await DatabaseHelper.instance.updateItem(newNestItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget image = Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      clipBehavior: Clip.antiAlias,
      child: widget.photo.toString().startsWith("http")
          ? Image.network(widget.photo, fit: BoxFit.cover)
          : Image.file(widget.photo, fit: BoxFit.cover)
    );

    return GestureDetector(
      onTap: () {
        openNestItemDetailScreen();
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
              child: Text(
                widget.note != null ? widget.note : " ",
              ),
            ),
            trailing: FittedBox(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                "${widget.worth}€",
                style: TextStyle(
                  color: Colors.amber,
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
                    color: Colors.amber,
                  )
                : Icon(
                    Icons.favorite_border,
                    color: Colors.amber,
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
    NestItem nestItem = NestItem(
      nestId: widget.nestId,
      id: widget.id,
      photo: widget.photo,
      name: widget.name,
      note: widget.note,
      worth: widget.worth,
      favored: widget.favored,
      date: widget.date,
    );
    await DatabaseHelper.instance.updateItem(nestItem);
  }
}
