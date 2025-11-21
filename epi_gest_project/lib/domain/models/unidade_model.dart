import 'package:epi_gest_project/domain/models/appwrite_model.dart';

enum Tipo { matriz, filial }

class UnidadeModel extends AppWriteModel {
  final String nomeUnidade;
  final String cnpj;
  final String endereco;
  final Tipo tipoUnidade;

  UnidadeModel({
    super.id,
    required this.nomeUnidade,
    required this.cnpj,
    required this.endereco,
    required this.tipoUnidade,
  });

  factory UnidadeModel.fromMap(Map<String, dynamic> map) {
    return UnidadeModel(
      id: map['\$id'],
      nomeUnidade: map['nome_unidad'],
      cnpj: map['cnpj'],
      endereco: map['endereco'],
      tipoUnidade: map['tipo_unidad'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'nome_unidad': nomeUnidade,
      'cnpj': cnpj,
      'endereco': endereco,
      'tipo_unidad': tipoUnidade
    };
  }
}
