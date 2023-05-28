import 'package:flutter/material.dart';
import '../constants.dart';

InputDecoration buildInputDecoration(IconData icons, String hinttext) {
  return InputDecoration(
    hintText: hinttext,
    counter: Offstage(),
    prefixIcon: Icon(
      icons,
      color: Color(0xFF4CA6A8),
    ),
    fillColor: Color(0xFFF5F5F5),
    filled: true,
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: BorderSide(color: Colors.red, width: 2)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: BorderSide(color: kPrimaryColor, width: 2),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: BorderSide(
        color: Color(0xFF4CA6A8),
        width: 2,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: BorderSide(
        color: Color(0xFFF5F5F5),
        width: 2,
      ),
    ),
  );
}
