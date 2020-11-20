import 'package:financetracker/Classes/ExpenseGroup.dart';

class FilterSetting {

  FilterType filterType;
  ExpenseGroup group;
  bool isAscending;

  FilterSetting({this.filterType, this.group, this.isAscending});
}

enum FilterType {
  Expense,
  Income,
  Date,
  Group
}