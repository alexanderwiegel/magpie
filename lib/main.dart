import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:magpie_app/screens/nestDetailScreen.dart';
import 'database_helper.dart';
import 'screens/homeScreen.dart';
import 'screens/takePictureScreen.dart';

void main() {
  //DatabaseHelper.instance.clear();
  runApp(Magpie());
}

class Magpie extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magpie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: HomeScreen(),
      //home: TakePictureScreen(camera: CameraDescription(name: "0")),
    );
  }
}
