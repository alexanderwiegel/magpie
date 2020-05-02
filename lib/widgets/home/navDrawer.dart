import 'package:flutter/material.dart';
import 'package:magpie_app/SizeConfig.dart';
import 'package:magpie_app/constants.dart' as Constants;

import '../../services/auth.dart';

class NavDrawer extends StatelessWidget {
  final Color iconColor = Constants.COLOR1;
  final String userId;
  NavDrawer({this.userId});

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Padding(
              padding: const EdgeInsets.only(top: 43.0, left: 7.0),
              child: Text(
                'Magpie',
                textAlign: TextAlign.center,
                style: TextStyle(color: Constants.COLOR3, fontSize: 20),
              ),
            ),
            decoration: BoxDecoration(
                color: Constants.COLOR1,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('pics/placeholder.jpg'))),
          ),
          option(Icons.home, "Übersicht", () => navigate(context, "/home")),
          option(Icons.insert_chart, "Statistik",
              () => navigate(context, "/statistic")),
          option(Icons.account_circle, "Account",
              () => {Navigator.of(context).pop()}),
          option(Icons.settings, "Einstellungen",
              () => {Navigator.of(context).pop()}),
          option(Icons.exit_to_app, "Ausloggen", () async {
            //Navigator.of(context).pop();
            navigate(context, "/");
            await _auth.signOut();
          })
        ],
      ),
    );
  }

  Widget option(IconData icon, String title, Function onTap) {
    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.hori),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(icon,
                color: iconColor,
                size: SizeConfig.isTablet
                    ? SizeConfig.vert * 4
                    : SizeConfig.hori * 6),
            title: Text(title,
                style: TextStyle(
                    fontSize: SizeConfig.isTablet
                        ? SizeConfig.vert * 2.5
                        : SizeConfig.hori * 4)),
            onTap: onTap,
          ),
          Container(
              height: 1, width: SizeConfig.hori * 100, color: Colors.grey[200])
        ],
      ),
    );
  }

  void navigate(context, String routeName) {
    bool isNewRouteSameAsCurrent = false;

    Navigator.popUntil(context, (route) {
      if (route.settings.name == routeName ||
          route.settings.name == "/" && routeName == "/home") {
        Navigator.pop(context);
        isNewRouteSameAsCurrent = true;
      }
      return true;
    });

    if (!isNewRouteSameAsCurrent) {
      Navigator.pushReplacementNamed(context, routeName, arguments: userId);
    }
  }
}
