import 'package:financetracker/Classes/Constants.dart';
import 'package:financetracker/Classes/Expense.dart';
import 'package:financetracker/Classes/ExpenseGroup.dart';
import 'package:financetracker/Helper/Database.dart';
import 'package:financetracker/Helper/Overview.dart';
import 'package:financetracker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CreateExpense extends StatefulWidget {
  CreateExpense({Key key}) : super(key: key);
  @override
  _CreateExpenseState createState() => _CreateExpenseState();
}

class _CreateExpenseState extends State<CreateExpense> {
  final _mainFormKey = GlobalKey<FormState>();
  final _colorFormKey = GlobalKey<FormState>();

  Expense newExpense = new Expense(
    type: ExpenseType.Expense,
    date: DateTime.now().millisecondsSinceEpoch,
    isMonthly: false,
    group: new ExpenseGroup(),
  );

  bool shouldRepeat = false;
  Color pickerColor = Color(0xFF44a49);
  Color currentColor = Color(0xFF44a49);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: mainPageBackgroundColor,
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Overview(),
                Form(
                  key: _mainFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(height: 20),
                      NameFormField(),
                      SizedBox(height: 20,),
                      DateFormField(),
                      RepeatCheckbox(),
                      if(shouldRepeat) RepetitionField(),
                      GroupField(),
                      SizedBox(height: 20,),
                      PlaceFormField(),
                      SizedBox(height: 20,),
                      PriceFormField(),
                      SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Select a Type: ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          ExpenseTypeDropdown(),
                      ]),
                      SizedBox(height: 20,),
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

  Widget NameFormField() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.3,
      child: TextFormField(
        style: basicStyle,
        decoration: InputDecoration(
          labelText: "What was the expense for?",
          labelStyle: basicStyle,
          errorStyle: errorTextStyle,
          fillColor: mediumDarkGreyColor,
          filled: true,
          border: new OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: new BorderSide(),
          ),
        ),
        validator: (String value) {
          return value.length == 0 ? "Please enter something" : null;
        },
        onSaved: (String value) => newExpense.name = value,
      ),
    );
  }

  Widget DateFormField() {
    DateTime now = DateTime.now();

    return Column(
      children: [
        Text(
          "When did the expense take place?",
          style: basicStyle,
          textAlign: TextAlign.start,
        ),
        OutlineButton(
          borderSide: BorderSide(
            color: Colors.white,
            width: 1,
          ),
          color: mainPageBackgroundColor,
          child: Text(
            newExpense.getDateAsString(),
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
            ),
          ),
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
        ),
      ],
    );
  }

  Widget RepeatCheckbox() {
    return CheckboxListTile(
      title: Text("Repeat", style: TextStyle(color: Colors.white), textAlign: TextAlign.right,),
      value: shouldRepeat,
      onChanged: (bool value) {
        setState(() {
          shouldRepeat = value;
        });
      },
    );
  }

  Widget RepetitionField() {
    List<String> intervalAmountList = ["1", "2", "3", "4"];
    String intervalAmountValue = intervalAmountList[0];

    List<String> intervalFactorList = ["day(s)", "week(s)", "month(s)", "year(s)"];
    String intervalFactorValue = intervalFactorList[0];

    return Container(
      width: MediaQuery.of(context).size.width / 1.3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Repeat every ", style: TextStyle(fontSize: 20, color: Colors.white),),
          Container(
            width: 80,
            child: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: mediumDarkGreyColor,
              ),
              child: DropdownButtonFormField(
                value: intervalAmountValue,
                onSaved: (value) => {
                  if(shouldRepeat) {
                    //TODO: Set up flexible expense-repeptition
                    print(value)
                  }
                },
                onChanged: (value) => {
                  setState(() {
                    intervalFactorValue = value;
                  })
                },
                items: intervalAmountList.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child:
                    Text(
                      e,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList()
              ),
            ),
          ),
          Container(
            width: 100,
            child: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: mainPageBackgroundColor,
              ),
              child: DropdownButtonFormField(
                value: intervalFactorValue,
                onSaved: (value) => {
                  if(shouldRepeat) {
                    //TODO: Set up flexible expense-repeptition
                    print(value)
                  }
                },
                onChanged: (value) => {
                  setState(() {
                    intervalFactorValue = value;
                  })
                },
                items: intervalFactorList.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child:
                      Text(
                        e,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                  );
                }).toList()
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget GroupField() {
    String groupName = "";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          "Assign a group",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        Container(
          color: currentColor,
          width: 100,
          child: Text(""),
        ),
        /*Container(
          width: 100,
          child: DropdownButtonFormField(
            item
          ),
        )*/
        RaisedButton(
          child: Text(
            "Create Group",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () => {
            //Create popup to create a new group
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Create a new Group"),
                  content: SingleChildScrollView(
                    child: Form(
                      key: _colorFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: "The group's name",
                              labelStyle: TextStyle(),
                            ),
                            onSaved: (String value) => groupName = value,
                          ),
                          BlockPicker(
                            pickerColor: pickerColor,
                            onColorChanged: (Color color) {
                              setState(() {
                                pickerColor = color;
                              });
                            }
                          ),
                          FlatButton(
                            child: Text("Done"),
                            onPressed: () {
                              _colorFormKey.currentState.validate();

                              setState(() => {
                                currentColor = pickerColor,
                                newExpense.group.setColor(pickerColor),
                                newExpense.group.name = groupName,

                                //Notify database
                                SQLiteDbProvider.db.insertNexGroup(newExpense.group)
                              });
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }
            ),
          },
        ),
      ],
    );
  }

  Widget PlaceFormField() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.3,
      child: TextFormField(
        decoration: InputDecoration(
          labelText: "Where did the expense take place?",
          labelStyle: basicStyle,
          errorStyle: errorTextStyle,
          fillColor: mediumDarkGreyColor,
          filled: true,
          border: new OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: new BorderSide(),
          ),
        ),
        validator: (String value) {
          return value.length == 0 ? "Please enter something" : null;
        },
        onSaved: (String value) => newExpense.place = value,
      ),
    );
  }

  Widget PriceFormField() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.3,
      child: TextFormField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: "How much did the expense cost?",
          labelStyle: basicStyle,
          errorStyle: errorTextStyle,
          fillColor: mediumDarkGreyColor,
          filled: true,
          border: new OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: new BorderSide(),
          ),
        ),
        validator: (String value) {
          return double.tryParse(value) == null ? "Please enter a valid number" : null;
        },
        onSaved: (String value) => {
          newExpense.amount = double.parse(value)
        },
      ),
    );
  }

  Widget ExpenseTypeDropdown() {
    return Container(
      width: MediaQuery.of(context).size.width / 3,
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: mediumDarkGreyColor,
        ),
        child: DropdownButtonFormField(
          value: ExpenseType.Expense.toString().split(".")[1],
          onSaved: (String value) => {
            if(value.compareTo(ExpenseType.Expense.toString().split(".")[1]) == 0)
              newExpense.type = ExpenseType.Expense
            else
              newExpense.type = ExpenseType.Income
          },
          onChanged: (String value) => {
            setState(() {
              if(value.compareTo(ExpenseType.Expense.toString().split(".")[1]) == 0)
                newExpense.type = ExpenseType.Expense;
              else
                newExpense.type = ExpenseType.Income;
            })
          },
          items: ExpenseType.values.map((e) {
            String type = e.toString().split(".")[1];

            return DropdownMenuItem(
              value: type,
              child:
                Text(
                  type,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
            );
          }).toList()
        ),
      ),
    );
  }

  Widget SubmitButton() {
    return FlatButton(
      color: Colors.blue,
      minWidth: MediaQuery.of(context).size.width / 1.3,
      height: 60,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      onPressed: () {
        if(_mainFormKey.currentState.validate()) {
          _mainFormKey.currentState.save();

          //Save Expense in database
          SQLiteDbProvider.db.insertNewExpense(newExpense);

          //Calculate new money pools (spent money and remaining money)
          MyHomePage.manager.HandleExpense(newExpense);

          Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyHomePage()));
        }
      },
      child: Text("Submit"),
    );
  }
}

