import 'dart:async';
import 'dart:io';
import 'package:financetracker/Classes/Expense.dart';
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
              "id INTEGER PRIMARY KEY,"
              "starting_money TEXT,"
              "spent_money TEXT DEFAULT 0.0,"
              "remaining_money TEXT,"
              "month TEXT"
            ");"
          );

          await db.execute("CREATE TABLE Expenses("
              "id INTEGER PRIMARY KEY,"
              "name TEXT,"
              "date DATE,"
              "place TEXT,"
              "amount NUMBER,"
              "type TEXT,"
              "isMonthly NUMBER"
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

  Future<Manager> getManager() async {
    final db = await database;
    var result = await db.query("Manager"); //, where: "month = ?", whereArgs: [new DateTime(DateTime.now().month, DateTime.now().year)]);
    return result.isNotEmpty ? Manager.fromMap(result.first) : null;
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
    int id = await db.rawInsert(
        'INSERT INTO Manager(starting_money, remaining_money, month) VALUES(?, ?, ?);',
        [ startingMoney.toString(),
          startingMoney.toString(),
          month
        ]);

    return new Manager(id, startingMoney, 0, startingMoney, month);
  }


  insertNewExpense(Expense expense) async {
    final db = await database;
    var result = await db.insert("Expenses", expense.toMap());
    print("Added new expense with id [$result] to the database");
  }

  Future<List<Expense>> getExpenses(DateTime month) async {
    final db = await database;
    //var result = await db.rawQuery("SELECT * FROM Expenses WHERE month BETWEEN ? AND ?", [('now','start of month','+1 month','-1 day')]);
  }
}