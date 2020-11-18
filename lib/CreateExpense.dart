import 'package:financetracker/Classes/Expense.dart';
import 'file:///D:/Anderes/Projekte/finance_tracker/lib/Helper/Database.dart';
import 'package:financetracker/Helper/Overview.dart';
import 'package:financetracker/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateExpense extends StatefulWidget {
  CreateExpense({Key key}) : super(key: key);
  @override
  _CreateExpenseState createState() => _CreateExpenseState();
}

class _CreateExpenseState extends State<CreateExpense> {
  final _formKey = GlobalKey<FormState>();

  Expense newExpense = new Expense(
    type: ExpenseType.Expense,
    isMonthly: false
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Overview(),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      NameFormField(),
                      DateFormField(),
                      IsMonthlyCheckbox(),
                      PlaceFormField(),
                      PriceFormField(),
                      ExpenseTypeDropdown(),
                      SubmitButton(),
                    ],
                  ),
                )
              ],
            ),
          )
      ),
    );
  }

  Widget DateFormField() {
    DateTime now = DateTime.now();
    String dateStringRep = newExpense.date == null ? "Pick a Date" : DateFormat.yMd().format(DateTime.fromMillisecondsSinceEpoch(newExpense.date));

    return Column(
      children: [
        Text("When did the expense take place?", textAlign: TextAlign.start,),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(dateStringRep),
              RaisedButton(
                child: Text("Pick a Date"),
                onPressed: () {
                  showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: new DateTime(now.year, now.month, 1),
                      lastDate: new DateTime(now.year, now.month+1, 0)
                  ).then((DateTime date) {
                    setState(() {
                      newExpense.date = date.millisecondsSinceEpoch;
                    });
                  });
                },
              )
            ]
        ),
      ],
    );
  }

  Widget ExpenseTypeDropdown() {
    return DropdownButtonFormField(
      value: ExpenseType.Expense.toString().split(".")[1],
      onSaved: (String value) => {
        if(value.compareTo(ExpenseType.Expense.toString().split(".")[1]) == 0)
          newExpense.type = ExpenseType.Expense
        else
          newExpense.type = ExpenseType.Income
      },
      onChanged: (String value) {
        setState(() {
          if(value.compareTo(ExpenseType.Expense.toString().split(".")[1]) == 0)
            newExpense.type = ExpenseType.Expense;
          else
            newExpense.type = ExpenseType.Income;
        });
      },
      items: ExpenseType.values.map((e) {
        String type = e.toString().split(".")[1];

        return DropdownMenuItem(
          value: type,
          child:
            Text(
              type,
              style: TextStyle(fontSize: 16),
            ),
        );
      }).toList()
    );
  }

  Widget NameFormField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "What was the expense for?"
      ),
      onSaved: (String value) => newExpense.name = value,
    );
  }

  Widget PlaceFormField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "Where did the expense take place?"
      ),
      onSaved: (String value) => newExpense.place = value,
    );
  }

  Widget PriceFormField() {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: "How much did the expense cost?",
      ),
      validator: (String value) {
        return double.tryParse(value) == null ? "Please enter a valid number" : null;
      },
      onSaved: (String value) => {
        newExpense.amount = double.parse(value)
      },
    );
  }

  Widget IsMonthlyCheckbox() {
    return CheckboxListTile(
      title: Text("is monthly", style: TextStyle(), textAlign: TextAlign.right,),
      value: newExpense.isMonthly,
      onChanged: (bool value) {
        setState(() {
          newExpense.isMonthly = value;
        });
      },
    );
  }

  Widget SubmitButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: ElevatedButton(
        onPressed: () {
          if(_formKey.currentState.validate()) {
            _formKey.currentState.save();

            //Save Expense in database
            SQLiteDbProvider.db.insertNewExpense(newExpense);

            //Calculate new money pools (spent money and remaining money)
            MyHomePage.manager.HandleExpense(newExpense);

            Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyHomePage()));
          }
        },
        child: Text("Submit"),
      ),
    );
  }
}

