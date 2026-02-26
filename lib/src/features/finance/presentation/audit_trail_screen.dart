import 'package:ecclesia_frontend/src/features/finance/data/finance_repository.dart';
import 'package:ecclesia_frontend/src/features/finance/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AuditTrailScreen extends ConsumerWidget {
  const AuditTrailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditFuture = ref.watch(financeRepositoryProvider).getAuditLogs();

    return Scaffold(
      appBar: AppBar(title: const Text('Trilha de Auditoria')),
      body: FutureBuilder<List<AuditLogDto>>(
        future: auditFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final logs = snapshot.data ?? [];

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return ExpansionTile(
                leading: _getActionIcon(log.action),
                title: Text('${log.action} - ${log.entityType}'),
                subtitle: Text('Em: ${log.changedAt}'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Entity ID: ${log.entityId}'),
                        const Divider(),
                        if (log.afterSnapshot != null) ...[
                          const Text('Dados do Snapshot:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(log.afterSnapshot.toString()),
                        ],
                        if (log.changedFields != null) ...[
                          const Divider(),
                          const Text('Campos Alterados:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(log.changedFields.toString()),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _getActionIcon(String action) {
    if (action.contains('CREATE')) return const Icon(Icons.add_circle, color: Colors.green);
    if (action.contains('UPDATE')) return const Icon(Icons.edit, color: Colors.blue);
    if (action.contains('DELETE')) return const Icon(Icons.delete, color: Colors.red);
    if (action.contains('CLOSE')) return const Icon(Icons.lock, color: Colors.orange);
    if (action.contains('REOPEN')) return const Icon(Icons.lock_open, color: Colors.lightBlue);
    return const Icon(Icons.history);
  }
}
