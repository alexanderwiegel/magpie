import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magpie_app/constants.dart' as Constants;

class MagpieFormField extends StatelessWidget {
  final OutlineInputBorder border;
  final TextEditingController controller;
  final bool enabled;
  final String hintText;
  final IconData icon;
  final String initialValue;
  final List<dynamic> inputFormatter;
  final TextInputType keyboardType;
  final String labelText;
  final Function onChanged;
  final Function validate;

  MagpieFormField({
    this.border,
    this.controller,
    this.enabled,
    this.hintText,
    @required this.icon,
    this.initialValue,
    this.inputFormatter,
    this.keyboardType,
    @required this.labelText,
    this.onChanged,
    this.validate,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextFormField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          border: border,
          hintText: hintText,
          icon: Icon(icon, color: Constants.COLOR2),
          labelText: labelText,
        ),
        initialValue: initialValue,
        inputFormatters: inputFormatter,
        keyboardType: keyboardType,
        maxLines: null,
        onChanged: onChanged,
        textCapitalization: TextCapitalization.sentences,
        validator: validate,
      ),
    );
  }
}
