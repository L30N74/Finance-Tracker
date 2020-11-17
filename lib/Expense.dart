class Expense {

  String name;
  DateTime date;
  String place;
  double amount;
  ExpenseType type;
  bool isMonthly;


  Expense({this.name, this.date, this.isMonthly, this.place, this.amount, this.type});

}

enum ExpenseType {
  Expense,
  Income
}