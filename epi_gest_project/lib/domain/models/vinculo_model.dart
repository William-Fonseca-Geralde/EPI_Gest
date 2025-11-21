import 'package:epi_gest_project/domain/models/appwrite_model.dart';

class VinculoModel extends AppWriteModel {
  final String codigoVinculo;
  final String nomeVinculo;

  VinculoModel({
    super.id,
    required this.codigoVinculo,
    required this.nomeVinculo,
  });

  factory VinculoModel.fromMap(Map<String, dynamic> map) {
    return VinculoModel(
      id: map['\$id'],
      codigoVinculo: map['codigo_vinc'],
      nomeVinculo: map['nome_vinc'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'codigo_vinc': codigoVinculo,
      'nome_vinc': nomeVinculo
    };
  }
}
