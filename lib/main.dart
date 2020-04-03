import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:magpie_app/authenticate.dart';
import 'package:provider/provider.dart';

import 'screens/homeScreen.dart';
import 'services/auth.dart';
import 'user.dart';
import 'wrapper.dart';

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
