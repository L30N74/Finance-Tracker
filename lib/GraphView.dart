import 'package:financetracker/Classes/Constants.dart';
import 'package:financetracker/Classes/ExpenseGroup.dart';
import 'package:financetracker/Classes/Manager.dart';
import 'package:financetracker/Helper/Database.dart';
import 'package:financetracker/main.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class GraphView extends StatefulWidget {
  @override
  _GraphViewState createState() => _GraphViewState();
}

String filterOptionsValue = "3 Months";
List<String> filterOptions = ["1 Month", "3 Months", "6 Months", "12 Months"];
charts.SelectionModel selectedEntry;

class _GraphViewState extends State<GraphView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: mainPageBackgroundColor,
        body: Column(
          children: [
            //Overview(),
            filterContainer(),
            graphContainer(),
            SizedBox(
              height: 10,
            ),
            detailsView(),
            Spacer(),
            returnButton(),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget filterContainer() {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 50),
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Show up to how many entries?",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.left,
          ),
          filterDropdown(),
        ],
      ),
    );
  }

  Widget filterDropdown() {
    return Container(
      height: 60,
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: mediumDarkGreyColor,
        ),
        child: DropdownButton(
          value: filterOptionsValue,
          items: filterOptions
              .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ))
              .toList(),
          onChanged: (String newValue) {
            setState(() {
              filterOptionsValue = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget graphContainer() {
    int numOfMonthsToShow = int.parse(filterOptionsValue.split(" ")[0]);

    return Container(
      height: 300,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                "Overview of the last $numOfMonthsToShow months",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Expanded(
                child: ClipRect(
                  child: FutureBuilder(
                    future: SQLiteDbProvider.db.getAllManagers(),
                    builder: (context, snapshot) =>
                        buildGraph(context, snapshot, numOfMonthsToShow),
                  ),
                ),
              ),
              legend(),
            ],
          ),
        ),
      ),
    );
  }

  buildGraph(context, snapshot, numOfMonthsToShow) {
    if (snapshot.hasError) return Container();

    if (snapshot.hasData)
      return charts.BarChart(
        buildSeries(snapshot.data),
        animate: true,
        //vertical: false,  //set to false for a horizontal graph
        barGroupingType: charts.BarGroupingType.grouped,
        behaviors: [
          new charts.SlidingViewport(),
          new charts.PanAndZoomBehavior(),
        ],
        selectionModels: [
          new charts.SelectionModelConfig(
            changedListener: (charts.SelectionModel model) {
              setState(() {
                selectedEntry = model;
              });
            },
          ),
        ],
        domainAxis: new charts.OrdinalAxisSpec(
          viewport: charts.OrdinalViewport("0", numOfMonthsToShow),
        ),
      );

    // Waiting for data to load
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
            'Rertrieving data...',
            style: TextStyle(color: Colors.black),
          ),
        )
      ],
    );
  }

  /// Builds the chartseries to display managers' information
  ///
  /// [data] is the list of managers
  buildSeries(data) {
    List<charts.Series<Manager, String>> series = [
      charts.Series(
        seriesColor: charts.ColorUtil.fromDartColor(mainPageBackgroundColor),
        id: "Starting",
        data: data,
        domainFn: (Manager manager, _) => manager.month,
        measureFn: (Manager manager, _) => manager.startingMoney,
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Colors.blue),
      ),
      //charts.ColorUtil.fromDartColor(Colors.blue).lighter),
      charts.Series(
          id: "Spent",
          data: data,
          domainFn: (Manager manager, _) => manager.month,
          measureFn: (Manager manager, _) => manager.spentMoney,
          colorFn: (Manager manager, _) =>
              charts.ColorUtil.fromDartColor(Colors.red)),
      charts.Series(
          id: "Saved",
          data: data,
          domainFn: (Manager manager, _) => manager.month,
          measureFn: (Manager manager, _) => manager.remainingMoney,
          colorFn: (Manager manager, _) =>
              charts.ColorUtil.fromDartColor(Colors.green)),
    ];
    return series;
  }

  Widget legend() {
    return Container(
      child: Row(
        children: [
          Container(
            width: 15,
            height: 15,
            color: Colors.blue,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Text(
              "Starting",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Container(
            width: 15,
            height: 15,
            color: Colors.red,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Text(
              "Spent",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Container(
            width: 15,
            height: 15,
            color: Colors.green,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Text(
              "Saved",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget detailsView() {
    if (selectedEntry == null) return Container();
    final Manager selectedManager = selectedEntry.selectedDatum.first.datum;

    return Container(
      height: 250,
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Column(
        children: [
          Text(
            "Money spent on in ${selectedManager.month}:",
            style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                decoration: TextDecoration.underline),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 15,
          ),
          groupExpenseOverview(selectedManager),
          SizedBox(
            height: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You started the month with ${selectedManager.startingMoney.toString()}€",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              Text(
                "Total expenses: ${selectedManager.spentMoney.toString()}€",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              Text(
                "Total saved: ${selectedManager.remainingMoney.toString()}€",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget groupExpenseOverview(Manager selectedManager) {
    return Expanded(
      child: FutureBuilder(
        future: SQLiteDbProvider.db.getExpensesFromGroups(selectedManager),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Container();
          if (snapshot.hasData) {
            Map<ExpenseGroup, double> expenses = snapshot.data;
            List<MapEntry<ExpenseGroup, double>> list =
                expenses.entries.toList();

            return ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                ExpenseGroup group = list[index].key;
                double spentAmount = list[index].value;

                return Container(
                  margin: EdgeInsets.only(
                    bottom: 15,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 20,
                        width: 50,
                        margin: EdgeInsets.only(right: 10),
                        color: group.getColor(),
                      ),
                      Text(
                        group.name,
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      Spacer(),
                      Text(
                        spentAmount.toString() + "€",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }

  Widget returnButton() {
    return OutlineButton(
      color: Colors.blue,
      borderSide: BorderSide(
        width: 2,
        color: lightGreyColor,
      ),
      //minWidth: MediaQuery.of(context).size.width / 1.3,
      //height: 60,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      onPressed: () {
        selectedEntry = null;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      },
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Text(
          "Back to Homepage",
          style: TextStyle(color: Colors.white, fontSize: 32),
        ),
      ),
    );
  }
}
