class InventoryFilterModel {
  final List<String>? validades; // Mudou de String para List<String>
  final String? ca;
  final List<String>? categorias; // Mudou de String para List<String>
  final String? nome;
  final List<String>? fornecedores; // Mudou de String para List<String>
  final num? quantidade;
  final String? quantidadeOperador;
  final num? valor;
  final String? valorOperador;

  const InventoryFilterModel({
    this.validades,
    this.ca,
    this.categorias,
    this.nome,
    this.fornecedores,
    this.quantidade,
    this.quantidadeOperador,
    this.valor,
    this.valorOperador,
  });

  factory InventoryFilterModel.empty() {
    return const InventoryFilterModel();
  }

  bool get isEmpty {
    return (validades == null || validades!.isEmpty) &&
        ca == null &&
        (categorias == null || categorias!.isEmpty) &&
        nome == null &&
        (fornecedores == null || fornecedores!.isEmpty) &&
        quantidade == null &&
        valor == null;
  }

  int get activeFiltersCount {
    int count = 0;
    if (validades != null && validades!.isNotEmpty) count++;
    if (ca != null && ca!.isNotEmpty) count++;
    if (categorias != null && categorias!.isNotEmpty) count++;
    if (nome != null && nome!.isNotEmpty) count++;
    if (fornecedores != null && fornecedores!.isNotEmpty) count++;
    if (quantidade != null) count++;
    if (valor != null) count++;
    return count;
  }

  InventoryFilterModel copyWith({
    List<String>? validades,
    String? ca,
    List<String>? categorias,
    String? nome,
    List<String>? fornecedores,
    num? quantidade,
    String? quantidadeOperador,
    num? valor,
    String? valorOperador,
  }) {
    return InventoryFilterModel(
      validades: validades ?? this.validades,
      ca: ca ?? this.ca,
      categorias: categorias ?? this.categorias,
      nome: nome ?? this.nome,
      fornecedores: fornecedores ?? this.fornecedores,
      quantidade: quantidade ?? this.quantidade,
      quantidadeOperador: quantidadeOperador ?? this.quantidadeOperador,
      valor: valor ?? this.valor,
      valorOperador: valorOperador ?? this.valorOperador,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (validades != null && validades!.isNotEmpty) 'validades': validades,
      if (ca != null) 'ca': ca,
      if (categorias != null && categorias!.isNotEmpty) 'categorias': categorias,
      if (nome != null) 'nome': nome,
      if (fornecedores != null && fornecedores!.isNotEmpty)
        'fornecedores': fornecedores,
      if (quantidade != null) 'quantidade': quantidade,
      if (quantidadeOperador != null) 'quantidadeOperador': quantidadeOperador,
      if (valor != null) 'valor': valor,
      if (valorOperador != null) 'valorOperador': valorOperador,
    };
  }

  factory InventoryFilterModel.fromMap(Map<String, dynamic> map) {
    return InventoryFilterModel(
      validades: map['validades'] != null
          ? List<String>.from(map['validades'])
          : null,
      ca: map['ca'],
      categorias: map['categorias'] != null
          ? List<String>.from(map['categorias'])
          : null,
      nome: map['nome'],
      fornecedores: map['fornecedores'] != null
          ? List<String>.from(map['fornecedores'])
          : null,
      quantidade: map['quantidade'],
      quantidadeOperador: map['quantidadeOperador'],
      valor: map['valor'],
      valorOperador: map['valorOperador'],
    );
  }
}
