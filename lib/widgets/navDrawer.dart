import 'package:flutter/material.dart';

import '../services/auth.dart';

class NavDrawer extends StatelessWidget {
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
                style: TextStyle(color: Colors.amber, fontSize: 20),
              ),
            ),
            decoration: BoxDecoration(
                color: Colors.teal,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('pics/placeholder.jpg'))),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Übersicht'),
            onTap: () => navigate(context, "/home"),
          ),
          ListTile(
            leading: Icon(Icons.insert_chart),
            title: Text('Statistik'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Account'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Einstellungen'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Ausloggen'),
              onTap: () async {
                //Navigator.of(context).pop();
                navigate(context, "/");
                await _auth.signOut();
              }),
        ],
      ),
    );
  }

  void navigate(context, String routeName) {
    bool isNewRouteSameAsCurrent = false;

    Navigator.popUntil(context, (route) {
      if (route.settings.name == routeName || route.settings.name == "/") {
        print("Du befindest dich bereits auf $routeName");
        Navigator.pop(context);
        isNewRouteSameAsCurrent = true;
      }
      return true;
    });

    if (!isNewRouteSameAsCurrent) {
      print("Navigiere nun zu $routeName");
      Navigator.pushReplacementNamed(context, routeName, arguments: userId);
    }
  }
}
