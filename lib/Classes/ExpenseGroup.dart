import 'package:flutter/material.dart';

class ExpenseGroup {
  int id;
  String name;
  String color; //1D1D


  ExpenseGroup({this.id, this.name, this.color});

  factory ExpenseGroup.fromMap(Map<String, dynamic> data) {
    return ExpenseGroup(
      id: data["ROWID"],
      name: data["groupName"],
      color: data["color"]
    );
  }

  Map<String, dynamic> toMap() => {
    "ROWID": id,
    "groupName": name,
    "color": color
  };

  Color getColor(){
    return Color(int.parse(color));
  }

  setColor(Color c) {
    color = c.toString();
  }

  String toString() {
    return "{$name; $color}";
  }
}