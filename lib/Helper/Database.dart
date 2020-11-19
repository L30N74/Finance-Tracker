import 'dart:async';
import 'dart:io';
import 'package:financetracker/Classes/Expense.dart';
import 'package:financetracker/Classes/ExpenseGroup.dart';
import 'package:financetracker/Classes/Manager.dart';
import 'package:flutter/material.dart';
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
          await db.execute("DROP TABLE IF EXISTS Manager;");
          await db.execute("DROP TABLE IF EXISTS Expenses;");

          await db.execute("CREATE TABLE Manager("
              "starting_money TEXT,"
              "spent_money TEXT DEFAULT 0.0,"
              "remaining_money TEXT,"
              "month TEXT"
            ");"
          );

          await db.execute("CREATE TABLE Expenses("
              "name TEXT,"
              "date INTEGER,"
              "place TEXT,"
              "amount NUMBER,"
              "type TEXT,"
              "isMonthly NUMBER,"
              "group INTEGER,"
              "FOREIGN KEY(group) REFERENCES Expensegroup(ROWID)"
            ");"
          );

          await db.execute("CREATE TABLE Expensegroup("
              "name TEXT,"
              "color TEXT"
            ");"
          );
        }
    );
  }

  resetManagerTable() async {
    final db = await database;

    await db.delete("Manager");
  }

  resetExpensesTable() async {
    final db = await database;

    await db.delete("Expenses");
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

  Future<List<Expense>> getExpenses(DateTime date) async {
    final db = await database;

    int beginningDate = (new DateTime(date.year, date.month, 1)).millisecondsSinceEpoch;
    int endDate = (new DateTime(date.year, date.month+1, 0)).millisecondsSinceEpoch;

    var result = await db.query("Expenses", where: "date BETWEEN ? AND ? ORDER BY date DESC", whereArgs: [beginningDate, endDate]);

    List<Expense> expenses = new List<Expense>();

    var iterator = result.iterator;

    while (iterator.moveNext()) {
      expenses.add(Expense.fromMap(iterator.current));
    }

    return expenses;
  }

  insertNexGroup(ExpenseGroup group) async {
    var db = await database;
    await db.insert("Expensegroup", group.toMap());

    print("--------------- Inserted new group with name ${group.name} and color ${group.color}");
  }
}