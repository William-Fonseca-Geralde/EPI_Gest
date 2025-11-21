import 'appwrite_model.dart';

class MapeamentoEpiModel extends AppWriteModel {
  final String codigoMapeamento;
  final String cargoId;
  final String setorId;
  final List<String> riscosId;
  final List<String> listCategoriasEpis;

  MapeamentoEpiModel({
    super.id,
    required this.codigoMapeamento,
    required this.cargoId,
    required this.setorId,
    required this.riscosId,
    required this.listCategoriasEpis,
  });

  factory MapeamentoEpiModel.fromMap(Map<String, dynamic> map) {
    return MapeamentoEpiModel(
      id: map['\$id'],
      codigoMapeamento: map['codigo_mapeamento'] ?? '',
      cargoId: map['cargo_id'] ?? '',
      setorId: map['setor_id'] ?? '',
      riscosId: map['riscos_id'] ?? '',
      listCategoriasEpis: map['list_categorias_epis'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'codigo_mapeamento': codigoMapeamento,
      'cargo_id': cargoId,
      'setor_id': setorId,
      'riscos_id': riscosId,
      'list_categorias_epis': listCategoriasEpis,
    };
  }
}