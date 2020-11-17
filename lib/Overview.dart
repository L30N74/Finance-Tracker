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
        children: [
          Text(
            "Monthly Income:",
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Spent",
              ),
              Text(
                "Remaining",
              ),
            ],
          )
        ],
      ),
    );
  }
}
