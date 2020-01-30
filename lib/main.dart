import 'package:flutter/material.dart';

import 'screens/homeScreen.dart';

void main() {
  //DatabaseHelper.instance.clear();
  runApp(Magpie());
  //DatabaseHelper.instance.vacuum();
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
      routes: {
        HomeScreen.routeName: (context) => HomeScreen(),
      },
      home: HomeScreen(),
    );
  }
}
