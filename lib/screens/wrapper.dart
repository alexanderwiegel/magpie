import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magpie_app/SizeConfig.dart';
import 'package:magpie_app/screens/authenticate/loginPage.dart';
import 'package:provider/provider.dart';

import '../models/magpieUser.dart';
import 'home/homeScreen.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    SizeConfig.isTablet
        ? SystemChrome.setPreferredOrientations(
            [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
        : SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    final user = Provider.of<MagpieUser>(context);
    return user == null ? LoginPage() : HomeScreen(userId: user.uid);
  }
}
