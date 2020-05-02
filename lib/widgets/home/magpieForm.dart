import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:magpie_app/SizeConfig.dart';

import 'magpieFormField.dart';
import 'magpieImageSelector.dart';

// ignore: must_be_immutable
class MagpieForm extends StatelessWidget {
  final Function changeImage;
  final DateTime date;
  final dynamic photo;
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
    @required this.photo,
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
  static final DateFormat formatter = DateFormat("dd.MM.yyyy");

  @override
  Widget build(BuildContext context) {
    currentCreation = isNest ? "Deiner Sammlung" : "dem Gegenstand";
    worthText = isNest ? "Gesamtwert" : "Wert (optional)";
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            SizeConfig.isTablet
                ? SizedBox(
                    height: SizeConfig.vert * 20,
                    child: Container(color: Colors.teal[700]),
                  )
                : Container(),
            Row(
              children: <Widget>[
                SizeConfig.isTablet
                    ? SizedBox(
                        width: SizeConfig.hori * 50,
                        height: SizeConfig.vert * 50,
                        child: MagpieImageSelector(
                          changeImage: changeImage,
                          context: context,
                          photo: photo,
                          updateStatus: updateStatus,
                        ))
                    : Container(),
                Expanded(
                  child: Column(
                      mainAxisAlignment: SizeConfig.isTablet
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [
                        SizeConfig.isTablet
                            ? Container()
                            : MagpieImageSelector(
                                changeImage: changeImage,
                                context: context,
                                photo: photo,
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
                          validate: (value) => value.isEmpty
                              ? "Bitte gib $currentCreation einen Namen"
                              : null,
                        ),
                        Visibility(
                          visible: worthVisible,
                          child: MagpieFormField(
                            controller: worthEditingController,
                            enabled: !isNest,
                            icon: Icons.euro_symbol,
                            initialValue: isNest
                                ? totalWorth == null ? "?" : "$totalWorth"
                                : null,
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
              ],
            ),
            SizeConfig.isTablet
                ? SizedBox(
                    height: SizeConfig.vert * 20.5,
                    child: Container(color: Colors.teal[700]),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
