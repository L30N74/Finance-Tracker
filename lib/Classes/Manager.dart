import 'package:financetracker/Classes/Expense.dart';
import 'file:///D:/Anderes/Projekte/finance_tracker/lib/Helper/Database.dart';

class Manager {
  double startingMoney; //The amount of money the month started with
  double spentMoney; //The amount of money spent since the beginning of the month
  double remainingMoney; //The amount of money remaining.
  String month; //The month and year this manager was assigned to (ie. 1/2022)

  Manager({this.startingMoney, this.spentMoney, this.remainingMoney, this.month});

  factory Manager.fromMap(Map<String, dynamic> data) {
    return Manager(
        startingMoney: double.parse(data['starting_money']),
        spentMoney: double.parse(data['spent_money']),
        remainingMoney: double.parse(data['remaining_money']),
        month: data['month']);
  }

  Map<String, dynamic> toMap() => {
        "starting_money": startingMoney,
        "spent_money": spentMoney,
        "remaining_money": remainingMoney,
        "month": month
      };

  /// Handles the update of trackers and calls the database for the new entry
  ///
  /// In case that the [expense]'s ExpenseType is of Type Expense, [spentMoney] will be increased by the [expense]'s amount
  /// I don't want to decrease spent money when receiving some.
  /// Remaining money will get updated in both cases.
  void handleExpense(Expense expense) {
    //Save Expense in database
    SQLiteDbProvider.db.insertNewExpense(expense);

    if (expense.type == ExpenseType.Expense) {
      spentMoney += expense.amount;
      remainingMoney -= expense.amount;
    } else
      remainingMoney += expense.amount;

    //Notify database of the change
    SQLiteDbProvider.db.updateManager(this);
  }


  /// Returns whether or not the manager is current
  ///
  /// Returns: true is the month part is the same as the current month
  bool isUpToDate() {
    return int.tryParse(this.month.split("/")[0]) == DateTime.now().month;
  }

  /// Handles the update of trackers and calls the database
  void reverseExpense(Expense expense) {
    if (expense.type == ExpenseType.Expense) {
      spentMoney -= expense.amount;
      remainingMoney += expense.amount;
    } else
      remainingMoney -= expense.amount;

    //Notify database of the change
    SQLiteDbProvider.db.removeExpense(expense);
    SQLiteDbProvider.db.updateManager(this);

  }
}
