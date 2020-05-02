import 'package:flutter/material.dart';
import 'package:magpie_app/SizeConfig.dart';

class StartMessage extends StatelessWidget {
  final message;
  const StartMessage({@required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(
          fontSize:
              SizeConfig.isTablet ? SizeConfig.hori * 2 : SizeConfig.hori * 4),
    );
  }
}
