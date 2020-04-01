import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:magpie_app/widgets/magpieFormField.dart';
import 'package:magpie_app/widgets/magpieImageSelector.dart';

// ignore: must_be_immutable
class MagpieForm extends StatelessWidget {
  final Function changeImage;
  final DateTime date;
  final File file;
  final GlobalKey formKey;
  final TextEditingController nameEditingController;
  final bool isNest;
  final TextEditingController noteEditingController;
  final Function setField;
  final int totalWorth;
  final Function updateStatus;
  final TextEditingController worthEditingController;
  final bool worthVisible;

  MagpieForm({
    @required this.changeImage,
    @required this.date,
    @required this.file,
    @required this.formKey,
    @required this.nameEditingController,
    @required this.isNest,
    @required this.noteEditingController,
    @required this.setField,
    this.totalWorth,
    @required this.updateStatus,
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
          MagpieImageSelector(
            changeImage: changeImage,
            context: context,
            file: file,
            updateStatus: updateStatus,
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
