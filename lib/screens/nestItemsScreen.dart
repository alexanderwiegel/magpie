import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magpie_app/database_helper.dart';
import 'package:magpie_app/widgets/magpieButton.dart';
import 'package:magpie_app/widgets/nestItem.dart';
import '../widgets/nest.dart';
import 'nestDetailScreen.dart';
import 'nestItemCreatorScreen.dart';

class NestItems extends StatefulWidget {
  NestItems({@required this.nest});

  Nest nest;

  @override
  _NestItemsState createState() => _NestItemsState();
}

class _NestItemsState extends State<NestItems> {
  DatabaseHelper db = DatabaseHelper.instance;

  @override
  initState() {
    super.initState();
    buildNestItems();
  }

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
                    builder: (context) => NestDetail(nest: widget.nest)),
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
      body: FutureBuilder<List<NestItem>>(
        future: db.getNestItems(widget.nest.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          return GridView.count(
              padding: const EdgeInsets.all(8),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              crossAxisCount: 2,
              childAspectRatio: 1.05,
              children: List.generate(
                  snapshot.data.length, (index) => snapshot.data[index]));
        },
      ),
      floatingActionButton: MagpieButton(
        onPressed: () {
          setState(() {
            _openNestCreator();
          });
        },
        title: "Neuen Gegenstand anlegen",
      ),
    );
  }

  Future _openNestCreator() async {
    await Navigator.of(context).push(MaterialPageRoute<Nest>(
        builder: (BuildContext context) {
          return NestItemCreator(nest: widget.nest);
        },
        fullscreenDialog: true));
  }

  Future<List<Future<NestItem>>> buildNestItems() async {
    return List.generate(await DatabaseHelper.instance.getNestItemCount(widget.nest.id),
            (int index) => DatabaseHelper.instance.getNestItem(index));
  }
}
