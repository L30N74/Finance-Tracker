import 'package:financetracker/Classes/ExpenseGroup.dart';
import 'package:flutter/material.dart';

List<ExpenseGroup> defaultExpenseGroups = [
  new ExpenseGroup(name: "Default", color: formatColor(Colors.red.toString())),
  new ExpenseGroup(name: "Food", color: formatColor(Colors.blue.toString())),
];

Color mainPageBackgroundColor = Color(0xFF212128);
Color expenseCreationBackgroundColor = Color(0xFF323232);
Color cardBackgroundColor = Color(0xFFe0e0e0);

Color lightGreyColor = Color(0xFF4D4E57);
Color mediumDarkGreyColor = Color(0xFF3C3D44);
Color darkGreyColor = Color(0xFF1A1A1D);

TextStyle basicStyle = new TextStyle(fontSize: 16, color: Colors.white);
TextStyle errorTextStyle = new TextStyle(fontSize: 12, color: Colors.red);

TextStyle graphDetailsTextStyle =
    new TextStyle(fontSize: 20, color: Colors.white);

/// Returns the hexcode of a color as a string
String formatColor(String color) {
  String colorWork = (color.length > 18)
      ? color.substring(35).split(")")[0]
      : //Get rid of "Materialcolor(...)
      color.substring(6).split(")")[0];

  return colorWork;
}
