import 'dart:async';
import 'dart:io';
import 'package:financetracker/Classes/Expense.dart';
import 'package:financetracker/Classes/ExpenseGroup.dart';
import 'package:financetracker/Classes/FilterSetting.dart';
import 'package:financetracker/Classes/Manager.dart';
import 'package:financetracker/main.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteDbProvider {
  SQLiteDbProvider._();
  SQLiteDbProvider.ensureInitialised();

  static final SQLiteDbProvider db = SQLiteDbProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "finances.db");

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.transaction(
          (txn) => txn.execute("CREATE TABLE Manager("
              "starting_money TEXT,"
              "spent_money TEXT DEFAULT 0.0,"
              "remaining_money TEXT,"
              "month TEXT"
              ");"),
        );

        print("Manager table initialized.");

        await db.transaction(
          (txn) => txn.execute("CREATE TABLE Expensegroup("
              "ROWID INTEGER PRIMARY KEY AUTOINCREMENT,"
              "groupName TEXT,"
              "color TEXT"
              ");"),
        );

        //Set up default groups
        /*defaultExpenseGroups.forEach((element) async {
          await insertNewGroup(element);
        });*/

        print("Expensegroup table initialized.");

        await db.transaction(
          (txn) => txn.execute("CREATE TABLE Expenses("
              "name TEXT,"
              "date INTEGER,"
              "place TEXT,"
              "amount NUMBER,"
              "type TEXT,"
              "isMonthly NUMBER,"
              "groupId NUMBER,"
              "FOREIGN KEY(groupId) REFERENCES Expensegroup(ROWID)"
              ");"),
        );

        print("Expenses table initialized.");
      },
    );
  }

  Future<void> resetManagerTable() async {
    final db = await database;
    await db.transaction((txn) => txn.delete("Manager"));
    print("INFO [Manager reset]");
  }

  Future<void> resetExpensesTable() async {
    final db = await database;
    await db.transaction((txn) => txn.delete("Expenses"));
    print("INFO [Expenses reset]");
  }

  Future<void> resetGroupsTable() async {
    final db = await database;
    await db.transaction((txn) => txn.delete("Expensegroup"));
    //where: "ROWID > ?", whereArgs: [defaultExpenseGroups.length]);
    print("INFO [Groups reset]");
  }

  resetEverything() async {
    await resetManagerTable();
    await resetExpensesTable();
    await resetGroupsTable();
  }

  ///Retrieves the manager for this month
  ///
  /// Returns a [Manager] if there is one for this month, otherwise [null] if there isn't
  Future<Manager> getCurrentManager() async {
    final db = await database;

    //Get the date the manager should be assigned to if he exists
    DateTime now = DateTime.now();
    String beginningDate =
        DateFormat.yM().format(new DateTime(now.year, now.month, 1));

    //Retrieve manager of this month
    var result = await db
        .query("Manager", where: "month = ?", whereArgs: [beginningDate]);

    return result.isNotEmpty ? Manager.fromMap(result.first) : null;
  }

  Future<List<Manager>> getAllManagers() async {
    final db = await database;
    List<Manager> managerList = new List<Manager>();

    var result = await db.query("Manager");
    var iterator = result.iterator;

    while (iterator.moveNext()) {
      managerList.add(Manager.fromMap(iterator.current));
    }

    return managerList;
  }

  Future<void> updateManager(Manager manager) async {
    final db = await database;
    await db.transaction((txn) => txn.update("Manager", manager.toMap()));
  }

  /// Inserts a new Manager into the database
  ///
  /// Returns [Manager] with appropriate id in database
  Future<Manager> insertNewManager(double startingMoney, String month) async {
    final db = await database;
    await db.transaction((txn) => txn.rawInsert(
        'INSERT INTO Manager(starting_money, remaining_money, month) VALUES(?, ?, ?);',
        [startingMoney.toString(), startingMoney.toString(), month]));

    return new Manager(
      startingMoney: startingMoney,
      spentMoney: 0,
      remainingMoney: startingMoney,
      month: month,
    );
  }

  Future<void> insertNewExpense(Expense expense) async {
    final db = await database;
    await db.transaction((txn) => txn.insert("Expenses", expense.toMap()));
  }

  /// Retrieves all expenses during the in [date] specified month
  ///
  /// Also determines with the Filter in [MyHomePage] which expenses to show.
  /// Default is filtered by month with the date descending (most recent expense on top of the list)
  Future<List<Expense>> getExpenses(DateTime date) async {
    final db = await database;

    int beginningDate =
        (new DateTime(date.year, date.month, 1)).millisecondsSinceEpoch;
    int endDate =
        (new DateTime(date.year, date.month + 1, 0)).millisecondsSinceEpoch;
    FilterSetting filter = MyHomePage.filterSetting;
    String filterType = filter.filterType.toString().split(".")[1];
    String orderAscDesc = filter.isAscending ? "ASC" : "DESC";

    var query = "";
    //Every expense
    switch (filter.filterType) {
      case FilterType.Expense:
      case FilterType.Income:
        //Select only income or expenses but not both
        query =
            "SELECT * from Expenses e JOIN Expensegroup g ON e.groupId = g.ROWID AND e.type = '$filterType' AND e.date BETWEEN $beginningDate AND $endDate ORDER BY e.date $orderAscDesc";
        break;
      case FilterType.Group:
        //Select groups
        query =
            "SELECT * from Expenses e JOIN Expensegroup g ON e.groupId = g.ROWID AND e.groupId = ${filter.group.id} AND e.date BETWEEN $beginningDate AND $endDate ORDER BY e.date DESC";
        break;
      case FilterType.Date:
      default:
        query =
            "SELECT * from Expenses e JOIN Expensegroup g ON e.groupId = g.ROWID AND e.date BETWEEN $beginningDate AND $endDate ORDER BY e.date $orderAscDesc";
        break;
    }

    var result = await db.rawQuery(query);
    List<Expense> expenses = new List<Expense>();

    var iterator = result.iterator;
    while (iterator.moveNext()) expenses.add(Expense.fromMap(iterator.current));

    return expenses;
  }

  Future<Map<ExpenseGroup, double>> getExpensesFromGroups(
      Manager manager) async {
    final db = await database;
    Map<ExpenseGroup, double> expensesMap = new Map();

    var dateSplits = manager.month.split("/");
    int month = int.parse(dateSplits[0]);
    int year = int.parse(dateSplits[1]);

    int beginningDate = (new DateTime(year, month, 1)).millisecondsSinceEpoch;
    int endDate = (new DateTime(year, month + 1, 0)).millisecondsSinceEpoch;

    // Retrieve all groups
    var groups = await db.query("Expensegroup");
    var groupIterator = groups.iterator;

    while (groupIterator.moveNext()) {
      var group = ExpenseGroup.fromMap(groupIterator.current);

      // Get all expenses by those groups
      // Add up the expenses
      String query =
          "SELECT sum(e.amount) FROM Expenses e JOIN ExpenseGroup g " +
              "ON e.groupId = g.ROWID AND g.groupName = ? AND " +
              "e.date BETWEEN ? AND ?;";

      var result =
          await db.rawQuery(query, [group.name, beginningDate, endDate]);

      //Value is in a cursor. Retrieve and parse to double
      var resultIterator = result.iterator;
      resultIterator.moveNext();
      double parseAmount =
          double.tryParse(resultIterator.current.values.first.toString());

      // If there are no expenses in a group, null is returned from tryparse.
      // Get rid of that so there is always a double
      double amount = parseAmount != null ? parseAmount : 0.0;

      // Put the total into the map
      if (amount != null) expensesMap[group] = amount;
    }

    return expensesMap;
  }

  insertNewGroup(ExpenseGroup group) async {
    var db = await database;
    return await db.transaction((txn) => txn.rawInsert(
        "INSERT INTO Expensegroup(groupName, color) VALUES(?, ?);",
        [group.name, group.color]));
  }

  Future<ExpenseGroup> getGroupById(ExpenseGroup group) async {
    var db = await database;
    var result = await db
        .query("Expensegroup", where: "ROWID = ?;", whereArgs: [group.id]);

    if (result.isNotEmpty)
      return ExpenseGroup.fromMap(result.first);
    else
      throw Exception("No Group by the name of '${group.name}'");
  }

  Future<List<ExpenseGroup>> getAllGroups() async {
    var db = await database;
    List<ExpenseGroup> groups = new List<ExpenseGroup>();

    var result = await db.query("Expensegroup");

    var iterator = result.iterator;
    while (iterator.moveNext()) {
      groups.add(ExpenseGroup.fromMap(iterator.current));
    }

    return groups;
  }
}
