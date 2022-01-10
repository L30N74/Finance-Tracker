import 'package:financetracker/Classes/Constants.dart';
import 'package:financetracker/Classes/Expense.dart';
import 'package:financetracker/CreateExpense.dart';
import 'package:financetracker/Classes/Manager.dart';
import 'package:financetracker/GraphView.dart';
import 'package:financetracker/Helper/Database.dart';
import 'package:financetracker/Helper/DialogHelper.dart';
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
  static FilterSetting filterSetting =
      new FilterSetting(filterType: FilterType.Date, isAscending: false);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool redirected = false;
  bool loading = true;

  @override
  Widget build(BuildContext context) {
    if(MyHomePage.manager != null) {
      return mainPage();
    }

    return FutureBuilder<Manager>(
      future: SQLiteDbProvider.db.getCurrentManager(),
      builder: (ctx, snapshot) {
        if(!snapshot.hasData) return waitingIndicator();
        if(snapshot.hasError) return errorIndicator(snapshot.error);

        MyHomePage.manager = snapshot.data;
        return mainPage();
      },
    );
  }

  Widget errorIndicator(error) {
    return Container(
      child: Text(
        "Error retrieveing manager. \n${error.toString()}\nPlease restart",
        style: errorTextStyle,
      ),
    );
  }
  Widget waitingIndicator() {
    return Container(
      height: 30,
      width: MediaQuery.of(context).size.width/2,
      alignment: Alignment.center,
      child: LinearProgressIndicator(),
    );
  }

  Widget mainPage() {
    return SafeArea(
      child: Scaffold(
        backgroundColor: mainPageBackgroundColor,
        body: Column(
          children: <Widget>[
            Overview(),
            filterRow(),
            showExpenses(),
          ],
        ),
        bottomNavigationBar: myBottomBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          width: 60,
          height: 60,
          child: myFloatingActionButton(),
        ),
      ),
    );
  }

  Widget myFloatingActionButton() {
    return Container(
      width: 200,
      height: 40,
      child: OutlineButton(
        color: Colors.blue,
        borderSide: BorderSide(
          width: 2,
          color: lightGreyColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => CreateExpense())),
        child: Text(
          "+",
          style: TextStyle(
            fontSize: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget filterRow() {
    return Container(
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
          Container(
            margin: EdgeInsets.only(
              right: 20,
            ),
            child: IconButton(
              icon: Icon(
                Icons.filter_list,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                //OpenFilterDialog();
                DialogHelper.showFilterDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget showExpenses() {
    return FutureBuilder(
      future: SQLiteDbProvider.db.getExpenses(DateTime.now()),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0)
            return Container(
              child: Text(
                "No expenses yet or none found with the given filter.\nCreate an expense below or change filter-settings",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            );

          return _expenseListBuilder(snapshot.data);
        } else if (snapshot.hasError) {
          return Column(
            children: [
              Text(
                "Error while retrieving data:\n [${snapshot.error}]",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              SizedBox(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.green,
                ),
                width: 60,
                height: 60,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'Loading...',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          );
        }
      },
    );
  }

  _expenseListBuilder(list) {
    return Expanded(
      child: ListView.builder(
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            Expense expense = list[index];
            return Dismissible(
              key: Key(expense.name),
              child: createExpenseItem(expense),
              onDismissed: (direction) {
                setState(() {
                  // Remove expense from database
                  list.remove(expense);
                  MyHomePage.manager.reverseExpense(expense);
                  Scaffold.of(context).showSnackBar(new SnackBar(
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        setState(() {
                          MyHomePage.manager.handleExpense(expense);
                        });
                      },
                    ),
                    content: Text("${expense.name} removed"),
                  ));
                });
              },
              background: Container(
                color: Colors.red,
                child: Icon(Icons.delete, color: Colors.black, size: 30),
              ),
            );
          }
      )  //createExpenseItem(list[index], list)),
    );
  }

  Widget createExpenseItem(expense) {
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
          ]),
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
                  color: expense.group
                      .getColor(),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: Text(
                  expense.getDateAsString(),
                  style: TextStyle(),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
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
                    (expense.type == ExpenseType.Expense ? "-" : "+") +
                        expense.amount.toStringAsFixed(2) +
                        "€",
                    style: TextStyle(
                      fontSize: 24,
                      color: expense.type == ExpenseType.Expense
                          ? Color.fromRGBO(200, 10, 30, 1)
                          : Colors.green, //Color.fromRGBO(10, 150, 30, 1),
                    ),
                  )),
            ],
          ),
          SizedBox(
            height: 10,
          ),
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
              SizedBox(
                width: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget myBottomBar() {
    return BottomAppBar(
      color: Colors.white, //Color(0xFF216128),
      shape: CircularNotchedRectangle(),
      child: Container(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            graphRedirectButton(),
            MaterialButton(
              child: Text("Reset all"),
              onPressed: () {
                setState(() {
                  SQLiteDbProvider.db.resetEverything();
                  MyHomePage.manager = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget graphRedirectButton() {
    return Container(
      width: MediaQuery.of(context).size.width / 3.5,
      child: OutlineButton(
        color: Colors.blue,
        borderSide: BorderSide(
          width: 2,
          color: lightGreyColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => GraphView())),
        child: Text(
          "View graph",
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Future createManagerAlert(BuildContext context) {
    TextEditingController controller = TextEditingController();
    redirected = true;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Monthly Setup"),
          content: Container(
            height: 200,
            child: Column(
              children: [
                Text("Allowance this month?"),
                SizedBox(
                  height: 50,
                ),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  onSubmitted: (String value) async {
                    MyHomePage.manager =
                        await SQLiteDbProvider.db.insertNewManager(
                      double.parse(value),
                      DateFormat.yM().format(
                        new DateTime(
                            DateTime.now().year, DateTime.now().month, 1),
                      ),
                    );
                  },
                ),
                FlatButton(
                  child: Text("Submit"),
                  onPressed: () => {
                    SQLiteDbProvider.db
                        .insertNewManager(
                          double.parse(controller.value.text),
                          DateFormat.yM().format(
                            new DateTime(
                                DateTime.now().year, DateTime.now().month, 1),
                          ),
                        )
                        .then(
                          (mgr) => {
                            setState(() => {
                              MyHomePage.manager = mgr,
                              redirected = false,
                              loading = false,
                              Navigator.of(context).pop()

                            }),
                          },
                        ),
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
