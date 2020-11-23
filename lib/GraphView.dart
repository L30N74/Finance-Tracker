import 'package:financetracker/Classes/Manager.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class GraphView extends StatelessWidget {
  List<Manager> data;

  GraphView({@required this.data});

  @override
  Widget build(BuildContext context) {

    List<charts.Series<Manager, String>> series = [
      charts.Series(
        id: "Starting",
        data: data,
        domainFn: (Manager manager, _) => manager.month,
        measureFn: (Manager manager, _) => manager.startingMoney,
      ),
      charts.Series(
        id: "Spent",
        data: data,
        domainFn: (Manager manager, _) => manager.month,
        measureFn: (Manager manager, _) => manager.spentMoney,
      ),
      charts.Series(
        id: "Saved",
        data: data,
        domainFn: (Manager manager, _) => manager.month,
        measureFn: (Manager manager, _) => manager.remainingMoney,
      )
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(),
        GraphContainer(series),
        Container(),
      ],
    );

  }

  Widget GraphContainer(series) {
    return Container(
      height: 400,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text("Test with starting money"),
              Expanded(
                child: charts.BarChart(
                  series,
                  animate: true,
                  barGroupingType: charts.BarGroupingType.groupedStacked,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}
