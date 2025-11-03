enum ReportType {
  epiInventory('Inventário de EPIs', 'Relatório completo do estoque de EPIs'),
  epiExpiring('EPIs Vencendo', 'EPIs próximos do vencimento ou vencidos'),
  employeeEpis('EPIs por Funcionário', 'Relação de EPIs distribuídos por funcionário'),
  employeeList('Lista de Funcionários', 'Cadastro completo de funcionários'),
  epiExchangeHistory('Histórico de Trocas', 'Registro de todas as trocas de EPIs'),
  costAnalysis('Análise de Custos', 'Custo de EPIs por funcionário/departamento'),
  caValidation('Validação de CAs', 'Status de validade dos Certificados de Aprovação'),
  complianceReport('Relatório de Conformidade', 'Verificação de conformidade NR-6');

  final String title;
  final String description;

  const ReportType(this.title, this.description);
}

enum ReportFormat {
  pdf('PDF', 'Portable Document Format'),
  excel('Excel', 'Planilha Microsoft Excel (.xlsx)'),
  csv('CSV', 'Valores Separados por Vírgula');

  final String title;
  final String description;

  const ReportFormat(this.title, this.description);
}

class ReportFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? companyId;
  final String? departmentId;
  final List<String>? employeeIds;
  final List<String>? epiCategories;
  final bool? includeInactive;

  const ReportFilter({
    this.startDate,
    this.endDate,
    this.companyId,
    this.departmentId,
    this.employeeIds,
    this.epiCategories,
    this.includeInactive,
  });

  ReportFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? companyId,
    String? departmentId,
    List<String>? employeeIds,
    List<String>? epiCategories,
    bool? includeInactive,
  }) {
    return ReportFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      companyId: companyId ?? this.companyId,
      departmentId: departmentId ?? this.departmentId,
      employeeIds: employeeIds ?? this.employeeIds,
      epiCategories: epiCategories ?? this.epiCategories,
      includeInactive: includeInactive ?? this.includeInactive,
    );
  }
}

class ReportRequest {
  final ReportType type;
  final ReportFormat format;
  final ReportFilter filter;
  final DateTime requestedAt;

  const ReportRequest({
    required this.type,
    required this.format,
    required this.filter,
    required this.requestedAt,
  });
}
