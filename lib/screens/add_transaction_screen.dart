import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../services/firebase_service.dart';
import '../models/transaction_model.dart';
import '../services/notification_service.dart';
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  DatabaseHelper dbHelper = DatabaseHelper();
  FirebaseService firebaseService = FirebaseService();

  TextEditingController titleController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  String selectedType = 'expense';
  String selectedCategory = 'Food';
  DateTime selectedDate = DateTime.now();
  String errorMessage = '';
  bool isSaving = false;

  List<String> expenseCategories = ['Food', 'Transport', 'Shopping', 'Bills', 'Health', 'Entertainment', 'Other'];
  List<String> incomeCategories = ['Salary', 'Business', 'Gift', 'Investment', 'Other'];

  @override
  void initState() {
    super.initState();
    setupDatabase();
  }

  Future<void> setupDatabase() async {
    await dbHelper.createDatabase();
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> saveTransaction() async {
    setState(() {
      errorMessage = '';
    });

    if (titleController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a title';
      });
      return;
    }

    if (amountController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter an amount';
      });
      return;
    }

    double? amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      setState(() {
        errorMessage = 'Please enter a valid amount';
      });
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // make sure the database is ready before we insert
      await dbHelper.createDatabase();

      TransactionModel transaction = TransactionModel(
        title: titleController.text,
        amount: amount,
        type: selectedType,
        category: selectedCategory,
        date: DateFormat('yyyy-MM-dd').format(selectedDate),
        note: noteController.text,
      );

      await dbHelper.insertTransaction(transaction);

      await firebaseService.syncTransaction(transaction);

      await NotificationService.showNotification(
        title: "Transaction Saved",
        body: "Rs. ${transaction.amount} added successfully.",
      );

      Navigator.pop(context);
      setState(() {
        isSaving = false;
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        isSaving = false;
        errorMessage = 'Could not save transaction. Please try again';
      });
      print('SAVE ERROR: $e');
    }



  }

  @override
  Widget build(BuildContext context) {
    List<String> categoryList;
    if (selectedType == 'expense') {
      categoryList = expenseCategories;
    } else {
      categoryList = incomeCategories;
    }

    if (categoryList.contains(selectedCategory) == false) {
      selectedCategory = categoryList[0];
    }

    // build dropdown items with a simple loop
    List<DropdownMenuItem<String>> categoryItems = [];
    for (int i = 0; i < categoryList.length; i++) {
      categoryItems.add(
        DropdownMenuItem(value: categoryList[i], child: Text(categoryList[i])),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedType = 'expense';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: selectedType == 'expense' ? Colors.red : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Expense',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selectedType == 'expense' ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedType = 'income';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: selectedType == 'income' ? Colors.green : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Income',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selectedType == 'income' ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: 'Rs. ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: categoryItems,
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            if (errorMessage != '')
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveTransaction,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isSaving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Text('Save Transaction', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}