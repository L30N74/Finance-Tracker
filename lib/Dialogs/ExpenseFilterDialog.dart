import 'package:financetracker/Classes/Constants.dart';
import 'package:financetracker/Classes/ExpenseGroup.dart';
import 'package:financetracker/Classes/FilterSetting.dart';
import 'package:financetracker/Helper/Database.dart';
import 'package:financetracker/main.dart';
import 'package:flutter/material.dart';

class ExpenseFilterDialog extends StatefulWidget {

  @override
  _ExpenseFilterDialogState createState() => _ExpenseFilterDialogState();
}

class _ExpenseFilterDialogState extends State<ExpenseFilterDialog> {

  List<String> filterOptions = ["Expenses", "Income", "Date", "Group"];
  String selectedType = "Expenses";
  String selectedOrderType = "Ascending";

  ExpenseGroup selectedGroup = defaultExpenseGroups[0];

  bool filterByExpenses = true;
  bool filterByIncome = false;
  bool filterByDate = false;
  bool filterByGroup = false;

  bool filterByAscDesc = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: _buildChild(),
    );
  }

  _buildChild() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: mainPageBackgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _typeChoice(),
          if(filterByAscDesc) _orderDropdown(),
          if(filterByGroup) _listGroupDropdown(),
          _submitButton(),
          SizedBox(height: 10,),
        ],
      ),
    );
  }

  _typeChoice() {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: lightGreyColor,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Container(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          color: darkGreyColor,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "Filter by",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            Theme(
              data: Theme.of(context).copyWith(
                canvasColor: lightGreyColor,
              ),
              child: DropdownButton(
                value: selectedType,
                onChanged: (String value) {
                  setState(() {
                    selectedType = value;

                    switch(value) {
                      case "Expenses":
                        filterByExpenses = true;
                        filterByAscDesc = true;
                        filterByIncome = false;
                        filterByDate = false;
                        filterByGroup = false;
                        break;
                      case "Income":
                        filterByExpenses = false;
                        filterByAscDesc = true;
                        filterByIncome = true;
                        filterByDate = false;
                        filterByGroup = false;
                        break;
                      case "Date":
                        filterByExpenses = false;
                        filterByAscDesc = true;
                        filterByIncome = false;
                        filterByDate = true;
                        filterByGroup = false;
                        break;
                      case "Group":
                        filterByExpenses = false;
                        filterByAscDesc = false;
                        filterByIncome = false;
                        filterByDate = false;
                        filterByGroup = true;
                        break;
                    }
                  });
                },
                items: filterOptions.map((entry) => DropdownMenuItem(
                    value: entry,
                    child: Text(
                      entry,
                      style: TextStyle(
                          color: Colors.white
                      ),
                    )
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _orderDropdown() {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: lightGreyColor,
      ),
      child: DropdownButton(
        value: selectedOrderType,
        onChanged: (String value) {
          setState(() {
            selectedOrderType = value;
          });
        },
        items: ["Ascending", "Descending"].map((entry) => DropdownMenuItem(
            value: entry,
            child: Text(
              entry,
              style: TextStyle(
                  color: Colors.white
              ),
            )
        )).toList(),
      ),
    );
  }

  _listGroupDropdown() {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: mediumDarkGreyColor,
      ),
      child: DropdownButtonHideUnderline(
        child: FutureBuilder<List<ExpenseGroup>>(
          future: SQLiteDbProvider.db.getAllGroups(),
          builder: (context, snapshot) => _groupDropdownBuilder(context, snapshot),
        ),
      ),
    );
  }

  _groupDropdownBuilder(context, snapshot) {
    var dropDownItemsMap;
    List<DropdownMenuItem> list = new List<DropdownMenuItem>();
    int _selectedItem = 0;

    if(snapshot.hasError){
      return new Container();
    }
    else if(snapshot.hasData) {
      dropDownItemsMap = new Map();
      list.clear();

      snapshot.data.forEach((group) {
        int index = snapshot.data.indexOf(group);
        dropDownItemsMap[index] = group;
        list.add(new DropdownMenuItem(
          value: index,
          child: _groupContainer(group),
        ));
      });

      return DropdownButton(
        items: list,
        onChanged: (value) => {
          _selectedItem = list[value].value,
          setState(() {
            //selectedItemName = dropDownItemsMap[_selectedItem].name;
            selectedGroup = dropDownItemsMap[_selectedItem];
          }),
        },
        hint: _groupContainer(selectedGroup),
      );
    }
    else {
      return CircularProgressIndicator();
    }
  }

  Widget _groupContainer(ExpenseGroup group) {
    return Container(
      //margin: EdgeInsets.symmetric(horizontal: 10),
      height: 40,
      width: 200,
      decoration: BoxDecoration(
        //borderRadius: BorderRadius.all(Radius.circular(20)),
        color: group.getColor(), //expense.type == ExpenseType.Expense ? Color.fromRGBO(200, 10, 30, 1) : Colors.green, //Color.fromRGBO(10, 150, 30, 1),
      ),
      child: Center(
        child: Text(
          group.name,
          style: TextStyle(
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  _submitButton() {
    return FlatButton(
      color: Colors.blue,
      height: 40,
      minWidth: 200,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      onPressed: () {
        FilterSetting filterSetting = new FilterSetting();

        if(filterByExpenses) {
          filterSetting.filterType = FilterType.Expense;
        } else if(filterByIncome){
          filterSetting.filterType = FilterType.Income;
        } else if(filterByDate) {
          filterSetting.filterType = FilterType.Date;
        } else if(filterByGroup) {
          filterSetting.filterType = FilterType.Group;
          filterSetting.group = selectedGroup;
        }

        filterSetting.isAscending = (selectedOrderType.compareTo("Ascending") == 0) ? true : false;

        MyHomePage.filterSetting = filterSetting;
        Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage()));
      },
      child: Text(
        "Confirm",
        style: TextStyle(
            fontSize: 16,
            color: Colors.white
        ),
      ),
    );
  }
}
