import 'package:financetracker/Database.dart';

class Manager {
  int id;
  double startingMoney;  //The amount of money the month started with
  double spentMoney;     //The amount of money spent since the beginning of the month
  double remainingMoney; //The amount of money remaining.
  DateTime month;        //The month and year this manager was assigned to

  Manager(this.id, this.startingMoney, this.spentMoney, this.remainingMoney, this.month);

  factory Manager.fromMap(Map<String, dynamic> data) {
    return Manager(
      data['id'],
      data['starting_money'],
      data['spent_money'],
      data['remaining_money'],
      data['month']
    );
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "startingMoney": startingMoney,
    "spentMoney": spentMoney,
    "remainingMoney": remainingMoney,
    "month": month
  };
}

