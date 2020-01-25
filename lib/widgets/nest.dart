import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../screens/nestItemsScreen.dart';

class Nest extends StatefulWidget {
  Nest({this.id, @required this.name, this.note});

  int id;
  String name;
  String note;

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'name': name,
      'note': note,
    };
  }

  Nest.fromMap(dynamic obj) {
    this.id = obj["id"];
    this.name = obj["name"];
    this.note = obj["note"];
  }

  @override
  _NestState createState() => _NestState();
}

class _NestState extends State<Nest> {
  void openNestDetailScreen() async {
    Nest nest = await Navigator.push(
      context,
        MaterialPageRoute(builder: (context) => NestItems(id: widget.id ,name: widget.name, note: widget.note)),
    );
    if (nest != null) {
      await DatabaseHelper.instance.update(nest);
      widget.name = nest.name;
      widget.note = nest.note;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget image = Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        "pics/" + widget.name + ".jpg",
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
