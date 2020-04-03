import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'file:///A:/Alex/Downloads/magpie/lib/screens/authenticate/authenticate.dart';

import 'models/user.dart';
import 'screens/home/homeScreen.dart';
import 'screens/wrapper.dart';
import 'services/auth.dart';

void main() {
  //DatabaseHelper.instance.clear();
  runApp(Magpie());
  //DatabaseHelper.instance.vacuum();
}

class Magpie extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("pics/placeholder.jpg"), context);
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        title: 'Magpie',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        routes: {
          "/": (context) => Wrapper(),
          "/home": (context) => HomeScreen(),
          "/authenticate": (context) => Authenticate(),
        },
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: [const Locale('de', 'DE')],
        //home: Wrapper(),
      ),
    );
  }
}
