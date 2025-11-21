import 'package:epi_gest_project/domain/models/appwrite_model.dart';

class FuncionarioEpiModel extends AppWriteModel {
  final String funcionarioId;
  final String mapeamentoId;
  final List<String> listEpis;

  FuncionarioEpiModel({
    super.id,
    required this.funcionarioId,
    required this.mapeamentoId,
    required this.listEpis,
  });

  factory FuncionarioEpiModel.fromMap(Map<String, dynamic> map) {
    return FuncionarioEpiModel(
      id: map['\$id'],
      funcionarioId: map['funcionario_id'],
      mapeamentoId: map['mapeamento_id'],
      listEpis: map['list_epis'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'funcionario_id': funcionarioId,
      'mapeamento_id': mapeamentoId,
      'list_epis': listEpis
    };
  }
}
