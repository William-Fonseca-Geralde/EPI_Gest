import 'package:epi_gest_project/domain/models/appwrite_model.dart';

class ArmazemModel extends AppWriteModel {
  final String codigoArmazem;
  final String unidadeId;

  ArmazemModel({
    super.id,
    required this.codigoArmazem,
    required this.unidadeId,
  });

  factory ArmazemModel.fromMap(Map<String, dynamic> map) {
    return ArmazemModel(
      id: map['\$id'],
      codigoArmazem: map['codigo_armazem'],
      unidadeId: map['unidade_id'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {'codigo_armazem': codigoArmazem, 'unidade_id': unidadeId};
  }
}
