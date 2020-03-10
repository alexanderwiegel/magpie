import 'dart:io';

import 'package:flutter/material.dart';

import '../database_helper.dart';
import '../screens/nestItemDetailScreen.dart';

// ignore: must_be_immutable
class NestItem extends StatefulWidget {
  NestItem(
      {@required this.nestId,
      this.id,
      this.photo,
      @required this.name,
      this.note,
      this.worth,
      this.favored});

  int nestId;
  int id;
  File photo;
  String name;
  String note;
  int worth;
  bool favored;

  Map<String, dynamic> toMap() {
    return {
      'nestId': nestId,
      'id': id,
      'albumCover': photo,
      'name': name,
      'note': note,
      'worth': worth,
      'favored': favored
    };
  }

  NestItem.fromMap(dynamic obj) {
    this.nestId = obj["nestId"];
    this.id = obj["id"];
    String path = obj["photo"].toString();
    path = path.substring(path.indexOf("s"), path.length - 2);
    this.photo = File(path);
    this.name = obj["name"];
    this.note = obj["note"];
    this.worth = obj["worth"];
    this.favored = obj["favored"] == 0 ? false : true;
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
    );
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
      child: Image.file(
        widget.photo,
        fit: BoxFit.cover,
      ),
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
        header: IconButton(
          alignment: AlignmentDirectional.centerStart,
          tooltip: "Als Favorit markieren",
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
    NestItem nestItem = NestItem(
      id: widget.id,
      photo: widget.photo,
      name: widget.name,
      note: widget.note,
      worth: widget.worth,
      favored: widget.favored,
    );
    await DatabaseHelper.instance.updateItem(nestItem);
  }
}
