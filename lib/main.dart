import 'package:financetracker/Classes/Constants.dart';
import 'package:financetracker/Classes/Expense.dart';
import 'package:financetracker/CreateExpense.dart';
import 'package:financetracker/CreateManager.dart';
import 'package:financetracker/Classes/Manager.dart';
import 'package:financetracker/Helper/Database.dart';
import 'package:financetracker/Helper/Overview.dart';
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

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    SQLiteDbProvider.db.getCurrentManager().then((mgr) => {
      if(mgr == null) {
        // Redirect user to page to create a new manager
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateManager()))
      }
      else {
        //There already exists a manager for this month. Retrieve data
        MyHomePage.manager = mgr
      }
    });

    return SafeArea(
      child: Scaffold(
        backgroundColor: mainPageBackgroundColor,
        body: Column(
          children: <Widget>[
            Overview(),
            SizedBox(height: 30,),
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
        padding: const EdgeInsets.only(top: 20, bottom: 100),
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
                  color: expense.type == ExpenseType.Expense ? Color.fromRGBO(200, 10, 30, 1) : Color.fromRGBO(10, 200, 30, 1),
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
                    (expense.type == ExpenseType.Expense ? "-" : "+") + expense.amount.toString() + "€",
                    style: TextStyle(fontSize: 24),
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
            SizedBox(width: 30,),
            MaterialButton(
              child: Text("Reset Expenses"),
              onPressed: () {
                setState(() {
                  SQLiteDbProvider.db.resetExpensesTable();
                  MyHomePage.manager.spentMoney = 0;
                  MyHomePage.manager.remainingMoney = MyHomePage.manager.startingMoney;
                  SQLiteDbProvider.db.updateManager(MyHomePage.manager);
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
}
