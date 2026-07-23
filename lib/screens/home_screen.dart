import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import 'add_transaction_screen.dart';
import 'transaction_screen.dart';
import 'budget_screen.dart';
import 'report_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget bodyToShow;

    if (currentIndex == 0) {
      bodyToShow = const DashboardBody();
    } else if (currentIndex == 1) {
      bodyToShow = const TransactionScreen();
    } else if (currentIndex == 2) {
      bodyToShow = const BudgetScreen();
    } else if (currentIndex == 3) {
      bodyToShow = const ReportScreen();
    } else {
      bodyToShow = const SettingsScreen();
    }

    return Scaffold(
      body: SafeArea(child: bodyToShow),
      floatingActionButton: currentIndex == 0 || currentIndex == 1
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTransactionScreen(),
                  ),
                );
                setState(() {});
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Budget'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class DashboardBody extends StatefulWidget {
  const DashboardBody({super.key});

  @override
  State<DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<DashboardBody> {

  DatabaseHelper dbHelper = DatabaseHelper();
  List<TransactionModel> allTransactions = [];
  double totalIncome = 0;
  double totalExpense = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await dbHelper.createDatabase();

    List<TransactionModel> transactions = await dbHelper.getTransactions();

    double income = 0;
    double expense = 0;

    for (var t in transactions) {
      if (t.type == "income") {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    setState(() {
      allTransactions = transactions;
      totalIncome = income;
      totalExpense = expense;
      isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    double balance = totalIncome - totalExpense;
    List<TransactionModel> recent = allTransactions.take(5).toList();

    return RefreshIndicator(
      onRefresh: loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Balance', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),
                Text(
                  'Rs. ${balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: summaryCard('Income', totalIncome, Colors.green, Icons.arrow_downward),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: summaryCard('Expense', totalExpense, Colors.red, Icons.arrow_upward),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          recent.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('No transactions yet', style: TextStyle(color: Colors.grey)),
                )
              : Column(
                  children: recent.map((t) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: t.type == 'income'
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          child: Icon(
                            t.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                            color: t.type == 'income' ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(t.title),
                        subtitle: Text('${t.category} • ${t.date}'),
                        trailing: Text(
                          (t.type == 'income' ? '+ ' : '- ') + 'Rs. ${t.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: t.type == 'income' ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget summaryCard(String label, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color)),
          const SizedBox(height: 4),
          Text(
            'Rs. ${amount.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
