import 'package:financetracker/Classes/Constants.dart';
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
      height: 160,
      //margin: EdgeInsets.only(left: 20, right: 20),
      padding: EdgeInsets.only(left: 2, right: 2, bottom: 2),
      width: MediaQuery.of(context).size.width-18,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
        color: lightGreyColor,

      ),
      child: Container(
        height: 150,
        //margin: EdgeInsets.only(left: 20, right: 20),
        width: MediaQuery.of(context).size.width-20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
          color: mediumDarkGreyColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                    "You started with:",
                  style: basicStyle,
                ),
                Text(
                  MyHomePage.manager != null ?  MyHomePage.manager.startingMoney.toStringAsFixed(2) + " €" : "",
                  style: basicStyle,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text("Spent:", style: basicStyle,),
                    Text(
                      MyHomePage.manager != null ? MyHomePage.manager.spentMoney.toStringAsFixed(2) + " €" : "",
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text("Remaining:", style: basicStyle,),
                    Text(
                      MyHomePage.manager != null ? MyHomePage.manager.remainingMoney.toStringAsFixed(2) + " €" : "",
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
