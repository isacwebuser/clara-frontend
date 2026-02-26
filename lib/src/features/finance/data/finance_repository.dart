import 'package:dio/dio.dart';
import 'package:ecclesia_frontend/src/core/api/api_client.dart';
import 'package:ecclesia_frontend/src/features/finance/domain/models.dart';
import 'package:ecclesia_frontend/src/features/finance/presentation/scope_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final financeRepositoryProvider = Provider((ref) => FinanceRepository(ref.read(dioProvider)));

class FinanceRepository {
  final Dio _dio;

  FinanceRepository(this._dio);

  Future<List<CategoryDto>> getCategories({ScopeType? scope, String? tenantId}) async {
    final response = await _dio.get('/api/v1/finance/categories', queryParameters: {
      if (scope != null) 'scope': scope.name,
      if (tenantId != null) 'tenantId': tenantId,
    });
    return (response.data as List).map((e) => CategoryDto.fromJson(e)).toList();
  }

  Future<List<TransactionDto>> getTransactions({ScopeType? scope, String? tenantId}) async {
    final response = await _dio.get('/api/v1/finance/transactions', queryParameters: {
      if (scope != null) 'scope': scope.name,
      if (tenantId != null) 'tenantId': tenantId,
    });
    return (response.data as List).map((e) => TransactionDto.fromJson(e)).toList();
  }

  Future<ScopedReportResponse> getReportSummary({ScopeType? scope, String? tenantId}) async {
    final response = await _dio.get('/api/v1/finance/reports/summary', queryParameters: {
      if (scope != null) 'scope': scope.name,
      if (tenantId != null) 'tenantId': tenantId,
    });
    return ScopedReportResponse.fromJson(response.data);
  }

  Future<List<TenantDescendantResponse>> getDescendants() async {
    final response = await _dio.get('/api/v1/tenants/descendants');
    return (response.data as List).map((e) => TenantDescendantResponse.fromJson(e)).toList();
  }
  
  Future<void> createCategory(String name, String type, String color, String icon, {String? templateId, bool custom = false}) async {
    await _dio.post('/api/v1/finance/categories', data: {
      'name': name,
      'type': type,
      'color': color,
      'icon': icon,
      'templateId': templateId,
      'custom': custom,
    });
  }

  Future<List<CategoryTemplateDto>> getCategoryTemplates() async {
    final response = await _dio.get('/api/v1/finance/category-templates');
    return (response.data as List).map((e) => CategoryTemplateDto.fromJson(e)).toList();
  }

  Future<void> createCategoryTemplate(String code, String name, String type, bool mandatory) async {
    await _dio.post('/api/v1/finance/category-templates', data: {
      'code': code,
      'name': name,
      'type': type,
      'mandatory': mandatory,
    });
  }

  Future<void> createTransaction(String categoryId, double amount, String description, String transactionDate) async {
    await _dio.post('/api/v1/finance/transactions', data: {
      'categoryId': categoryId,
      'amount': amount,
      'description': description,
      'date': transactionDate,
    });
  }

  Future<void> updateCategory(String id, String name, String type, String color, String icon) async {
    await _dio.put('/api/v1/finance/categories/$id', data: {
      'name': name,
      'type': type,
      'color': color,
      'icon': icon,
    });
  }

  Future<void> deleteCategory(String id) async {
    await _dio.delete('/api/v1/finance/categories/$id');
  }

  Future<void> updateTransaction(String id, String categoryId, double amount, String description, String transactionDate) async {
    await _dio.put('/api/v1/finance/transactions/$id', data: {
      'categoryId': categoryId,
      'amount': amount,
      'description': description,
      'date': transactionDate,
    });
  }

  Future<void> deleteTransaction(String id) async {
    await _dio.delete('/api/v1/finance/transactions/$id');
  }

  Future<OrganizationalReportDTO> getOrganizationalReport({ScopeType? scope, String? tenantId}) async {
    final response = await _dio.get('/api/v1/finance/reports/organizational', queryParameters: {
      if (scope != null) 'scope': scope.name,
      if (tenantId != null) 'tenantId': tenantId,
    });
    return OrganizationalReportDTO.fromJson(response.data);
  }

  Future<List<AccountingPeriodDto>> getPeriods() async {
    final response = await _dio.get('/api/v1/finance/periods');
    return (response.data as List).map((e) => AccountingPeriodDto.fromJson(e)).toList();
  }

  Future<void> closePeriod(int year, int month) async {
    await _dio.post('/api/v1/finance/periods/$year/$month/close');
  }

  Future<void> reopenPeriod(int year, int month, String reason) async {
    await _dio.post('/api/v1/finance/periods/$year/$month/reopen', queryParameters: {
      'reason': reason,
    });
  }

  Future<List<AuditLogDto>> getAuditLogs() async {
    final response = await _dio.get('/api/v1/finance/audit');
    return (response.data as List).map((e) => AuditLogDto.fromJson(e)).toList();
  }
}
