import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/transaction_model.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {

  DatabaseHelper dbHelper = DatabaseHelper();
  List<TransactionModel> allTransactions = [];
  List<TransactionModel> filteredTransactions = [];
  TextEditingController searchController = TextEditingController();
  String selectedFilter = 'All';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }
  Future<void> loadTransactions() async {
    await dbHelper.createDatabase();

    List<TransactionModel> transactions = await dbHelper.getTransactions();

    setState(() {
      allTransactions = transactions;
      filteredTransactions = transactions;
      isLoading = false;
    });

    applyFilters();
  }

  void applyFilters() {
    List<TransactionModel> result = allTransactions;

    if (selectedFilter == 'Income') {
      result = result.where((t) => t.type == 'income').toList();
    } else if (selectedFilter == 'Expense') {
      result = result.where((t) => t.type == 'expense').toList();
    }

    if (searchController.text.isNotEmpty) {
      String query = searchController.text.toLowerCase();
      result = result.where((t) {
        return t.title.toLowerCase().contains(query) || t.category.toLowerCase().contains(query);
      }).toList();
    }

    setState(() {
      filteredTransactions = result;
    });
  }

  Future<void> deleteTransaction(int id) async {
    await dbHelper.deleteTransaction(id);
    loadTransactions();
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
          const Text(
            'Transactions',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: searchController,
            onChanged: (value) {
              applyFilters();
            },
            decoration: InputDecoration(
              hintText: 'Search by title or category',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              filterChip('All'),
              const SizedBox(width: 8),
              filterChip('Income'),
              const SizedBox(width: 8),
              filterChip('Expense'),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filteredTransactions.isEmpty
                ? const Center(child: Text('No transactions found', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      TransactionModel t = filteredTransactions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: t.type == 'income' ? Colors.green.shade100 : Colors.red.shade100,
                            child: Icon(
                              t.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                              color: t.type == 'income' ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(t.title),
                          subtitle: Text('${t.category} • ${t.date}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                (t.type == 'income' ? '+ ' : '- ') + 'Rs. ${t.amount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: t.type == 'income' ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                onPressed: () {
                                  deleteTransaction(t.id!);
                                },
                              ),
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

  Widget filterChip(String label) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
        applyFilters();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E88E5) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
