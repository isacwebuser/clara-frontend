import 'package:ecclesia_frontend/src/features/finance/data/finance_repository.dart';
import 'package:ecclesia_frontend/src/features/finance/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class PeriodsScreen extends ConsumerStatefulWidget {
  const PeriodsScreen({super.key});

  @override
  ConsumerState<PeriodsScreen> createState() => _PeriodsScreenState();
}

class _PeriodsScreenState extends ConsumerState<PeriodsScreen> {
  late Future<List<AccountingPeriodDto>> _periodsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _periodsFuture = ref.read(financeRepositoryProvider).getPeriods();
    });
  }

  Future<void> _closePeriod(int year, int month) async {
    try {
      await ref.read(financeRepositoryProvider).closePeriod(year, month);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Período fechado com sucesso')),
        );
        _refresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fechar período: $e')),
        );
      }
    }
  }

  Future<void> _reopenPeriod(int year, int month) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reabrir Período'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Justificativa obrigatória'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reabrir')),
        ],
      ),
    );

    if (confirmed == true && reasonController.text.isNotEmpty) {
      try {
        await ref.read(financeRepositoryProvider).reopenPeriod(year, month, reasonController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Período reaberto')),
          );
          _refresh();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao reabrir: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fechamento Mensal')),
      body: FutureBuilder<List<AccountingPeriodDto>>(
        future: _periodsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final periods = snapshot.data ?? [];
          if (periods.isEmpty) {
            return const Center(child: Text('Nenhum período registrado.'));
          }

          return ListView.builder(
            itemCount: periods.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final p = periods[index];
              final isClosed = p.status == 'CLOSED';
              final isLocked = p.status == 'LOCKED';

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(p.status),
                    child: Text(p.month.toString(), style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text('${_getMonthName(p.month)} / ${p.year}'),
                  subtitle: Text('Status: ${p.status}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isClosed && !isLocked)
                        IconButton(
                          icon: const Icon(Icons.lock_open, color: Colors.orange),
                          tooltip: 'Fechar Período',
                          onPressed: () => _closePeriod(p.year, p.month),
                        ),
                      if (isClosed)
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.blue),
                          tooltip: 'Reabrir Período',
                          onPressed: () => _reopenPeriod(p.year, p.month),
                        ),
                      if (isLocked)
                        const Icon(Icons.lock, color: Colors.red),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'OPEN': return Colors.amber;
      case 'CLOSED': return Colors.blue;
      case 'LOCKED': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getMonthName(int month) {
    const names = [
      '', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return names[month];
  }
}
