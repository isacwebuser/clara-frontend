import 'package:ecclesia_frontend/src/core/theme/app_theme.dart';
import 'package:ecclesia_frontend/src/features/finance/data/finance_repository.dart';
import 'package:ecclesia_frontend/src/features/finance/presentation/finance_controller.dart';
import 'package:ecclesia_frontend/src/features/finance/domain/models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecclesia_frontend/src/features/finance/domain/models.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class MonthlyReportScreen extends ConsumerWidget {
  const MonthlyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Monthly Report'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Expenses', icon: Icon(Icons.trending_down)),
              Tab(text: 'Incomes', icon: Icon(Icons.trending_up)),
            ],
          ),
        ),
        body: transactionsAsync.when(
          data: (transactions) {
            final expenses = transactions.where((t) => t.transactionType == 'EXPENSE').toList();
            final incomes = transactions.where((t) => t.transactionType == 'INCOME').toList();

            return TabBarView(
              children: [
                _ReportContentView(
                    transactions: expenses, 
                    title: "Expenses by Category", 
                    totalLabel: "Total Expenses",
                    accentColor: AppTheme.error
                ),
                _ReportContentView(
                    transactions: incomes, 
                    title: "Incomes by Category", 
                    totalLabel: "Total Incomes",
                    accentColor: Colors.green
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}

class _ReportContentView extends StatelessWidget {
  final List<TransactionDto> transactions;
  final String title;
  final String totalLabel;
  final Color accentColor;

  const _ReportContentView({
    required this.transactions,
    required this.title,
    required this.totalLabel,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.query_stats, size: 64, color: Colors.grey.withOpacity(0.5)),
            const Gap(16),
            const Text("No transactions found for this period."),
          ],
        ),
      );
    }

    final categoryTotals = <String, double>{};
    double grandTotal = 0;

    for (var t in transactions) {
      categoryTotals.update(t.categoryName, (v) => v + t.amount, ifAbsent: () => t.amount);
      grandTotal += t.amount;
    }

    final pieSections = categoryTotals.entries.map((e) {
      final index = categoryTotals.keys.toList().indexOf(e.key);
      final color = Colors.primaries[index % Colors.primaries.length];

      return PieChartSectionData(
        color: color,
        value: e.value,
        title: '${(e.value / grandTotal * 100).toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white),
      );
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Gap(24),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: pieSections,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const Gap(32),

          // Legend List
          ...categoryTotals.entries.map((e) {
            final index = categoryTotals.keys.toList().indexOf(e.key);
            final color = Colors.primaries[index % Colors.primaries.length];
            return ListTile(
              leading: CircleAvatar(backgroundColor: color, radius: 8),
              title: Text(e.key),
              trailing: Text(
                  NumberFormat.currency(symbol: '\$').format(e.value)),
            );
          }),

          const Divider(),
          ListTile(
            title: Text(totalLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text(
                NumberFormat.currency(symbol: '\$').format(grandTotal),
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: accentColor)),
          ),
        ],
      ),
    );
  }
}
