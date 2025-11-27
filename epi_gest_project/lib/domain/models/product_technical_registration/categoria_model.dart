import 'package:epi_gest_project/domain/models/appwrite_model.dart';

class CategoriaModel extends AppWriteModel {
  final String codigoCategoria;
  final String nomeCategoria;
  final bool status;

  CategoriaModel({
    super.id,
    required this.codigoCategoria,
    required this.nomeCategoria,
    this.status = true,
  });

  factory CategoriaModel.fromMap(Map<String, dynamic> map) {
    return CategoriaModel(
      id: map['\$id'],
      codigoCategoria: map['codigo_categ'],
      nomeCategoria: map['nome_categ'],
      status: map['status'] ?? true,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'codigo_categ': codigoCategoria,
      'nome_categ': nomeCategoria,
      'status': status,
    };
  }
}
