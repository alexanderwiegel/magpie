import 'package:flutter/material.dart';
import 'package:magpie_app/SizeConfig.dart';
import 'package:magpie_app/constants.dart' as Constants;

import '../../services/database_helper.dart';

class MagpieDeleteDialogue {
  void displayDeleteDialogue(BuildContext context, bool isNest, int id) async {
    await _deleteDialogueBox(context, isNest, id);
  }

  void _delete(BuildContext context, bool isNest, int id) async {
    await _actuallyDelete(context, isNest, id);
  }

  // ignore: missing_return
  Future<void> _actuallyDelete(BuildContext context, bool isNest, int id) {
    isNest
        ? DatabaseHelper.instance.deleteNest(id)
        : DatabaseHelper.instance.deleteNestItem(id);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _deleteDialogueBox(BuildContext context, bool isNest, int id) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  isNest
                      ? "Dieses Nest für immer löschen?"
                      : "Diesen Gegenstand für immer löschen?",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: SizeConfig.isTablet
                          ? SizeConfig.hori * 2
                          : SizeConfig.hori * 4),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                option(() => _delete(context, isNest, id), Icons.delete_forever,
                    "Ja, ich bin mir sicher."),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                option(() => Navigator.of(context).pop(), Icons.cancel,
                    "Nein, lieber doch nicht.")
              ],
            ),
          ),
        );
      },
    );
  }

  Widget option(Function onTap, IconData icon, String text) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size:
                SizeConfig.isTablet ? SizeConfig.hori * 3 : SizeConfig.hori * 4,
            color: Constants.COLOR2,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          Text(
            text,
            style: TextStyle(
                fontSize: SizeConfig.isTablet
                    ? SizeConfig.hori * 2
                    : SizeConfig.hori * 4),
          ),
        ],
      ),
    );
  }
}
