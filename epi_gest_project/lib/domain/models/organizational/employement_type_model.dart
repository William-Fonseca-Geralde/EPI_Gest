class EmploymentType {
  String id;
  String codigo;
  String descricao;

  EmploymentType({
    required this.id,
    required this.codigo,
    required this.descricao,
  });

  EmploymentType copyWith({
    String? id,
    String? codigo,
    String? descricao,
  }) {
    return EmploymentType(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      descricao: descricao ?? this.descricao,
    );
  }
}
