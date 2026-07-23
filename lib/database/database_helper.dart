import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';

class DatabaseHelper {
  Database? db;

  Future<void> createDatabase() async {
    if (db != null) {
      return;
    }

    String path = join(await getDatabasesPath(), 'finance_app.db');

    db = await openDatabase(
      path,
      // Bumped from 1 -> 2 because the `budgets` table was added after
      // `transactions` already existed on devices. Without a version bump,
      // onCreate never runs again on those devices and `budgets` never
      // gets created, causing "no such table: budgets" on insert.
      version: 2,
      onCreate: (Database database, int version) async {
        await database.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            amount REAL,
            type TEXT,
            category TEXT,
            date TEXT,
            note TEXT
          )
        ''');

        await database.execute('''
          CREATE TABLE budgets(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT,
            limitAmount REAL,
            month TEXT
          )
        ''');
      },
      onUpgrade: (Database database, int oldVersion, int newVersion) async {
        // Runs on existing installs that already have version 1
        // (transactions table only, no budgets table yet).
        if (oldVersion < 2) {
          await database.execute('''
            CREATE TABLE IF NOT EXISTS budgets(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              category TEXT,
              limitAmount REAL,
              month TEXT
            )
          ''');
        }
      },
    );
  }

  // ---------------- TRANSACTIONS ----------------

  Future<int> insertTransaction(TransactionModel transaction) async {
    await createDatabase();
    return await db!.insert('transactions', transaction.toMap());
  }

  Future<List<TransactionModel>> getTransactions() async {
    await createDatabase();

    List<Map<String, dynamic>> maps = await db!.query(
      'transactions',
      orderBy: 'id DESC',
    );

    List<TransactionModel> result = [];
    for (int i = 0; i < maps.length; i++) {
      result.add(TransactionModel.fromMap(maps[i]));
    }
    return result;
  }

  Future<int> deleteTransaction(int id) async {
    await createDatabase();
    return await db!.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- BUDGETS ----------------

  Future<int> insertBudget(BudgetModel budget) async {
    await createDatabase();

    Map<String, dynamic> data = budget.toMap();
    data.remove('id'); // let SQLite auto-generate the id on insert

    return await db!.insert('budgets', data);
  }

  Future<List<BudgetModel>> getBudgets() async {
    await createDatabase();

    List<Map<String, dynamic>> maps = await db!.query(
      'budgets',
      orderBy: 'id DESC',
    );

    List<BudgetModel> result = [];
    for (int i = 0; i < maps.length; i++) {
      result.add(BudgetModel.fromMap(maps[i]));
    }
    return result;
  }

  Future<int> deleteBudget(int id) async {
    await createDatabase();
    return await db!.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }
}