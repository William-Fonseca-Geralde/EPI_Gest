import 'package:epi_gest_project/domain/models/appwrite_model.dart';


class UnidadeModel extends AppWriteModel {
  final String nomeUnidade;
  final String cnpj;
  final String endereco;
  final String tipoUnidade;
  final bool status;

  UnidadeModel({
    super.id,
    required this.nomeUnidade,
    required this.cnpj,
    required this.endereco,
    required this.tipoUnidade,
    required this.status,
  });

  factory UnidadeModel.fromMap(Map<String, dynamic> map) {
    return UnidadeModel(
      id: map['\$id'],
      nomeUnidade: map['nome_unidad'],
      cnpj: map['cnpj'],
      endereco: map['endereco'],
      tipoUnidade: map['tipo_unidad'],
      status: map['status'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'nome_unidad': nomeUnidade,
      'cnpj': cnpj,
      'endereco': endereco,
      'tipo_unidad': tipoUnidade,
      'status': status
    };
  }
}
