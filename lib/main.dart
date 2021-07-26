import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:magpie_app/constants.dart' as Constants;
import 'package:magpie_app/screens/authenticate/loginPage.dart';
import 'package:magpie_app/screens/home/unsplashPage.dart';
import 'package:magpie_app/screens/statistic/statistic.dart';
import 'package:provider/provider.dart';

import 'models/magpieUser.dart';
import 'screens/home/homeScreen.dart';
import 'screens/wrapper.dart';
import 'services/auth.dart';

void main() async {
  //DatabaseHelper.instance.clear();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Magpie());
  //DatabaseHelper.instance.vacuum();
}

class Magpie extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("pics/placeholder.jpg"), context);
    return StreamProvider<MagpieUser>.value(
      initialData: MagpieUser(uid: ""),
      value: AuthService().user,
      child: MaterialApp(
        title: 'Magpie',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Constants.COLOR1,
        ),
        routes: {
          "/": (context) => Wrapper(),
          "/home": (context) => HomeScreen(),
          "/login": (context) => LoginPage(),
          "/unsplash": (context) => UnsplashPage(),
          "/statistic": (context) => Statistic()
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
