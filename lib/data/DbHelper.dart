import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DbHelper {
  var _db;

  Future<Database> get db async {
    if (_db == null) {
      _db = await initializeDb();
    }

    return _db;
  }

  Future<Database> initializeDb() async {
    if(Platform.isWindows){
      sqfliteFfiInit();
      var databaseFactory = databaseFactoryFfi;
      return await databaseFactory.openDatabase("/hesabim.db",options: OpenDatabaseOptions(onCreate: createDb,version: 1));
    }

    String dbPath = join(await getDatabasesPath(), "hesabim.db");
    var hesabimDb = await openDatabase(dbPath, version: 1, onCreate: createDb);
    return hesabimDb;
  }

  void createDb(Database db, int version) async {
    //await db.execute(
    //"Create table if not exists accounts(id integer primary key, name text, money_type_id integer, amount double)");
    await db.execute(
        "Create table if not exists money_types (id integer primary key, name text)");
    await db.execute(
        "Create table if not exists users (id integer primary key,name text, password text)");
    await db.execute(
        "Create table if not exists categories (id integer primary key, user_id integer, name text, type text)");
    await db.execute(
        "Create Table If Not Exists incomes (id integer primary key, category_id integer, user_id integer, money_type_id integer, name text, amount integer,date text,status int)");
    await db.execute(
        "create table if not exists expenses (id integer primary key, category_id integer, user_id integer, money_type_id integer, name text, amount integer, date text,status int)");
    await db.execute("create table if not exists current_user (id integer primary key, user_id integer)");
  }
}
