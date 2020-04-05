import 'package:flutter/material.dart';

class StartMessage extends StatelessWidget {
  final message;
  const StartMessage({@required this.message});

  @override
  Widget build(BuildContext context) {
    //MediaQueryData queryData = MediaQuery.of(context);
    return Text(
      message,
      style: TextStyle(fontSize: 16),
    );
  }
}