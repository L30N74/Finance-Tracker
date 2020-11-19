class Expense {
  String name;
  int date;
  String place;
  double amount;
  ExpenseType type;
  bool isMonthly;

  Expense({this.name, this.date, this.isMonthly, this.place, this.amount, this.type});

  factory Expense.fromMap(Map<String, dynamic> data) {
    return Expense(
      name: data['name'],
      date: data['date'],
      isMonthly: data['isMonthly'] == 1 ? true : false,
      place: data['place'],
      amount: double.parse(data['amount'].toString()),
      type: data['type'].toString().compareTo(ExpenseType.Expense.toString().split(".")[1]) == 0 ?
              ExpenseType.Expense : ExpenseType.Income
    );
  }

  Map<String, dynamic> toMap() => {
    "name": name,
    "date": date,
    "isMonthly": isMonthly ? 1 : 0,
    "place": place,
    "amount": amount,
    "type": type.toString().split(".")[1] //Remove the "Expensetype." from the enum
  };


  String getDateAsString() {
    String value = "";

    var dateSplits = DateTime.fromMillisecondsSinceEpoch(date).toString().split("-");
    String day = dateSplits[2].split(" ")[0];
    String month = dateSplits[1];
    String year = dateSplits[0];

    value = "$day.$month.$year";

    return value;
  }
}

enum ExpenseType {
  Expense,
  Income
}