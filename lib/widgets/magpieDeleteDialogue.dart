import 'package:flutter/material.dart';

class MagpieDeleteDialogue {
  void displayDeleteDialogue(
      BuildContext context, Function delete, String title) async {
    await _deleteDialogueBox(context, delete, title);
  }

  Future<void> _deleteDialogueBox(
      BuildContext context, Function delete, String title) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "$title für immer löschen?",
                  style: TextStyle(color: Colors.red),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                GestureDetector(
                  onTap: delete(),
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
