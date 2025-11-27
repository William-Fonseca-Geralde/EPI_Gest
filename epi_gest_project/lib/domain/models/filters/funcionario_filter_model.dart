class FuncionarioFilterModel {
  final String? matricula;
  final String? nome;
  final List<String>? status;
  final DateTime? dataEntrada;
  final List<String>? mapeamentos;

  const FuncionarioFilterModel({
    this.matricula,
    this.nome,
    this.status,
    this.dataEntrada,
    this.mapeamentos,
  });

  factory FuncionarioFilterModel.empty() {
    return const FuncionarioFilterModel();
  }

  bool get isEmpty {
    return (matricula == null || matricula!.isEmpty) &&
        (nome == null || nome!.isEmpty) &&
        (status == null || status!.isEmpty) &&
        dataEntrada == null &&
        (mapeamentos == null || mapeamentos!.isEmpty);
  }

  int get activeFiltersCount {
    int count = 0;
    if (matricula != null && matricula!.isNotEmpty) count++;
    if (nome != null && nome!.isNotEmpty) count++;
    if (status != null && status!.isNotEmpty) count++;
    if (dataEntrada != null) count++;
    if (mapeamentos != null && mapeamentos!.isNotEmpty) count++;
    return count;
  }

  FuncionarioFilterModel copyWith({
    String? matricula,
    String? nome,
    List<String>? status,
    DateTime? dataEntrada,
    List<String>? mapeamentos,
  }) {
    return FuncionarioFilterModel(
      matricula: matricula ?? this.matricula,
      nome: nome ?? this.nome,
      status: status ?? this.status,
      dataEntrada: dataEntrada ?? this.dataEntrada,
      mapeamentos: mapeamentos ?? this.mapeamentos,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      if (matricula != null && matricula!.isNotEmpty) 'matricula': matricula,
      if (nome != null) 'nome': nome,
      if (status != null && status!.isNotEmpty) 'status': status,
      if (nome != null && nome!.isNotEmpty) 'nome': nome,
      if (dataEntrada != null) 'dataEntrada': dataEntrada,
      if (mapeamentos != null && mapeamentos!.isNotEmpty) 'mapeamentos': mapeamentos,
    };
  }

  factory FuncionarioFilterModel.fromMap(Map<String, dynamic> map) {
    return FuncionarioFilterModel(
      matricula: map['matricula'],
      nome: map['nome'],
      status: map['status'] != null ? List<String>.from(map['status']) : null,
      dataEntrada: map['dataEntrada'],
      mapeamentos: map['mapeamentos'] != null ? List<String>.from(map['mapeamentos']) : null
    );
  }
}