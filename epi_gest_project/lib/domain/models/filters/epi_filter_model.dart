class EpiFilterModel {
  final List<String>? validades;
  final String? ca;
  final List<String>? categorias;
  final String? nome;
  final List<String>? marcas;
  final num? quantidade;
  final String? quantidadeOperador;
  final num? valor;
  final String? valorOperador;

  const EpiFilterModel({
    this.validades,
    this.ca,
    this.categorias,
    this.nome,
    this.marcas,
    this.quantidade,
    this.quantidadeOperador,
    this.valor,
    this.valorOperador,
  });

  factory EpiFilterModel.empty() {
    return const EpiFilterModel();
  }

  bool get isEmpty {
    return (validades == null || validades!.isEmpty) &&
        ca == null &&
        (categorias == null || categorias!.isEmpty) &&
        nome == null &&
        (marcas == null || marcas!.isEmpty) &&
        quantidade == null &&
        valor == null;
  }

  int get activeFiltersCount {
    int count = 0;
    if (validades != null && validades!.isNotEmpty) count++;
    if (ca != null && ca!.isNotEmpty) count++;
    if (categorias != null && categorias!.isNotEmpty) count++;
    if (nome != null && nome!.isNotEmpty) count++;
    if (marcas != null && marcas!.isNotEmpty) count++;
    if (quantidade != null) count++;
    if (valor != null) count++;
    return count;
  }

  EpiFilterModel copyWith({
    List<String>? validades,
    String? ca,
    List<String>? categorias,
    String? nome,
    List<String>? marcas,
    num? quantidade,
    String? quantidadeOperador,
    num? valor,
    String? valorOperador,
  }) {
    return EpiFilterModel(
      validades: validades ?? this.validades,
      ca: ca ?? this.ca,
      categorias: categorias ?? this.categorias,
      nome: nome ?? this.nome,
      marcas: marcas ?? this.marcas,
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
      if (marcas != null && marcas!.isNotEmpty)
        'marcas': marcas,
      if (quantidade != null) 'quantidade': quantidade,
      if (quantidadeOperador != null) 'quantidadeOperador': quantidadeOperador,
      if (valor != null) 'valor': valor,
      if (valorOperador != null) 'valorOperador': valorOperador,
    };
  }

  factory EpiFilterModel.fromMap(Map<String, dynamic> map) {
    return EpiFilterModel(
      validades: map['validades'] != null
          ? List<String>.from(map['validades'])
          : null,
      ca: map['ca'],
      categorias: map['categorias'] != null
          ? List<String>.from(map['categorias'])
          : null,
      nome: map['nome'],
      marcas: map['marcas'] != null
          ? List<String>.from(map['marcas'])
          : null,
      quantidade: map['quantidade'],
      quantidadeOperador: map['quantidadeOperador'],
      valor: map['valor'],
      valorOperador: map['valorOperador'],
    );
  }
}
