import 'package:ecclesia_frontend/src/core/api/auth_state.dart';
import 'package:ecclesia_frontend/src/features/auth/presentation/auth_controller.dart';
import 'package:ecclesia_frontend/src/features/finance/presentation/finance_controller.dart';
import 'package:ecclesia_frontend/src/features/finance/domain/models.dart';
import 'package:ecclesia_frontend/src/features/finance/presentation/scope_controller.dart';
import 'package:ecclesia_frontend/src/features/finance/data/finance_repository.dart';
import 'package:ecclesia_frontend/src/features/finance/domain/models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard'),
            const Gap(2),
            _ModeIndicator(),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () => context.push('/categories'),
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => context.push('/transactions'),
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () => context.push('/monthly-report'),
          ),
          if (ref.watch(organizationModeProvider) == 'CORPORATE') ...[
            IconButton(
              tooltip: 'Plano de Contas',
              icon: const Icon(Icons.account_tree_outlined),
              onPressed: () => context.push('/organizational-report'),
            ),
            IconButton(
              tooltip: 'Fechamento Mensal',
              icon: const Icon(Icons.lock_clock),
              onPressed: () => context.push('/periods'),
            ),
            IconButton(
              tooltip: 'Auditoria',
              icon: const Icon(Icons.history_edu),
              onPressed: () => context.push('/audit-trail'),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(transactionsControllerProvider);
          ref.invalidate(reportSummaryControllerProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scope Indicator & Selector
              const _ScopeSelector(),
              
              const Gap(16),
              
              // Summary Cards
              statsAsync.when(
                data: (stats) => Row(
                  children: [
                    Expanded(child: _SummaryCard('Income', stats.totalIncome, Colors.green)),
                    const Gap(8),
                    Expanded(child: _SummaryCard('Expense', stats.totalExpense, Colors.red)),
                    const Gap(8),
                    Expanded(child: _SummaryCard('Balance', stats.balance, Colors.blue)),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error: $err'),
              ),
              
              const Gap(24),
              
              const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Gap(8),
              
              transactionsAsync.when(
                data: (transactions) => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final t = transactions[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(t.categoryName[0]),
                        ),
                        title: Text(t.categoryName),
                        subtitle: Text(t.description ?? ''),
                        trailing: Text(
                          NumberFormat.currency(symbol: '\$').format(t.amount),
                          style: TextStyle(
                            color: t.transactionType == 'INCOME' ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                 loading: () => const Center(child: CircularProgressIndicator()),
                 error: (err, _) => Text('Error: $err'),
              ),
              
              const Gap(24),
              // Placeholder for Chart
              statsAsync.when(
                  data: (stats) => SizedBox(
                    height: 200,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: BarChart(
                            BarChartData(
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value == 0) return const Text('Income');
                                        if (value == 1) return const Text('Expense');
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: [
                                  BarChartGroupData(x: 0, barRods: [
                                    BarChartRodData(toY: stats.totalIncome, color: Colors.green, width: 20, borderRadius: BorderRadius.circular(4))
                                  ]),
                                  BarChartGroupData(x: 1, barRods: [
                                    BarChartRodData(toY: stats.totalExpense, color: Colors.red, width: 20, borderRadius: BorderRadius.circular(4))
                                  ]),
                                ]
                            )
                        ),
                      ),
                    ),
                  ),
                  loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                  error: (err, _) => const SizedBox(height: 200, child: Center(child: Text('Failed to load chart'))),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add transaction dialog
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ScopeSelector extends ConsumerWidget {
  const _ScopeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scopeState = ref.watch(scopeControllerProvider);
    final isGlobalAdmin = ref.watch(isGlobalAdminProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Visualizando:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text(
                  scopeState.tenantName ?? 'Sede',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
            if (isGlobalAdmin)
              TextButton.icon(
                icon: const Icon(Icons.account_tree),
                label: const Text('Visão Organizacional'),
                onPressed: () => context.push('/branches'),
              ),
          ],
        ),
        if (isGlobalAdmin) ...[
          const Gap(12),
          SegmentedButton<ScopeType>(
            segments: const [
              ButtonSegment(value: ScopeType.OWN, label: Text('Minhas'), icon: Icon(Icons.person)),
              ButtonSegment(value: ScopeType.CONSOLIDATED, label: Text('Geral'), icon: Icon(Icons.corporate_fare)),
            ],
            selected: {scopeState.scope == ScopeType.TENANT ? ScopeType.OWN : scopeState.scope}, // Default to OWN if on specific tenant
            onSelectionChanged: (Set<ScopeType> newSelection) {
              ref.read(scopeControllerProvider.notifier).setScope(newSelection.first);
            },
          ),
        ],
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;

  const _SummaryCard(this.title, this.amount, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const Gap(4),
            Text(
              NumberFormat.compactCurrency(symbol: '\$').format(amount),
              style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(organizationModeProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: mode == 'CORPORATE' ? Colors.indigo : Colors.orange,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        mode ?? 'UNKNOWN',
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
