import 'package:flutter/material.dart';
import 'package:magpie_app/constants.dart' as Constants;
import '../../sortMode.dart';

class MagpieBottomAppBar extends StatelessWidget {
  final Function switchSortOrder;
  final Function showFavorites;
  final Function searchPressed;
  final SortMode sortMode;
  final bool asc;
  final bool onlyFavored;
  final Icon searchIcon;
  final Widget searchTitle;
  final Color color = Constants.COLOR3;

  MagpieBottomAppBar({
    @required this.searchPressed,
    @required this.showFavorites,
    @required this.switchSortOrder,
    @required this.sortMode,
    @required this.asc,
    @required this.onlyFavored,
    @required this.searchIcon,
    @required this.searchTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: BottomAppBar(
          clipBehavior: Clip.antiAlias,
          color: Constants.COLOR1,
          shape: CircularNotchedRectangle(),
          notchMargin: 4.0,
          child: Row(children: <Widget>[
            PopupMenuButton<SortMode>(
              icon: Icon(
                Icons.sort_by_alpha,
                color: color,
              ),
              tooltip: "Sortiermodus auswählen",
              onSelected: (SortMode result) {
                switchSortOrder(result);
              },
              initialValue: sortMode,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<SortMode>>[
                menuItem(SortMode.SortByDate, "Nach Erstelldatum sortieren"),
                menuItem(SortMode.SortByName, "Nach Name sortieren"),
                menuItem(SortMode.SortByWorth, "Nach Wert sortieren"),
                menuItem(SortMode.SortByFavored, "Nach Favoriten sortieren"),
              ],
            ),
            IconButton(
              color: color,
              tooltip: "Nur Favoriten anzeigen",
              icon: onlyFavored
                  ? Icon(Icons.favorite)
                  : Icon(Icons.favorite_border),
              onPressed: showFavorites,
            ),
            IconButton(
              color: color,
              tooltip: "Nest suchen",
              padding: const EdgeInsets.only(left: 12.0),
              alignment: Alignment.centerLeft,
              icon: searchIcon,
              onPressed: searchPressed,
            ),
            Expanded(child: searchTitle)
          ])),
    );
  }

  Widget menuItem(SortMode value, String txt) {
    return PopupMenuItem<SortMode>(
      value: value,
      child: Row(
        children: <Widget>[
          sortMode == value
              ? Icon(asc ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Constants.COLOR2)
              : Icon(null),
          Padding(
            padding: const EdgeInsets.only(left: 2.0),
          ),
          Text(txt)
        ],
      ),
    );
  }
}
