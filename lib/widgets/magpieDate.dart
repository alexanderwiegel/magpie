import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MagpieDate extends StatefulWidget {
  @override
  _MagpieDateState createState() => _MagpieDateState();
}

class _MagpieDateState extends State<MagpieDate> {
  final formatter = DateFormat("dd.MM.yyyy");
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: TextField(
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        labelText: "Aufnahmedatum (optional)",
        hintText: formatter.format(selectedDate),
        icon: Icon(
          Icons.date_range,
          color: Colors.amber,
        ),
      ),
    ));
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        locale: Locale("de", "DE"),
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }
}
