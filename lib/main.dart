import 'package:flutter/material.dart';
//import 'database_helper.dart';
import 'screens/homeScreen.dart';

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
    );
  }
}
