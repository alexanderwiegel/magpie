import 'package:flutter/material.dart';

class StartMessage extends StatelessWidget {
  const StartMessage({@required this.message});
  final message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(
          fontSize: 16
      ),
    );
  }
}