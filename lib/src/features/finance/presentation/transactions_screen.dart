import 'package:ecclesia_frontend/src/features/finance/domain/models.dart';
import 'package:ecclesia_frontend/src/features/finance/presentation/finance_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: transactionsAsync.when(
        data: (transactions) => ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final t = transactions[index];
            return Slidable(
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) => _showTransactionDialog(context, ref, transaction: t),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                    SlidableAction(
                      onPressed: (context) => ref.read(transactionsControllerProvider.notifier).deleteTransaction(t.id),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(t.categoryName.isNotEmpty ? t.categoryName[0] : '?'),
                    ),
                    title: Text(t.categoryName),
                    subtitle: Text('${t.description ?? ''}\n${t.transactionDate}'),
                    isThreeLine: true,
                    trailing: Text(
                      NumberFormat.currency(symbol: '\$').format(t.amount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showTransactionDialog(BuildContext context, WidgetRef ref, {TransactionDto? transaction}) {
    final descriptionController = TextEditingController(text: transaction?.description);
    final amountController = TextEditingController(text: transaction?.amount.toString());
    final dateController = TextEditingController(text: transaction?.transactionDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now()));
    
    var selectedCategoryId = transaction?.categoryId;
    
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final categoriesAsync = ref.watch(categoriesProvider);
          
          return AlertDialog(
            title: Text(transaction == null ? 'New Transaction' : 'Edit Transaction'),
            content: SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    categoriesAsync.when(
                      data: (categories) => DropdownButtonFormField<String>(
                          value: selectedCategoryId,
                          items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                          onChanged: (v) => selectedCategoryId = v,
                          decoration: const InputDecoration(labelText: 'Category'),
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (_,__) => const Text('Failed to load categories'),
                    ),
                    const Gap(8),
                    TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
                    const Gap(8),
                    TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
                    const Gap(8),
                    TextField(controller: dateController, decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)')),
                  ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                   if (selectedCategoryId != null) {
                     if (transaction == null) {
                        ref.read(transactionsControllerProvider.notifier).addTransaction(
                            selectedCategoryId!, 
                            double.tryParse(amountController.text) ?? 0, 
                            descriptionController.text, 
                            dateController.text
                        );
                     } else {
                        ref.read(transactionsControllerProvider.notifier).updateTransaction(
                            transaction.id,
                            selectedCategoryId!, 
                            double.tryParse(amountController.text) ?? 0, 
                            descriptionController.text, 
                            dateController.text
                        );
                     }
                   }
                   Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        }
      ),
    );
  }
}
