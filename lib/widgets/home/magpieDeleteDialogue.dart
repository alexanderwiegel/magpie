import 'package:flutter/material.dart';

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
                  style: TextStyle(color: Colors.red),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                GestureDetector(
                  onTap: () => _delete(context, isNest, id),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.delete_forever,
                        color: Colors.amber,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      Text(
                        "Ja, ich bin mir sicher.",
                        style: TextStyle(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.cancel,
                        color: Colors.amber,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      Text(
                        "Nein, lieber doch nicht.",
                        style: TextStyle(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
