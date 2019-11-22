import 'package:flutter/material.dart';

class Nest extends StatefulWidget {
  Nest({@required this.name, this.note});

  String name;
  String note;

  @override
  _NestState createState() => _NestState();
}

class _NestState extends State<Nest> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 90,
          width: 90,
          decoration: BoxDecoration(
            border: Border.all(),
            shape: BoxShape.circle,
            image: DecorationImage(image: AssetImage("pics/" + widget.name + ".jpg"),
                fit: BoxFit.cover,
            ),
          ),
        ),
        Text(
          widget.name,
        ),
      ],
    );
  }
}