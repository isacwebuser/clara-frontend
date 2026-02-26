import 'package:ecclesia_frontend/src/features/finance/data/finance_repository.dart';
import 'package:ecclesia_frontend/src/features/finance/domain/models.dart';
import 'package:ecclesia_frontend/src/features/finance/presentation/scope_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

final userRoleProvider = FutureProvider<String?>((ref) async {
  const storage = FlutterSecureStorage();
  final token = await storage.read(key: 'access_token');
  if (token != null) {
    final decoded = JwtDecoder.decode(token);
    return decoded['role']?.toString();
  }
  return null;
});

final isGlobalAdminProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider).value;
  return role == 'GLOBAL_ADMIN';
});

final transactionsControllerProvider = AsyncNotifierProvider<TransactionsController, List<TransactionDto>>(TransactionsController.new);

class TransactionsController extends AsyncNotifier<List<TransactionDto>> {
  @override
  Future<List<TransactionDto>> build() async {
    final scopeState = ref.watch(scopeControllerProvider);
    return ref.read(financeRepositoryProvider).getTransactions(
      scope: scopeState.scope,
      tenantId: scopeState.targetTenantId,
    );
  }

  Future<void> addTransaction(String categoryId, double amount, String description, String transactionDate) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(financeRepositoryProvider).createTransaction(categoryId, amount, description, transactionDate);
      ref.invalidate(reportSummaryControllerProvider); // Refresh stats
      final scopeState = ref.read(scopeControllerProvider);
      return ref.read(financeRepositoryProvider).getTransactions(
        scope: scopeState.scope,
        tenantId: scopeState.targetTenantId,
      );
    });
  }

  Future<void> updateTransaction(String id, String categoryId, double amount, String description, String transactionDate) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(financeRepositoryProvider).updateTransaction(id, categoryId, amount, description, transactionDate);
      ref.invalidate(reportSummaryControllerProvider); // Refresh stats
      final scopeState = ref.read(scopeControllerProvider);
      return ref.read(financeRepositoryProvider).getTransactions(
        scope: scopeState.scope,
        tenantId: scopeState.targetTenantId,
      );
    });
  }

  Future<void> deleteTransaction(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(financeRepositoryProvider).deleteTransaction(id);
      ref.invalidate(reportSummaryControllerProvider); // Refresh stats
      final scopeState = ref.read(scopeControllerProvider);
      return ref.read(financeRepositoryProvider).getTransactions(
        scope: scopeState.scope,
        tenantId: scopeState.targetTenantId,
      );
    });
  }
}

final transactionsProvider = Provider((ref) => ref.watch(transactionsControllerProvider));

final categoriesControllerProvider = AsyncNotifierProvider<CategoriesController, List<CategoryDto>>(CategoriesController.new);

class CategoriesController extends AsyncNotifier<List<CategoryDto>> {
  @override
  Future<List<CategoryDto>> build() async {
    final scopeState = ref.watch(scopeControllerProvider);
    return ref.read(financeRepositoryProvider).getCategories(
      scope: scopeState.scope,
      tenantId: scopeState.targetTenantId,
    );
  }

  Future<void> addCategory(String name, String type, String color, String icon, {String? templateId, bool custom = false}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(financeRepositoryProvider).createCategory(name, type, color, icon, templateId: templateId, custom: custom);
      final scopeState = ref.read(scopeControllerProvider);
      return ref.read(financeRepositoryProvider).getCategories(
        scope: scopeState.scope,
        tenantId: scopeState.targetTenantId,
      );
    });
  }
  
  Future<void> updateCategory(String id, String name, String type, String color, String icon, {String? templateId, bool custom = false}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Note: Backend might need update to support templateId/custom in PUT if we want that
      await ref.read(financeRepositoryProvider).updateCategory(id, name, type, color, icon);
      final scopeState = ref.read(scopeControllerProvider);
      return ref.read(financeRepositoryProvider).getCategories(
        scope: scopeState.scope,
        tenantId: scopeState.targetTenantId,
      );
    });
  }

  Future<void> deleteCategory(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(financeRepositoryProvider).deleteCategory(id);
      final scopeState = ref.read(scopeControllerProvider);
      return ref.read(financeRepositoryProvider).getCategories(
        scope: scopeState.scope,
        tenantId: scopeState.targetTenantId,
      );
    });
  }
}

final categoriesProvider = Provider((ref) => ref.watch(categoriesControllerProvider));

final reportSummaryControllerProvider = AsyncNotifierProvider<ReportSummaryController, ScopedReportResponse>(ReportSummaryController.new);

class ReportSummaryController extends AsyncNotifier<ScopedReportResponse> {
  @override
  Future<ScopedReportResponse> build() async {
    final scopeState = ref.watch(scopeControllerProvider);
    return ref.read(financeRepositoryProvider).getReportSummary(
      scope: scopeState.scope,
      tenantId: scopeState.targetTenantId,
    );
  }
}

final dashboardStatsProvider = Provider<AsyncValue<DashboardStats>>((ref) {
  final summaryAsync = ref.watch(reportSummaryControllerProvider);
  
  return summaryAsync.whenData((summary) => DashboardStats(
      totalIncome: summary.totalIncome, 
      totalExpense: summary.totalExpense, 
      balance: summary.balance
  ));
});

class DashboardStats {
  final double totalIncome;
  final double totalExpense;
  final double balance;

  DashboardStats({required this.totalIncome, required this.totalExpense, required this.balance});
}
