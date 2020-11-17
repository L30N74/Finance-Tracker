import 'package:financetracker/main.dart';
import 'package:flutter/material.dart';

class Overview extends StatefulWidget {
  @override
  _OverviewState createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      margin: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width-20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Colors.white,

      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text(
                  "You started with:",
              ),
              Text(
                MyHomePage.manager != null ?  MyHomePage.manager.startingMoney.toStringAsFixed(2) + " €" : "",
                style: TextStyle(
                  fontSize: 22
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text("Spent:"),
                  Text(
                    MyHomePage.manager != null ? MyHomePage.manager.spentMoney.toStringAsFixed(2) + " €" : "",
                    style: TextStyle(
                      fontSize: 26
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text("Remaining:"),
                  Text(
                    MyHomePage.manager != null ? MyHomePage.manager.remainingMoney.toStringAsFixed(2) + " €" : "",
                    style: TextStyle(
                      fontSize: 26
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
