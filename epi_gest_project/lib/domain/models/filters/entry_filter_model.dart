class EntryFilterModel {
  final String? notaFiscal;
  final String? fornecedor;
  final String? produto;
  final DateTime? dataInicio;
  final DateTime? dataFim;

  const EntryFilterModel({
    this.notaFiscal,
    this.fornecedor,
    this.produto,
    this.dataInicio,
    this.dataFim,
  });

  factory EntryFilterModel.empty() {
    return const EntryFilterModel();
  }

  bool get isEmpty {
    return (notaFiscal == null || notaFiscal!.isEmpty) &&
        (fornecedor == null || fornecedor!.isEmpty) &&
        (produto == null || produto!.isEmpty) &&
        dataInicio == null &&
        dataFim == null;
  }

  int get activeFiltersCount {
    int count = 0;
    if (notaFiscal != null && notaFiscal!.isNotEmpty) count++;
    if (fornecedor != null && fornecedor!.isNotEmpty) count++;
    if (produto != null && produto!.isNotEmpty) count++;
    if (dataInicio != null) count++;
    if (dataFim != null) count++;
    return count;
  }

  EntryFilterModel copyWith({
    String? notaFiscal,
    String? fornecedor,
    String? produto,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) {
    return EntryFilterModel(
      notaFiscal: notaFiscal ?? this.notaFiscal,
      fornecedor: fornecedor ?? this.fornecedor,
      produto: produto ?? this.produto,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (notaFiscal != null) 'nf_ref': notaFiscal,
      if (fornecedor != null) 'fornecedor': fornecedor,
      if (produto != null) 'produto': produto,
      if (dataInicio != null) 'data_inicio': dataInicio,
      if (dataFim != null) 'data_fim': dataFim,
    };
  }

  factory EntryFilterModel.fromMap(Map<String, dynamic> map) {
    return EntryFilterModel(
      notaFiscal: map['nf_ref'],
      fornecedor: map['fornecedor'],
      produto: map['produto'],
      dataInicio: map['data_inicio'],
      dataFim: map['data_fim'],
    );
  }
}