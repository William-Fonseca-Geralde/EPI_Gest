class Risk {
  String id;
  String codigo;
  String descricao;

  Risk({
    required this.id,
    required this.codigo,
    required this.descricao,
  });
  
  Risk copyWith({
    String? id,
    String? codigo,
    String? descricao,
  }) {
    return Risk(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      descricao: descricao ?? this.descricao,
    );
  }
}
