class Unit {
  String id;
  String nome;
  String cnpj;
  String endereco;
  String tipo;
  String responsavel;
  bool statusAtiva;

  Unit({
    required this.id,
    required this.nome,
    required this.cnpj,
    required this.endereco,
    required this.tipo,
    required this.responsavel,
    required this.statusAtiva,
  });

  Unit copyWith({
    String? id,
    String? nome,
    String? cnpj,
    String? endereco,
    String? tipo,
    String? responsavel,
    bool? statusAtiva,
  }) {
    return Unit(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cnpj: cnpj ?? this.cnpj,
      endereco: endereco ?? this.endereco,
      tipo: tipo ?? this.tipo,
      responsavel: responsavel ?? this.responsavel,
      statusAtiva: statusAtiva ?? this.statusAtiva,
    );
  }
}
