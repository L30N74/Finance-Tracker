import 'package:financetracker/Dialogs/ExpenseFilterDialog.dart';
import 'package:flutter/material.dart';

class DialogHelper {

  static showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ExpenseFilterDialog()
    );
  }
}