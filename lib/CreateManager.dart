import 'package:financetracker/Database.dart';
import 'package:financetracker/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateManager extends StatelessWidget {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("How much money is at your disposal this month?", style: TextStyle(), textAlign: TextAlign.center,),
            Container(
              width: 200,
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "800.99",
                  suffix: Text("€"),
                ),
                controller: controller,
                keyboardType: TextInputType.number,
              ),
            ),
            //Text("€", style: TextStyle(fontSize: 22),),
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text("Submit"),
              onPressed: () => {
                SQLiteDbProvider.db.insertNewManager(double.parse(controller.value.text), DateFormat.yM().format(new DateTime(DateTime.now().year, DateTime.now().month, 1))).then((mgr) => {
                  MyHomePage.manager = mgr,
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyHomePage()))
                })
              }
            ),
          ],
        ),
      ),
    );
  }
}
