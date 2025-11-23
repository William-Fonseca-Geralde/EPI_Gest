import 'package:epi_gest_project/domain/models/appwrite_model.dart';
import 'package:epi_gest_project/domain/models/unidade_model.dart';

class ArmazemModel extends AppWriteModel {
  final String codigoArmazem;
  final UnidadeModel unidade;

  ArmazemModel({super.id, required this.codigoArmazem, required this.unidade});

  factory ArmazemModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? getData(dynamic data) {
      if (data == null) return null;
      if (data is Map<String, dynamic>) return data;
      if (data is List && data.isNotEmpty)
        return data.first as Map<String, dynamic>;
      return null;
    }

    final unidadeData = getData(map['unidade_id']);
    final unidadeObj = unidadeData != null
        ? UnidadeModel.fromMap(unidadeData)
        : UnidadeModel(
            id: '',
            nomeUnidade: '',
            cnpj: '',
            endereco: '',
            tipoUnidade: '',
            status: false
          );

    return ArmazemModel(
      id: map['\$id'],
      codigoArmazem: map['codigo_armazem'],
      unidade: unidadeObj,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {'codigo_armazem': codigoArmazem, 'unidade_id': unidade.id};
  }
}
