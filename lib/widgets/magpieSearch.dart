import 'nest.dart';
import 'nestItem.dart';

class MagpieSearch {
  List<dynamic> filterList(String searchText, filteredNames, bool isNest) {
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
