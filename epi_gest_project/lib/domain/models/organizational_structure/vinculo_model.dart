import 'package:epi_gest_project/domain/models/appwrite_model.dart';

class VinculoModel extends AppWriteModel {
  final String nomeVinculo;
  final bool status;

  VinculoModel({
    super.id,
    required this.nomeVinculo,
    this.status = true,
  });

  factory VinculoModel.fromMap(Map<String, dynamic> map) {
    return VinculoModel(
      id: map['\$id'],
      nomeVinculo: map['nome_vinc'],
      status: map['status'] ?? true,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'nome_vinc': nomeVinculo,
      'status': status,
    };
  }
}
