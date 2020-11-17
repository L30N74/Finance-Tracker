import 'package:financetracker/Database.dart';
import 'package:financetracker/main.dart';
import 'package:flutter/material.dart';

class CreateManager extends StatelessWidget {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(fillColor: Colors.white,),
              controller: controller,
              keyboardType: TextInputType.number,
              onSubmitted: (String value) async {
                MyHomePage.manager = await SQLiteDbProvider.db.insertNewManager(double.parse(value), new DateTime(DateTime.now().year, DateTime.now().month, 1));
              },
            ),
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
                child: Text("Submit"),
                onPressed: () => {
                  SQLiteDbProvider.db.insertNewManager(double.parse(controller.value.text), new DateTime(DateTime.now().year, DateTime.now().month, 1)).then((mgr) => {
                    MyHomePage.manager = mgr,
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyHomePage()))
                  })
                }),
          ],
        ),
      ),
    );
  }
}
