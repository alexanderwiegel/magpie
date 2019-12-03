import 'package:flutter/material.dart';
import 'package:magpie_app/homescreen.dart';

void main() => runApp(Magpie());

class Magpie extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magpie',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: HomeScreen(),
      //TakePictureScreen(camera: CameraDescription(name: "0"))
    );
  }
}
