import 'package:flutter/material.dart';
import 'package:magpie_app/screens/homeScreen.dart';
import 'package:provider/provider.dart';

import 'authenticate.dart';
import 'user.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    print(user);
    // return either home or authenticate widget
    return user == null ? Authenticate() : HomeScreen(userId: user.uid);
  }
}
