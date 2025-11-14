class Department {
  String? id;
  String codigo;
  String descricao;
  String unidade;

  Department({
    this.id,
    required this.codigo,
    required this.descricao,
    required this.unidade,
  });

  Department copyWith({
    String? id,
    String? codigo,
    String? descricao,
    String? unidade,
  }) {
    return Department(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      descricao: descricao ?? this.descricao,
      unidade: unidade ?? this.unidade,
    );
  }
}