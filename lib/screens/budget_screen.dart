import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';
import '../services/firebase_service.dart';

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
      List<TransactionModel> transactionList = await dbHelper.getTransactions();

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

  bool budgetAlreadyExists(String category) {
    String currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    for (int i = 0; i < budgets.length; i++) {
      if (budgets[i].category == category && budgets[i].month == currentMonth) {
        return true;
      }
    }
    return false;
  }

  Future<void> showAddBudgetDialog() async {
    String selectedCategory = categoryOptions[0];
    TextEditingController limitController = TextEditingController();
    String dialogError = '';
    bool isSaving = false;

    List<DropdownMenuItem<String>> categoryItems = [];
    for (int i = 0; i < categoryOptions.length; i++) {
      categoryItems.add(
        DropdownMenuItem(value: categoryOptions[i], child: Text(categoryOptions[i])),
      );
    }

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
                    items: categoryItems,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCategory = value!;
                        dialogError = '';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: limitController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Monthly Limit (Rs.)'),
                  ),
                  const SizedBox(height: 8),
                  if (dialogError != '')
                    Text(dialogError, style: const TextStyle(color: Colors.red, fontSize: 12)),
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
                  onPressed: isSaving
                      ? null
                      : () async {
                    double? limit = double.tryParse(limitController.text);

                    if (limit == null || limit <= 0) {
                      setDialogState(() {
                        dialogError = 'Please enter a valid amount';
                      });
                      return;
                    }

                    if (budgetAlreadyExists(selectedCategory)) {
                      setDialogState(() {
                        dialogError = 'A budget for this category already exists this month';
                      });
                      return;
                    }

                    setDialogState(() {
                      isSaving = true;
                      dialogError = '';
                    });

                    try {
                      BudgetModel budget = BudgetModel(
                        category: selectedCategory,
                        limitAmount: limit,
                        month: DateFormat('yyyy-MM').format(DateTime.now()),
                      );

                      await dbHelper.insertBudget(budget);
                      firebaseService.syncBudget(budget);                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                      loadData();
                    } catch (e) {
                      print('SAVE BUDGET ERROR: $e');
                      setDialogState(() {
                        isSaving = false;
                        dialogError = 'Could not save budget. Try again';
                      });
                    }
                  },
                  child: isSaving
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> deleteBudget(int id) async {
    try {
      await dbHelper.deleteBudget(id);
      loadData();
    } catch (e) {
      print('DELETE BUDGET ERROR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete budget')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: showAddBudgetDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: budgetListView(),
      ),
    );
  }

  Widget budgetListView() {
    if (budgets.isEmpty) {
      return const Center(
        child: Text('No budgets set yet', style: TextStyle(color: Colors.grey)),
      );
    }

    List<Widget> budgetCards = [];

    for (int i = 0; i < budgets.length; i++) {
      BudgetModel b = budgets[i];
      double spent = amountSpentForCategory(b.category);
      double progress = b.limitAmount > 0 ? spent / b.limitAmount : 0;

      if (progress > 1) {
        progress = 1;
      }
      if (progress < 0) {
        progress = 0;
      }

      bool isOverBudget = spent > b.limitAmount;

      budgetCards.add(
        Card(
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
        ),
      );
    }

    return ListView(children: budgetCards);
  }
}