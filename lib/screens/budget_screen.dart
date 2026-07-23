import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../services/firebase_service.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {

  DatabaseHelper dbHelper = DatabaseHelper();
  FirebaseService firebaseService = FirebaseService();
  List<BudgetModel> budgets = [];
  List<TransactionModel> transactions = [];
  bool isLoading = true;

  List<String> categoryOptions = ['Food', 'Transport', 'Shopping', 'Bills', 'Health', 'Entertainment', 'Other'];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      await dbHelper.createDatabase();

      List<BudgetModel> budgetList = await dbHelper.getBudgets();
      List<TransactionModel> transactionList =
      await dbHelper.getTransactions();

      setState(() {
        budgets = budgetList;
        transactions = transactionList;
        isLoading = false;
      });
    } catch (e) {
      print("Budget Screen Error: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  double amountSpentForCategory(String category) {
    String currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    double spent = 0;
    for (int i = 0; i < transactions.length; i++) {
      if (transactions[i].category == category &&
          transactions[i].type == 'expense' &&
          transactions[i].date.startsWith(currentMonth)) {
        spent = spent + transactions[i].amount;
      }
    }
    return spent;
  }

  Future<void> showAddBudgetDialog() async {
    String selectedCategory = categoryOptions[0];
    TextEditingController limitController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Set Budget'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categoryOptions.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: limitController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Monthly Limit (Rs.)'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    double? limit = double.tryParse(limitController.text);
                    if (limit == null || limit <= 0) {
                      return;
                    }

                    BudgetModel budget = BudgetModel(
                      category: selectedCategory,
                      limitAmount: limit,
                      month: DateFormat('yyyy-MM').format(DateTime.now()),
                    );

                    await dbHelper.insertBudget(budget);
                    firebaseService.syncBudget(budget);
                    Navigator.pop(context);
                    loadData();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> deleteBudget(int id) async {
    await dbHelper.deleteBudget(id);
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Budgets',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: showAddBudgetDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: budgets.isEmpty
                ? const Center(child: Text('No budgets set yet', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: budgets.length,
                    itemBuilder: (context, index) {
                      BudgetModel b = budgets[index];
                      double spent = amountSpentForCategory(b.category);
                      double progress = spent / b.limitAmount;
                      if (progress > 1) {
                        progress = 1;
                      }
                      bool isOverBudget = spent > b.limitAmount;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(b.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                    onPressed: () {
                                      deleteBudget(b.id!);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade200,
                                color: isOverBudget ? Colors.red : Colors.green,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Rs. ${spent.toStringAsFixed(0)} of Rs. ${b.limitAmount.toStringAsFixed(0)}',
                                style: TextStyle(color: isOverBudget ? Colors.red : Colors.grey.shade700),
                              ),
                              if (isOverBudget)
                                const Text('Over budget!', style: TextStyle(color: Colors.red, fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
