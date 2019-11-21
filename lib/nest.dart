import 'package:flutter/material.dart';

class Nest extends StatefulWidget {
  const Nest({@required this.name});

  final String name;

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