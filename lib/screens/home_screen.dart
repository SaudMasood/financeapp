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
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
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

    for (int i = 0; i < transactions.length; i++) {
      if (transactions[i].type == "income") {
        income = income + transactions[i].amount;
      } else {
        expense = expense + transactions[i].amount;
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    double balance = totalIncome - totalExpense;

    // build a list of recent transaction widgets manually
    List<Widget> recentWidgets = [];

    if (allTransactions.isEmpty) {
      recentWidgets.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text('No transactions yet', style: TextStyle(color: Colors.grey)),
        ),
      );
    } else {
      int count = 0;
      for (int i = 0; i < allTransactions.length; i++) {
        if (count >= 5) break;

        TransactionModel t = allTransactions[i];

        Color color;
        IconData icon;
        String amountText;

        if (t.type == 'income') {
          color = Colors.green;
          icon = Icons.arrow_downward;
          amountText = '+ Rs. ${t.amount.toStringAsFixed(0)}';
        } else {
          color = Colors.red;
          icon = Icons.arrow_upward;
          amountText = '- Rs. ${t.amount.toStringAsFixed(0)}';
        }

        recentWidgets.add(
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              title: Text(t.title),
              subtitle: Text('${t.category} • ${t.date}'),
              trailing: Text(
                amountText,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );

        count = count + 1;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // balance card
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

            // income and expense cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.arrow_downward, color: Colors.green),
                        const SizedBox(height: 8),
                        const Text('Income', style: TextStyle(color: Colors.green)),
                        const SizedBox(height: 4),
                        Text(
                          'Rs. ${totalIncome.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.arrow_upward, color: Colors.red),
                        const SizedBox(height: 8),
                        const Text('Expense', style: TextStyle(color: Colors.red)),
                        const SizedBox(height: 4),
                        Text(
                          'Rs. ${totalExpense.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // recent transaction cards
            Column(children: recentWidgets),
          ],
        ),
      ),
    );
  }
}