import 'package:ecclesia_frontend/src/features/finance/data/finance_repository.dart';
import 'package:ecclesia_frontend/src/features/finance/domain/models.dart';
import 'package:ecclesia_frontend/src/features/finance/presentation/scope_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BranchManagementScreen extends ConsumerWidget {
  const BranchManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final descendantsAsync = ref.watch(descendantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão das Filiais'),
      ),
      body: descendantsAsync.when(
        data: (descendants) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: descendants.length,
          itemBuilder: (context, index) {
            final branch = descendants[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: const Icon(Icons.business, color: Colors.blue),
                ),
                title: Text(branch.name),
                subtitle: Text('Nível: ${branch.level}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Switch scope to this tenant
                    ref.read(scopeControllerProvider.notifier).setScope(
                      ScopeType.TENANT,
                      tenantId: branch.id,
                      name: branch.name,
                    );
                    context.go('/dashboard');
                  },
                  child: const Text('Acessar'),
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro ao carregar filiais: $err')),
      ),
    );
  }
}

final descendantsProvider = FutureProvider<List<TenantDescendantResponse>>((ref) {
  return ref.read(financeRepositoryProvider).getDescendants();
});
