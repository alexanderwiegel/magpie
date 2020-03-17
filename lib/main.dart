import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/homeScreen.dart';

void main() {
  //DatabaseHelper.instance.clear();
  runApp(Magpie());
  //DatabaseHelper.instance.vacuum();
}

class Magpie extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("pics/placeholder.jpg"), context);
    return MaterialApp(
      title: 'Magpie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      routes: {
        HomeScreen.routeName: (context) => HomeScreen(),
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [const Locale('de', 'DE')],
      home: HomeScreen(),
    );
  }
}
