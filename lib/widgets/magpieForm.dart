import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:magpie_app/widgets/magpieFormField.dart';

class MagpieForm extends StatelessWidget {
  final File file;
  final DateTime date;
  final Function displayOptionsDialog;
  final GlobalKey formKey;
  final TextEditingController nameEditingController;
  final bool isNest;
  final TextEditingController noteEditingController;
  final Function setField;
  final int totalWorth;
  final TextEditingController worthEditingController;
  final bool worthVisible;

  MagpieForm({
    @required this.file,
    @required this.date,
    @required this.displayOptionsDialog,
    @required this.formKey,
    @required this.nameEditingController,
    @required this.isNest,
    @required this.noteEditingController,
    @required this.setField,
    this.totalWorth,
    this.worthEditingController,
    @required this.worthVisible,
  });

  String currentCreation;
  String worthText;
  final DateFormat formatter = DateFormat("dd.MM.yyyy");

  @override
  Widget build(BuildContext context) {
    currentCreation = isNest ? "Deiner Sammlung" : "dem Gegenstand";
    worthText = isNest ? "Gesamtwert" : "Wert (optional)";

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(children: [
          GestureDetector(
            onTap: () {
              displayOptionsDialog();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  clipBehavior: Clip.antiAlias,
                  child: file != null
                      ? Image.file(file, fit: BoxFit.cover)
                      : FadeInImage.assetNetwork(
                          width: 400.0,
                          height: 250.0,
                          placeholder: 'pics/placeholder.jpg',
                          fit: BoxFit.cover,
                          image: 'pics/placeholder.jpg')),
            ),
          ),
          MagpieFormField(
            controller: nameEditingController,
            hintText: "Gib $currentCreation einen Namen",
            icon: Icons.title,
            labelText: "Name *",
            onChanged: (value) {
              setField("name", value);
            },
            validate: (value) =>
                value.isEmpty ? "Bitte gib $currentCreation einen Namen" : null,
          ),
          Visibility(
            visible: worthVisible,
            child: MagpieFormField(
              controller: worthEditingController,
              enabled: !isNest,
              icon: Icons.euro_symbol,
              initialValue:
                  isNest ? totalWorth == null ? "?" : "$totalWorth" : null,
              inputFormatter: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly
              ],
              keyboardType: TextInputType.number,
              labelText: worthText,
              onChanged: (value) {
                setField("worth", int.parse(value));
              },
            ),
          ),
          Visibility(
            visible: worthVisible,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
            ),
          ),
          MagpieFormField(
            border: OutlineInputBorder(),
            controller: noteEditingController,
            icon: Icons.speaker_notes,
            labelText: "Beschreibung (optional)",
            onChanged: (value) {
              setField("note", value);
            },
          ),
          MagpieFormField(
            enabled: false,
            icon: Icons.date_range,
            initialValue: formatter.format(date),
            labelText: "Erstelldatum",
          ),
        ]),
      ),
    );
  }
}
