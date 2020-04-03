import 'package:flutter/material.dart';
import 'package:magpie_app/screens/authenticate/loginPage.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import 'home/homeScreen.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return user == null ? LoginPage() : HomeScreen(userId: user.uid);
  }
}
