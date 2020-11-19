import 'package:flutter/material.dart';

class ExpenseGroup {
  String name;
  String color; //1D1D


  ExpenseGroup({this.name, this.color});

  factory ExpenseGroup.fromMap(Map<String, dynamic> data) {
    return ExpenseGroup();
  }

  Map<String, dynamic> toMap() => {
    "name": name,
    "color": color
  };

  Color getColor(){
    return Color(int.parse(color));
  }

  setColor(Color c) {
    color = c.toString();
  }
}