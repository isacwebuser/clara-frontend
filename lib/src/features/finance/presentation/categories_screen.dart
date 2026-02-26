import 'package:ecclesia_frontend/src/core/theme/app_theme.dart';
import 'package:ecclesia_frontend/src/features/finance/data/finance_repository.dart';
import 'package:ecclesia_frontend/src/features/finance/domain/models.dart';
import 'package:ecclesia_frontend/src/features/finance/presentation/finance_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';

const List<Map<String, dynamic>> _basicIcons = [
  {'name': 'home', 'icon': Icons.home},
  {'name': 'food', 'icon': Icons.fastfood},
  {'name': 'car', 'icon': Icons.directions_car},
  {'name': 'category', 'icon': Icons.category},
  {'name': 'shopping', 'icon': Icons.shopping_cart},
  {'name': 'health', 'icon': Icons.local_hospital},
  {'name': 'education', 'icon': Icons.school},
];

const List<Map<String, dynamic>> _adminIcons = [
  {'name': 'business', 'icon': Icons.business},
  {'name': 'bank', 'icon': Icons.account_balance},
  {'name': 'security', 'icon': Icons.security},
  {'name': 'work', 'icon': Icons.work},
  {'name': 'gavel', 'icon': Icons.gavel},
];

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: categoriesAsync.when(
        data: (categories) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Slidable(
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    if (category.templateId == null || category.custom) ...[
                      SlidableAction(
                        onPressed: (context) => _showEditDialog(context, ref, category),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Edit',
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                      ),
                      SlidableAction(
                        onPressed: (context) => ref.read(categoriesControllerProvider.notifier).deleteCategory(category.id),
                        backgroundColor: AppTheme.error,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                      ),
                    ] else
                      const SlidableAction(
                        onPressed: null,
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        icon: Icons.lock,
                        label: 'Locked',
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                  ],
                ),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _parseColor(category.color).withOpacity(0.2),
                      child: Icon(
                        _parseIcon(category.icon),
                        color: _parseColor(category.color),
                      ),
                    ),
                    title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(category.type),
                    trailing: category.templateId != null && !category.custom
                        ? const Icon(Icons.lock_outline, size: 16, color: Colors.indigo)
                        : const Icon(Icons.drag_handle, color: Colors.grey),
                  ),
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _parseColor(String colorStr) {
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppTheme.primary;
    }
  }

  IconData _parseIcon(String? iconStr) {
    if (iconStr == null) return Icons.category;
    final allIcons = [..._basicIcons, ..._adminIcons];
    final found = allIcons.firstWhere((e) => e['name'] == iconStr, orElse: () => {'icon': Icons.category});
    return found['icon'] as IconData;
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String selectedType = 'EXPENSE';
    String selectedIcon = 'category';
    bool isCustom = true;
    
    // Read the role synchronously as it's cached after initial load
    final role = ref.read(userRoleProvider).value;
    final isElevated = role == 'TENANT_ADMIN' || role == 'GLOBAL_ADMIN';
    final availableIcons = [..._basicIcons, if (isElevated) ..._adminIcons];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                const Gap(16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ['INCOME', 'EXPENSE'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => setState(() => selectedType = val!),
                ),
                const Gap(16),
                CheckboxListTile(
                  title: const Text('Custom Category'),
                  subtitle: const Text('Allows creation without a template'),
                  value: isCustom,
                  onChanged: (val) => setState(() => isCustom = val!),
                  contentPadding: EdgeInsets.zero,
                ),
                const Gap(16),
                const Align(alignment: Alignment.centerLeft, child: Text('Select Icon')),
                const Gap(8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableIcons.map((ic) {
                    final isSelected = selectedIcon == ic['name'];
                    return InkWell(
                      onTap: () => setState(() => selectedIcon = ic['name']),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primary.withOpacity(0.2) : Colors.transparent,
                          border: Border.all(color: isSelected ? AppTheme.primary : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(ic['icon'] as IconData, color: isSelected ? AppTheme.primary : Colors.grey),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  ref.read(categoriesControllerProvider.notifier)
                     .addCategory(
                       nameController.text, 
                       selectedType, 
                       '#4F46E5', 
                       selectedIcon,
                       custom: isCustom,
                     );
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

    void _showEditDialog(BuildContext context, WidgetRef ref, CategoryDto category) {
     final nameController = TextEditingController(text: category.name);
     String selectedIcon = category.icon ?? 'category';
     
     final role = ref.read(userRoleProvider).value;
     final isElevated = role == 'TENANT_ADMIN' || role == 'GLOBAL_ADMIN';
     final availableIcons = [..._basicIcons, if (isElevated) ..._adminIcons];
     
     showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                const Gap(16),
                const Align(alignment: Alignment.centerLeft, child: Text('Select Icon')),
                const Gap(8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableIcons.map((ic) {
                    final isSelected = selectedIcon == ic['name'];
                    return InkWell(
                      onTap: () => setState(() => selectedIcon = ic['name']),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primary.withOpacity(0.2) : Colors.transparent,
                          border: Border.all(color: isSelected ? AppTheme.primary : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(ic['icon'] as IconData, color: isSelected ? AppTheme.primary : Colors.grey),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  ref.read(categoriesControllerProvider.notifier)
                   .updateCategory(category.id, nameController.text, category.type, category.color, selectedIcon);
                  Navigator.pop(context);
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
