import 'package:epi_gest_project/domain/models/appwrite_model.dart';

class RiscosModel extends AppWriteModel {
  final String codigoRiscos;
  final String nomeRiscos;
  final bool status;

  RiscosModel({
    super.id,
    required this.codigoRiscos,
    required this.nomeRiscos,
    this.status = true,
  });

  factory RiscosModel.fromMap(Map<String, dynamic> map) {
    return RiscosModel(
      id: map['\$id'],
      codigoRiscos: map['codigo_risco'],
      nomeRiscos: map['nome_risco'],
      status: map['status'] ?? true,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'codigo_risco': codigoRiscos,
      'nome_risco': nomeRiscos,
      'status': status,
    };
  }
}
