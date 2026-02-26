import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ScopeType {
  OWN,
  TENANT,
  CONSOLIDATED,
}

class ScopeState {
  final ScopeType scope;
  final String? targetTenantId;
  final String? tenantName;

  ScopeState({
    required this.scope,
    this.targetTenantId,
    this.tenantName,
  });

  ScopeState copyWith({
    ScopeType? scope,
    String? targetTenantId,
    String? tenantName,
  }) {
    return ScopeState(
      scope: scope ?? this.scope,
      targetTenantId: targetTenantId ?? this.targetTenantId,
      tenantName: tenantName ?? this.tenantName,
    );
  }
}

class ScopeController extends StateNotifier<ScopeState> {
  ScopeController() : super(ScopeState(scope: ScopeType.OWN, tenantName: 'Minhas Contas'));

  void setScope(ScopeType scope, {String? tenantId, String? name}) {
    state = state.copyWith(
      scope: scope,
      targetTenantId: tenantId,
      tenantName: name ?? _getDefaultName(scope),
    );
  }

  String _getDefaultName(ScopeType scope) {
    switch (scope) {
      case ScopeType.OWN:
        return 'Minhas Contas';
      case ScopeType.CONSOLIDATED:
        return 'Consolidação Geral';
      case ScopeType.TENANT:
        return 'Filial';
    }
  }
}

final scopeControllerProvider = StateNotifierProvider<ScopeController, ScopeState>((ref) {
  return ScopeController();
});
