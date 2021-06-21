import 'package:financetracker/Helper/Database.dart';
import 'package:financetracker/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateManager extends StatelessWidget {
  final TextEditingController controller = TextEditingController();
  final DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "How much money is at your disposal this month?",
              style: TextStyle(),
              textAlign: TextAlign.center,
            ),
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
                keyboardAppearance: Brightness.dark,
              ),
            ),
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text("Submit"),
              onPressed: () => {
                SQLiteDbProvider.db
                    .insertNewManager(
                        double.parse(controller.value.text),
                        DateFormat.yM()
                            .format(new DateTime(now.year, now.month, 1)))
                    .then((mgr) => {
                          MyHomePage.manager = mgr,
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => MyHomePage())),
                        }),
              },
            ),
          ],
        ),
      ),
    );
  }
}
