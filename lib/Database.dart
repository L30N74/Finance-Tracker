import 'dart:async';
import 'dart:io';
import 'package:financetracker/Manager.dart';
import 'package:flutter/material.dart';
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

  Future<Manager> getOverviewDetails() async {
    final db = await database;
    var result = await db.query("Manager"); //, where: "month = ?", whereArgs: [new DateTime(DateTime.now().month, DateTime.now().year)]);
    return result.isNotEmpty ? Manager.fromMap(result.first) : null;
  }

  Future<int> getNextManagerID() async {
    final db = await database;
    var result = await db.rawQuery("SELECT COUNT(id) FROM Manager;");
    return result.first.values.first;
  }

  /// Inserts a new Manager into the database
  ///
  /// Returns [Manager] with appropriate id in database
  Future<Manager> insertNewManager(double startingMoney, DateTime month) async {
    print("------------ Starting insert into database");
    final db = await database;
    int id = await db.rawInsert(
      'INSERT INTO Manager(starting_money, remaining_money, month) VALUES(?, ?, ?);',
        [startingMoney.toString(),
        startingMoney.toString(),
        month.toIso8601String()]);

    print("-------------- Inserted new Manager with the id [$id], starting money of $startingMoney€ and in the month of $month");

    return new Manager(id, startingMoney, 0, startingMoney, month);
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "Expenses.db");

    return await openDatabase(
        path,
        version: 1,
        onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute("DROP TABLE IF EXISTS Expenses;");
          await db.execute("DROP TABLE IF EXISTS Manager;");

          await db.execute(
              "CREATE TABLE Expenses("
                "id INTEGER PRIMARY KEY,"
                "name TEXT,"
                "date DATE,"
                "place TEXT,"
                "amount NUMBER,"
                "type TEXT,"
                "isMonthly NUMBER"
              ");"
          );

          await db.execute("CREATE TABLE Manager("
              "id INTEGER PRIMARY KEY,"
              "starting_money NUMBER,"
              "spent_money NUMBER DEFAULT 0.0,"
              "remaining_money NUMBER,"
              "month TEXT"
              ");"
          );
        }
    );
  }
}