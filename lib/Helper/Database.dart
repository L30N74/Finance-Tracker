import 'dart:async';
import 'dart:io';
import 'package:financetracker/Classes/Constants.dart';
import 'package:financetracker/Classes/Expense.dart';
import 'package:financetracker/Classes/ExpenseGroup.dart';
import 'package:financetracker/Classes/FilterSetting.dart';
import 'package:financetracker/Classes/Manager.dart';
import 'package:financetracker/main.dart';
import 'package:financetracker/Classes/FilterSetting.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteDbProvider {
  SQLiteDbProvider._();

  static final SQLiteDbProvider db = SQLiteDbProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null)
      return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "Expenses.db");

    return await openDatabase(
        path,
        version: 1,
        onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await setUpTables();
        }
    );
  }

  setUpTables() async {
    var db = await database;
    await db.execute("DROP TABLE IF EXISTS Manager;");
    await db.execute("DROP TABLE IF EXISTS Expensegroup;");
    await db.execute("DROP TABLE IF EXISTS Expenses;");


    await db.execute("CREATE TABLE Manager("
        "starting_money TEXT,"
        "spent_money TEXT DEFAULT 0.0,"
        "remaining_money TEXT,"
        "month TEXT"
        ");"
    );

    print("Manager table initialized.");

    await db.execute("CREATE TABLE Expensegroup("
        "ROWID INTEGER PRIMARY KEY AUTOINCREMENT,"
        "groupName TEXT,"
        "color TEXT"
        ");"
    );

    //Set up default groups
    defaultExpenseGroups.forEach((element) async {
      await insertNewGroup(element);
    });

    print("Expensegroup table initialized.");

    await db.execute("CREATE TABLE Expenses("
        "name TEXT,"
        "date INTEGER,"
        "place TEXT,"
        "amount NUMBER,"
        "type TEXT,"
        "isMonthly NUMBER,"
        "groupId NUMBER,"
        "FOREIGN KEY(groupId) REFERENCES Expensegroup(ROWID)"
        ");"
    );

    print("Expenses table initialized.");
  }

  resetManagerTable() async {
    final db = await database;
    await db.delete("Manager");
    print("INFO [Manager reset]");
  }

  resetExpensesTable() async {
    final db = await database;
    await db.delete("Expenses");
    print("INFO [Expenses reset]");
  }

  resetGroupsTable() async {
    final db = await database;
    await db.delete("Expensegroup", where: "ROWID > ?", whereArgs: [defaultExpenseGroups.length]);
    print("INFO [Groups reset]");
  }

  ///Retrieves the manager for this month
  ///
  /// Returns a [Manager] if there is one for this month, otherwise [null] if there isn't
  Future<Manager> getCurrentManager() async {
    final db = await database;

    //Get the date the manager should be assigned to if he exists
    DateTime now = DateTime.now();
    String beginningDate = DateFormat.yM().format(new DateTime(now.year, now.month, 1));

    //Retrieve manager of this month
    var result = await db.query("Manager", where: "month = ?", whereArgs: [beginningDate]);

    return result.isNotEmpty ? Manager.fromMap(result.first) : null;
  }

  Future<List<Manager>> getAllManagers() async {
    final db = await database;
    List<Manager> managerList = new List<Manager>();

    var result = await db.query("Manager");

    while(result.iterator.moveNext())
      managerList.add(Manager.fromMap(result.iterator.current));

    return managerList;
  }

  updateManager(Manager manager) async {
    final db = await database;
    db.update("Manager", manager.toMap());
  }

  /// Inserts a new Manager into the database
  ///
  /// Returns [Manager] with appropriate id in database
  Future<Manager> insertNewManager(double startingMoney, String month) async {
    final db = await database;
    await db.rawInsert(
      'INSERT INTO Manager(starting_money, remaining_money, month) VALUES(?, ?, ?);',
      [ startingMoney.toString(),
        startingMoney.toString(),
        month
      ]);

    return new Manager(startingMoney, 0, startingMoney, month);
  }

  insertNewExpense(Expense expense) async {
    final db = await database;
    await db.insert("Expenses", expense.toMap());
  }

  /// Retrieves all expenses during the in [date] specified month
  ///
  /// Also determines with the Filter in [MyHomePage] which expenses to show.
  /// Default is filtered by month with the date descending (most recent expense on top of the list)
  Future<List<Expense>> getExpenses(DateTime date) async {
    final db = await database;

    int beginningDate = (new DateTime(date.year, date.month, 1)).millisecondsSinceEpoch;
    int endDate = (new DateTime(date.year, date.month+1, 0)).millisecondsSinceEpoch;
    FilterSetting filter = MyHomePage.filterSetting;
    String filterType = filter.filterType.toString().split(".")[1];
    String orderAscDesc = filter.isAscending ? "ASC" : "DESC";


    var query = "";
    //Every expense
    switch(filter.filterType){
      case FilterType.Expense:
      case FilterType.Income:
        //Select only income or expenses but not both
        query = "SELECT * from Expenses e JOIN Expensegroup g ON e.groupId = g.ROWID AND e.type = '$filterType' AND e.date BETWEEN $beginningDate AND $endDate ORDER BY e.date $orderAscDesc";
        break;
      case FilterType.Group:
        //Select groups
        query = "SELECT * from Expenses e JOIN Expensegroup g ON e.groupId = g.ROWID AND e.groupId = ${filter.group.id} AND e.date BETWEEN $beginningDate AND $endDate ORDER BY e.date DESC";
        break;
      case FilterType.Date:
      default:
        query = "SELECT * from Expenses e JOIN Expensegroup g ON e.groupId = g.ROWID AND e.date BETWEEN $beginningDate AND $endDate ORDER BY e.date $orderAscDesc";
        break;
    }

    var result = await db.rawQuery(query);
    List<Expense> expenses = new List<Expense>();

    var iterator = result.iterator;
    while (iterator.moveNext()) expenses.add(Expense.fromMap(iterator.current));

    return expenses;
  }

  insertNewGroup(ExpenseGroup group) async {
    var db = await database;
    return await db.rawInsert("INSERT INTO Expensegroup(groupName, color) VALUES(?, ?);", [group.name, group.color]);
  }

  Future<ExpenseGroup> getGroupById(ExpenseGroup group) async {
    var db = await database;
    var result = await db.query("Expensegroup", where: "ROWID = ?;", whereArgs: [group.id]);

    if (result.isNotEmpty)
      return ExpenseGroup.fromMap(result.first);
    else
      throw Exception("No Group by the name of '${group.name}'");
  }

  Future<List<ExpenseGroup>> getAllGroups() async {
    var db = await database;
    List<ExpenseGroup> groups = new  List<ExpenseGroup>();

    var result = await db.query("Expensegroup");

    var iterator = result.iterator;
    while(iterator.moveNext()) {
      groups.add(ExpenseGroup.fromMap(iterator.current));
    }

    return groups;
  }
}