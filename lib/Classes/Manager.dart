import 'package:financetracker/Classes/Expense.dart';
import 'file:///D:/Anderes/Projekte/finance_tracker/lib/Helper/Database.dart';

class Manager {
  double startingMoney;  //The amount of money the month started with
  double spentMoney;     //The amount of money spent since the beginning of the month
  double remainingMoney; //The amount of money remaining.
  String month;          //The month and year this manager was assigned to

  Manager(this.startingMoney, this.spentMoney, this.remainingMoney, this.month);

  factory Manager.fromMap(Map<String, dynamic> data) {
    return Manager(
      double.parse(data['starting_money']),
      double.parse(data['spent_money']),
      double.parse(data['remaining_money']),
      data['month']
    );
  }

  Map<String, dynamic> toMap() => {
    "starting_money": startingMoney,
    "spent_money": spentMoney,
    "remaining_money": remainingMoney,
    "month": month
  };

  ///Handles the update of trackers
  ///
  /// In case that the [expense]'s ExpenseType is of Type Expense, [spentMoney] will be increased by the [expense]'s amount
  /// I don't want to decrease spent money when receiving some.
  /// Remaining money will get updated in both cases.
  void HandleExpense(Expense expense) {
    if(expense.type == ExpenseType.Expense) {
      spentMoney += expense.amount;
      remainingMoney -= expense.amount;
    }
    else
      remainingMoney += expense.amount;

    //Notify database of the change
    SQLiteDbProvider.db.updateManager(this);
  }
}

