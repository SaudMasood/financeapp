import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/database_helper.dart';
import '../models/transaction_model.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {

  DatabaseHelper dbHelper = DatabaseHelper();
  List<TransactionModel> transactions = [];
  bool isLoading = true;

  Map<String, double> categoryTotals = {};
  double totalIncome = 0;
  double totalExpense = 0;

  List<Color> pieColors = [
    Colors.blue, Colors.red, Colors.green, Colors.orange,
    Colors.purple, Colors.teal, Colors.pink, Colors.brown,
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await dbHelper.createDatabase();




    List<TransactionModel> list = await dbHelper.getTransactions();

    Map<String, double> totals = {};
    double income = 0;
    double expense = 0;

    for (var item in list) {
      if (item.type == 'expense') {
        expense += item.amount;

        if (totals.containsKey(item.category)) {
          totals[item.category] =
              totals[item.category]! + item.amount;
        } else {
          totals[item.category] = item.amount;
        }
      } else {
        income += item.amount;
      }
    }

    setState(() {
      transactions = list;
      categoryTotals = totals;
      totalIncome = income;
      totalExpense = expense;
      isLoading = false;
    });
  }

  List<String> generateInsights() {
    List<String> insights = [];

    if (transactions.isEmpty) {
      insights.add('Add some transactions to see insights here.');
      return insights;
    }

    if (totalExpense > totalIncome) {
      insights.add('You are spending more than you earn. Try to cut back on non-essential categories.');
    } else {
      double saved = totalIncome - totalExpense;
      double percent = totalIncome > 0 ? (saved / totalIncome) * 100 : 0;
      insights.add('You are saving about ${percent.toStringAsFixed(0)}% of your income. Nice work.');
    }

    if (categoryTotals.isNotEmpty) {
      String topCategory = '';
      double topAmount = 0;
      categoryTotals.forEach((key, value) {
        if (value > topAmount) {
          topAmount = value;
          topCategory = key;
        }
      });
      insights.add('Your biggest spending category is $topCategory at Rs. ${topAmount.toStringAsFixed(0)}.');
    }

    return insights;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<String> insights = generateInsights();
    List<String> categoryKeys = categoryTotals.keys.toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Reports',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text('Income vs Expense', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (totalIncome > totalExpense ? totalIncome : totalExpense) + 500,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) {
                        return const Text('Income');
                      } else if (value == 1) {
                        return const Text('Expense');
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: [
                BarChartGroupData(x: 0, barRods: [
                  BarChartRodData(toY: totalIncome, color: Colors.green, width: 30),
                ]),
                BarChartGroupData(x: 1, barRods: [
                  BarChartRodData(toY: totalExpense, color: Colors.red, width: 30),
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Spending by Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        categoryTotals.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No expense data yet', style: TextStyle(color: Colors.grey)),
              )
            : SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    sections: List.generate(categoryKeys.length, (index) {
                      String category = categoryKeys[index];
                      double value = categoryTotals[category]!;
                      Color color = pieColors[index % pieColors.length];
                      return PieChartSectionData(
                        value: value,
                        title: category,
                        color: color,
                        radius: 80,
                        titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    }),
                  ),
                ),
              ),
        const SizedBox(height: 24),
        const Text('AI Spending Insights', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Column(
          children: insights.map((text) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.blue),
                  const SizedBox(width: 10),
                  Expanded(child: Text(text)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
