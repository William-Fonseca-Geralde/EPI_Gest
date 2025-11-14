class Role {
  String id;
  String codigo;
  String descricao;

  Role({
    required this.id,
    required this.codigo,
    required this.descricao,
  });

  Role copyWith({
    String? id,
    String? codigo,
    String? descricao,
  }) {
    return Role(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      descricao: descricao ?? this.descricao,
    );
  }
}
