import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'authenticate.dart';
import 'screens/homeScreen.dart';
import 'user.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return user == null ? Authenticate() : HomeScreen(userId: user.uid);
  }
}
