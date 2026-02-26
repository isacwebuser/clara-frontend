import 'package:json_annotation/json_annotation.dart';

class CategoryDto {
  final String id;
  final String name;
  final String type;
  final String color;
  final String? icon;
  final String? templateId;
  final bool custom;
  final bool active;

  CategoryDto({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    this.icon,
    this.templateId,
    this.custom = false,
    this.active = true,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json) => CategoryDto(
    id: json['id'] as String,
    name: json['name'] as String,
    type: json['type'] as String,
    color: json['color'] as String,
    icon: json['icon'] as String?,
    templateId: json['templateId'] as String?,
    custom: json['custom'] as bool? ?? false,
    active: json['active'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'color': color,
    'icon': icon,
    'templateId': templateId,
    'custom': custom,
    'active': active,
  };
}

class TransactionDto {
  final String id;
  final String categoryId;
  final String categoryName;
  final String transactionType;
  final double amount;
  final String? description;
  final String transactionDate;
  final String status;

  TransactionDto({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.transactionType,
    required this.amount,
    this.description,
    required this.transactionDate,
    required this.status,
  });

  factory TransactionDto.fromJson(Map<String, dynamic> json) => TransactionDto(
    id: json['id'] as String,
    categoryId: json['categoryId'] as String,
    categoryName: json['categoryName'] as String,
    transactionType: json['transactionType'] as String,
    amount: (json['amount'] as num).toDouble(),
    description: json['description'] as String?,
    transactionDate: json['transactionDate'] as String,
    status: json['status'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'transactionType': transactionType,
    'amount': amount,
    'description': description,
    'transactionDate': transactionDate,
    'status': status,
  };
}

class ScopedReportResponse {
  final String scopeType;
  final String tenantName;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final List<TenantBreakdownDto>? breakdowns;

  ScopedReportResponse({
    required this.scopeType,
    required this.tenantName,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    this.breakdowns,
  });

  factory ScopedReportResponse.fromJson(Map<String, dynamic> json) => ScopedReportResponse(
    scopeType: json['scopeType'] as String,
    tenantName: json['tenantName'] as String,
    totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
    totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0.0,
    balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    breakdowns: (json['breakdowns'] as List<dynamic>?)
        ?.map((e) => TenantBreakdownDto.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'scopeType': scopeType,
    'tenantName': tenantName,
    'totalIncome': totalIncome,
    'totalExpense': totalExpense,
    'balance': balance,
    'breakdowns': breakdowns?.map((e) => e.toJson()).toList(),
  };
}

class TenantBreakdownDto {
  final String tenantId;
  final String tenantName;
  final double totalIncome;
  final double totalExpense;
  final double balance;

  TenantBreakdownDto({
    required this.tenantId,
    required this.tenantName,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  factory TenantBreakdownDto.fromJson(Map<String, dynamic> json) => TenantBreakdownDto(
    tenantId: json['tenantId'] as String,
    tenantName: json['tenantName'] as String,
    totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
    totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0.0,
    balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    'tenantId': tenantId,
    'tenantName': tenantName,
    'totalIncome': totalIncome,
    'totalExpense': totalExpense,
    'balance': balance,
  };
}

class AccountingPeriodDto {
  final String id;
  final int year;
  final int month;
  final String status;
  final String? closedBy;
  final String? closedAt;

  AccountingPeriodDto({
    required this.id,
    required this.year,
    required this.month,
    required this.status,
    this.closedBy,
    this.closedAt,
  });

  factory AccountingPeriodDto.fromJson(Map<String, dynamic> json) => AccountingPeriodDto(
    id: json['id'] as String,
    year: json['year'] as int,
    month: json['month'] as int,
    status: json['status'] as String,
    closedBy: json['closedBy'] as String?,
    closedAt: json['closedAt'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'year': year,
    'month': month,
    'status': status,
    'closedBy': closedBy,
    'closedAt': closedAt,
  };
}

class AuditLogDto {
  final String id;
  final String entityType;
  final String entityId;
  final String action;
  final Map<String, dynamic>? beforeSnapshot;
  final Map<String, dynamic>? afterSnapshot;
  final Map<String, dynamic>? changedFields;
  final String? changedByUserId;
  final String changedAt;

  AuditLogDto({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    this.beforeSnapshot,
    this.afterSnapshot,
    this.changedFields,
    this.changedByUserId,
    required this.changedAt,
  });

  factory AuditLogDto.fromJson(Map<String, dynamic> json) => AuditLogDto(
    id: json['id'] as String,
    entityType: json['entityType'] as String,
    entityId: json['entityId'] as String,
    action: json['action'] as String,
    beforeSnapshot: json['beforeSnapshot'] as Map<String, dynamic>?,
    afterSnapshot: json['afterSnapshot'] as Map<String, dynamic>?,
    changedFields: json['changedFields'] as Map<String, dynamic>?,
    changedByUserId: json['changedByUserId'] as String?,
    changedAt: json['changedAt'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'entityType': entityType,
    'entityId': entityId,
    'action': action,
    'beforeSnapshot': beforeSnapshot,
    'afterSnapshot': afterSnapshot,
    'changedFields': changedFields,
    'changedByUserId': changedByUserId,
    'changedAt': changedAt,
  };
}

class OrganizationalReportDTO {
  final String scopeType;
  final String groupingType;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final List<GroupedBreakdownDTO> breakdowns;

  OrganizationalReportDTO({
    required this.scopeType,
    required this.groupingType,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.breakdowns,
  });

  factory OrganizationalReportDTO.fromJson(Map<String, dynamic> json) => OrganizationalReportDTO(
    scopeType: json['scopeType'] as String,
    groupingType: json['groupingType'] as String,
    totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
    totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0.0,
    balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    breakdowns: (json['breakdowns'] as List<dynamic>)
        .map((e) => GroupedBreakdownDTO.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'scopeType': scopeType,
    'groupingType': groupingType,
    'totalIncome': totalIncome,
    'totalExpense': totalExpense,
    'balance': balance,
    'breakdowns': breakdowns.map((e) => e.toJson()).toList(),
  };
}

class GroupedBreakdownDTO {
  final String id;
  final String name;
  final double totalIncome;
  final double totalExpense;
  final double balance;

  GroupedBreakdownDTO({
    required this.id,
    required this.name,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  factory GroupedBreakdownDTO.fromJson(Map<String, dynamic> json) => GroupedBreakdownDTO(
    id: json['id'] as String,
    name: json['name'] as String,
    totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
    totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0.0,
    balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'totalIncome': totalIncome,
    'totalExpense': totalExpense,
    'balance': balance,
  };
}

class TenantDescendantResponse {
  final String id;
  final String name;
  final int level;

  TenantDescendantResponse({required this.id, required this.name, required this.level});

  factory TenantDescendantResponse.fromJson(Map<String, dynamic> json) => TenantDescendantResponse(
    id: json['id'] as String,
    name: json['name'] as String,
    level: json['level'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'level': level,
  };
}
class CategoryTemplateDto {
  final String id;
  final String code;
  final String name;
  final String type;
  final bool mandatory;

  CategoryTemplateDto({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.mandatory,
  });

  factory CategoryTemplateDto.fromJson(Map<String, dynamic> json) => CategoryTemplateDto(
    id: json['id'] as String,
    code: json['code'] as String,
    name: json['name'] as String,
    type: json['type'] as String,
    mandatory: json['mandatory'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'type': type,
    'mandatory': mandatory,
  };
}
