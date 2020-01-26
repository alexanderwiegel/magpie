import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magpie_app/database_helper.dart';
import '../widgets/nest.dart';
import 'nestDetailScreen.dart';

class NestItems extends StatefulWidget {
  NestItems({@required this.nest});

  Nest nest;

  @override
  _NestItemsState createState() => _NestItemsState();
}

class _NestItemsState extends State<NestItems> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nest.name),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NestDetail(nest: widget.nest)
                ),
              );
            },
            child: Text(
              'DETAILS',
              style: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
