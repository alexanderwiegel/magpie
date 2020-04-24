import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:magpie_app/widgets/home/navDrawer.dart';
import 'package:magpie_app/services/database_helper.dart';
import 'package:magpie_app/constants.dart' as Constants;

// ignore: must_be_immutable
class Statistic extends StatelessWidget {
  DatabaseHelper db = DatabaseHelper.instance;
  String _userId;
  double smallTitleSize = 15;
  double bigTitleSize = 20;
  int totalNestCount;
  int totalItemCount;

  List<Color> colors = [Colors.blue, Colors.yellow, Colors.red, Colors.green, Colors.orange];
  List<CircularSegmentEntry> entries;
  List<Widget> descriptions;
  List<CircularStackEntry> circularData;

  Future initEntries() async {
    List<String> results = await db.getNestsWithItemCount(_userId);
    entries = List();
    descriptions = List();
    double sum = 0;
    for (int i = 0; i < results.length; i++) {
      String result = results[i];
      String name = result.substring(1, result.indexOf(","));
      String count = result.substring(result.indexOf(",")+2, result.indexOf(")"));
      if (i > 3) {
         sum += double.parse(result.substring(result.indexOf(",")+2, result.indexOf(")")));
      } else {
        entries.add(CircularSegmentEntry(double.parse(count), colors[i], rankKey: name));
        descriptions.add(description(i));
      }
    }
    if (results.length > 4) {
      entries.add(CircularSegmentEntry(sum, colors[4], rankKey: "Andere"));
      descriptions.add(description(4));
    }
    return [entries, descriptions];
  }

  @override
  Widget build(BuildContext context) {
    _userId = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      drawer: NavDrawer(userId: _userId),
      appBar: AppBar(
        title: Text("Statistik")
      ),
      body: Container(
        color: Constants.COLOR3,
        child: StaggeredGridView.count(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(8),
                child: nestsOverTimeChart("seit Beginn der Aufzeichnungen", "gesammelte Gegenstände")
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: total("Nester")
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: total("Gegenstände")
            ),
            Padding(
                padding: const EdgeInsets.all(8),
                child: nestShares("Gegenstände", "pro Nest")
            )
          ],
          staggeredTiles: [
            StaggeredTile.extent(4, 200),
            StaggeredTile.extent(2, 80),
            StaggeredTile.extent(2, 80),
            StaggeredTile.extent(4, 200),
          ]
        ),
      ),
    );
  }

  Material nestsOverTimeChart(String title, String subtitle) {
    return Material(
      color: Constants.COLOR3,
      elevation: 14,
      borderRadius: BorderRadius.circular(24),
      shadowColor: Constants.COLOR1,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(title, style: TextStyle(
                fontSize: smallTitleSize,
                color: Constants.COLOR1
              )
            ),
            Text(subtitle, style: TextStyle(fontSize: bigTitleSize)),
            Padding(padding: const EdgeInsets.symmetric(vertical: 8)),
            FutureBuilder(
              future: db.getHistory(_userId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<TimeSeriesData> data = [];
                  for (int i = 0; i < snapshot.data[0].length; i++) {
                    data.add(TimeSeriesData(
                        count: snapshot.data[0][i].toDouble(),
                        date: snapshot.data[1][i]));
                  }
                  return Expanded(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: charts.TimeSeriesChart(
                            [
                              charts.Series<TimeSeriesData, DateTime>(
                                  id: null,
                                  data: data,
                                  domainFn: (TimeSeriesData tsd, _) => tsd.date,
                                  measureFn: (TimeSeriesData tsd, _) => tsd.count
                              )
                            ]
                        )
                      /*
                        Sparkline(
                            data: snapshot.data.length == 0 ? [0] : snapshot.data,
                            lineColor: Constants.COLOR2,
                            pointsMode: PointsMode.all,
                            pointSize: 8
                          ),
                        */
                    ),
                  );
                }
                else return Container();
              },
            ),
          ],
        ),
      ),
    );
  }

  Material nestShares(String title, String subtitle){
    return Material(
      color: Constants.COLOR3,
      elevation: 14,
      borderRadius: BorderRadius.circular(24),
      shadowColor: Constants.COLOR1,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment:MainAxisAlignment.center,
              children: <Widget>[
                Text(title, style: TextStyle(
                    fontSize: smallTitleSize,
                    color: Constants.COLOR1
                )),
                Text(subtitle, style: TextStyle(fontSize: bigTitleSize)),
                FutureBuilder(
                  future: initEntries(),
                  builder: (context, snapshot) {
                    return snapshot.hasData
                      ? AnimatedCircularChart(
                        size: const Size(100, 100),
                        initialChartData: <CircularStackEntry>[
                          CircularStackEntry(snapshot.data[0], rankKey: "Nestanteile")
                        ],
                        chartType: CircularChartType.Pie
                        )
                    : Container();
                  }
                )
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: initEntries(),
              builder: (context, snapshot) {
                return snapshot.hasData
                  ? Column(children: snapshot.data[1],
                    mainAxisAlignment: MainAxisAlignment.center)
                  : Container();
              }
            )
          )
        ]
      ),
    );
  }

  Widget description(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          CircleAvatar(radius: 10, backgroundColor: colors[index]),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 5)),
          Text(entries[index].rankKey, style: TextStyle(fontSize: smallTitleSize))
        ],
      ),
    );
  }

  Material total(String title){
    return Material(
      color: Constants.COLOR3,
      elevation: 14,
      borderRadius: BorderRadius.circular(24),
      shadowColor: Constants.COLOR1,
      child: Center(
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment:MainAxisAlignment.center,
          children: <Widget>[
            Text(title, style: TextStyle(
              fontSize: smallTitleSize,
              color: Constants.COLOR1
            )),
            FutureBuilder(
              future: title == "Nester"
                  ? db.getNestCount(_userId)
                  : db.getTotalItemCount(_userId),
              builder: (context, snapshot) {
                return snapshot.hasData ?
                Text(snapshot.data.toString(), style: TextStyle(fontSize: bigTitleSize))
                : Text("?", style: TextStyle(fontSize: bigTitleSize));
              }
            ),
          ],
        ),
      ),
    );
  }
}

class TimeSeriesData {
  final double count;
  final DateTime date;
  TimeSeriesData({this.count, this.date});
}