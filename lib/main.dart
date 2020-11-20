import 'package:financetracker/Classes/Constants.dart';
import 'package:financetracker/Classes/Expense.dart';
import 'package:financetracker/Classes/ExpenseGroup.dart';
import 'package:financetracker/CreateExpense.dart';
import 'package:financetracker/CreateManager.dart';
import 'package:financetracker/Classes/Manager.dart';
import 'package:financetracker/Helper/Database.dart';
import 'package:financetracker/Helper/Overview.dart';
import 'package:financetracker/Classes/FilterSetting.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      home: MyHomePage(title: 'Finance Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  static Manager manager;
  static FilterSetting filterSetting = new FilterSetting(filterType: FilterType.Date, isAscending: false);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  /*FILTER*/
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
  void initState() {
    super.initState();

    SQLiteDbProvider.db.getCurrentManager().then((mgr) => {
      if(mgr == null) {
        // Redirect user to page to create a new manager
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateManager()))
      }
      else {
        //There already exists a manager for this month. Retrieve data
        MyHomePage.manager = mgr,
        setState(() {})
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: mainPageBackgroundColor,
        body: Column(
          children: <Widget>[
            Overview(),
            Container(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      "Recent Expenses",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.filter_list, color: Colors.black, size: 30,),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => ExpenseFilterDialog(),
                      );
                    },
                  ),
                ],
              ),
            ),
            ShowExpenses(),
          ],
        ),
        bottomNavigationBar: MyBottomBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          width: 60,
          height: 60,
          child: FloatingActionButton(
            backgroundColor: Colors.blue,
            child: Icon(Icons.add, size: 28,),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateExpense())),
          ),
        ),
      ),
    );
  }

  Widget ShowExpenses() {
    return FutureBuilder(
      future: SQLiteDbProvider.db.getExpenses(DateTime.now()),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return _builder(snapshot.data);
        }
        else if(snapshot.hasError) {
          return Column(
            children: [
              Text(
                "Error while retrieving data. [${snapshot.error}]",
                style: TextStyle(fontSize: 22, color: Colors.white),
              ),
              Container(

              ),
            ],
          );
        }
        else {
          return Column(
            children: [
              SizedBox(
                child: CircularProgressIndicator(backgroundColor: Colors.green,),
                width: 60,
                height: 60,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Loading...', style: TextStyle(color: Colors.white),),
              )
            ],
          );
        }
      },
    );
  }

  _builder(list) {
    return Expanded(
      child: ListView.builder(
        //padding: const EdgeInsets.only(top: 0, bottom: 100),
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) => CreateExpenseItem(list[index])
      ),
    );
  }

  Widget CreateExpenseItem(expense) {
    return Container(
      height: 100,
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
            )
          ]
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                height: 12,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: expense.group.getColor(), //expense.type == ExpenseType.Expense ? Color.fromRGBO(200, 10, 30, 1) : Colors.green, //Color.fromRGBO(10, 150, 30, 1),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: Text(
                  expense.getDateAsString(), // DateFormat.yMd().format(DateTime.fromMillisecondsSinceEpoch(list.data[index].date)),
                  style: TextStyle(),
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  expense.name,
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.right,
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Text(
                    (expense.type == ExpenseType.Expense ? "-" : "+") + expense.amount.toStringAsFixed(2) + "€",
                    style: TextStyle(
                      fontSize: 24,
                      color: expense.type == ExpenseType.Expense ? Color.fromRGBO(200, 10, 30, 1) : Colors.green, //Color.fromRGBO(10, 150, 30, 1),
                    ),
                  )
              ),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  expense.place,
                  style: TextStyle(),
                ),
              ),
              SizedBox(width: 10,),
            ],
          ),
        ],
      ),
    );
  }

  Widget MyBottomBar() {
    return BottomAppBar(
      color: Colors.white, //Color(0xFF216128),
      shape: CircularNotchedRectangle(),
      child: Container(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MaterialButton(
              child: Text("Reset Managers"),
              onPressed: () {
                setState(() {
                  SQLiteDbProvider.db.resetManagerTable();
                  MyHomePage.manager = null;
                });
              },
            ),
            /*MaterialButton(
              child: Text("Reset Expenses"),
              onPressed: () {
                setState(() {
                  SQLiteDbProvider.db.resetExpensesTable();
                  MyHomePage.manager.spentMoney = 0;
                  MyHomePage.manager.remainingMoney = MyHomePage.manager.startingMoney;
                  SQLiteDbProvider.db.updateManager(MyHomePage.manager);
                });
              },
            ),*/
            MaterialButton(
              child: Text("Reset Groups"),
              onPressed: () {
                setState(() {
                  SQLiteDbProvider.db.resetGroupsTable();
                });
              },
            ),
            MaterialButton(
              child: Text("Reset Database"),
              onPressed: () {
                setState(() {
                  SQLiteDbProvider.db.setUpTables();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future CreateManagerAlert(BuildContext context) {
    TextEditingController controller = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Monthly Setup"),
          content: Container(
            height: 200,
            child: Column(
              children: [
                Text("How much money is at your disposal this month?"),
                SizedBox(height: 50,),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  onSubmitted: (String value) async {
                    MyHomePage.manager = await SQLiteDbProvider.db.insertNewManager(double.parse(value), DateFormat.yM().format(new DateTime(DateTime.now().year, DateTime.now().month, 1)));
                  },
                ),
                FlatButton(
                  child: Text("Submit"),
                  onPressed: () => {
                    SQLiteDbProvider.db.insertNewManager(double.parse(controller.value.text), DateFormat.yM().format(new DateTime(DateTime.now().year, DateTime.now().month, 1))).then((mgr) => {
                      MyHomePage.manager = mgr,
                      Navigator.of(context).pop()
                    })
                  }),
              ],
            ),
          ),
        );
      }
    );
  }




  ExpenseFilterDialog() {
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
          if(filterByGroup) _listGroupDowndown(),
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

  _listGroupDowndown() {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: mediumDarkGreyColor,
      ),
      child: DropdownButtonHideUnderline(
        child: FutureBuilder<List<ExpenseGroup>>(
          future: SQLiteDbProvider.db.getAllGroups(),
          builder: (context, snapshot) => _groupDrowdownBuilder(context, snapshot),
        ),
      ),
    );
  }

  _groupDrowdownBuilder(context, snapshot) {
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

        setState(() {
          MyHomePage.filterSetting = filterSetting;
        });
        Navigator.of(context).pop();
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
