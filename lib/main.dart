import 'package:financetracker/CreateManager.dart';
import 'package:financetracker/Database.dart';
import 'package:financetracker/Manager.dart';
import 'package:financetracker/Overview.dart';
import 'package:flutter/material.dart';

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

    SQLiteDbProvider.db.getOverviewDetails().then((mgr) => {
      if(mgr == null) {
        // Create pop-up to instantiate new manager
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateManager()))
        //CreateManagerAlert(context)
      }
      else {
        //There already exists a manager for this month. Retrieve data
        MyHomePage.manager = mgr
      }
    });

    return SafeArea(
      child: Scaffold(
        //backgroundColor: Colors.black87,
        body: Column(
          children: <Widget>[
            Overview(),
            SizedBox(height: 30,),
            Container(
              child: Text("Test"),
            )
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
                    MyHomePage.manager = await SQLiteDbProvider.db.insertNewManager(double.parse(value), new DateTime(DateTime.now().year, DateTime.now().month, 1));
                  },
                ),
                FlatButton(
                  child: Text("Submit"),
                  onPressed: () => {
                    SQLiteDbProvider.db.insertNewManager(double.parse(controller.value.text), new DateTime(DateTime.now().year, DateTime.now().month, 1)).then((mgr) => {
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
