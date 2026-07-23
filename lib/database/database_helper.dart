import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';

class DatabaseHelper {

  late Database db;

  Future<void> createDatabase() async {
    db = await openDatabase(
      join(await getDatabasesPath(), 'finance_app.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE transactions ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'title TEXT, '
              'amount REAL, '
              'type TEXT, '
              'category TEXT, '
              'date TEXT, '
              'note TEXT)',
        );

        await db.execute(
          'CREATE TABLE budgets ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'category TEXT, '
              'limitAmount REAL, '
              'month TEXT)',
        );
      },
    );
  }

  // ---------------- TRANSACTIONS ----------------

  Future<void> insertTransaction(TransactionModel transaction) async {
    await db.insert(
      'transactions',
      transaction.toMap(),
    );
  }

  Future<List<TransactionModel>> getTransactions() async {
    List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'id DESC',
    );

    List<TransactionModel> transactions = [];
    for (int i = 0; i < maps.length; i++) {
      transactions.add(TransactionModel.fromMap(maps[i]));
    }
    return transactions;
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(int id) async {
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------------- BUDGETS ----------------

  Future<void> insertBudget(BudgetModel budget) async {
    await db.insert(
      'budgets',
      budget.toMap(),
    );
  }

  Future<List<BudgetModel>> getBudgets() async {
    List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      orderBy: 'id DESC',
    );

    List<BudgetModel> budgets = [];
    for (int i = 0; i < maps.length; i++) {
      budgets.add(BudgetModel.fromMap(maps[i]));
    }
    return budgets;
  }

  Future<void> updateBudget(BudgetModel budget) async {
    await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<void> deleteBudget(int id) async {
    await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
