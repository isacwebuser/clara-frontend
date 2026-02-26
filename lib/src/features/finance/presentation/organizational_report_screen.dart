import 'package:ecclesia_frontend/src/features/finance/data/finance_repository.dart';
import 'package:ecclesia_frontend/src/features/finance/domain/models.dart';
import 'package:ecclesia_frontend/src/features/finance/presentation/finance_controller.dart';
import 'package:ecclesia_frontend/src/features/finance/presentation/scope_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class OrganizationalReportScreen extends ConsumerWidget {
  const OrganizationalReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(organizationalReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plano de Contas'),
      ),
      body: reportAsync.when(
        data: (report) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderCard(report),
              const Gap(24),
              Text(
                'Agrupamento por ${report.groupingType}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Gap(8),
              if (report.breakdowns.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Nenhum dado consolidado disponível para este agrupamento.'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: report.breakdowns.length,
                  itemBuilder: (context, index) {
                    final item = report.breakdowns[index];
                    return Card(
                      child: ListTile(
                        title: Text(item.name),
                        trailing: Text(
                          NumberFormat.currency(symbol: '\$').format(item.balance),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: item.balance >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro ao carregar relatório: $err')),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final OrganizationalReportDTO report;
  const _HeaderCard(this.report);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem('Receita Total', report.totalIncome, Colors.green),
                _StatItem('Despesa Total', report.totalExpense, Colors.red),
              ],
            ),
            const Divider(height: 32),
            _StatItem('Saldo Consolidado', report.balance, Colors.blue, isLarge: true),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isLarge;

  const _StatItem(this.label, this.amount, this.color, {this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          NumberFormat.currency(symbol: '\$').format(amount),
          style: TextStyle(
            fontSize: isLarge ? 24 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

final organizationalReportProvider = FutureProvider<OrganizationalReportDTO>((ref) {
  final scopeState = ref.watch(scopeControllerProvider);
  return ref.read(financeRepositoryProvider).getOrganizationalReport(
    scope: scopeState.scope,
    tenantId: scopeState.targetTenantId,
  );
});
