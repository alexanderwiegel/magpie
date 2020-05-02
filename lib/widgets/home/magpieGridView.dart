import 'package:flutter/material.dart';
import 'package:magpie_app/SizeConfig.dart';
import 'package:magpie_app/models/nest.dart';
import 'package:magpie_app/models/nestItem.dart';

// ignore: must_be_immutable
class MagpieGridView extends StatelessWidget {
  List filteredNames;
  final bool isNest;
  final String searchText;

  MagpieGridView({
    @required this.filteredNames,
    @required this.isNest,
    @required this.searchText,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
        padding: const EdgeInsets.all(8),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        crossAxisCount: SizeConfig.isTablet ? 5 : 2,
        childAspectRatio: 1.05,
        children: _filterList());
  }

  List<dynamic> _filterList() {
    List tempList;
    isNest ? tempList = new List<Nest>() : tempList = new List<NestItem>();
    if (searchText.isNotEmpty) {
      for (int i = 0; i < filteredNames.length; i++) {
        if (filteredNames[i]
            .name
            .toLowerCase()
            .contains(searchText.toLowerCase())) {
          tempList.add(filteredNames[i]);
        }
      }
      filteredNames = tempList;
    }
    return filteredNames;
  }
}
