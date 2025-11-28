import 'package:epi_gest_project/domain/models/epi_model.dart';
import 'package:epi_gest_project/domain/models/organizational_structure/cargo_model.dart';
import 'package:epi_gest_project/domain/models/organizational_structure/riscos_model.dart';
import 'package:epi_gest_project/domain/models/organizational_structure/setor_model.dart';

import '../appwrite_model.dart';

class MapeamentoEpiModel extends AppWriteModel {
  final String codigoMapeamento;
  final String nomeMapeamento;
  final CargoModel cargo;
  final SetorModel setor;
  final List<RiscosModel> riscos;
  final List<EpiModel> epis;
  final bool status;

  MapeamentoEpiModel({
    super.id,
    required this.codigoMapeamento,
    required this.nomeMapeamento,
    required this.cargo,
    required this.setor,
    required this.riscos,
    required this.epis,
    this.status = true,
  });

  factory MapeamentoEpiModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? getData(dynamic data) {
      if (data == null) return null;
      if (data is Map<String, dynamic>) return data;
      if (data is List && data.isNotEmpty)
        return data.first as Map<String, dynamic>;
      return null;
    }

    final cargoData = getData(map['cargo_id']);
    final cargoObj = cargoData != null
        ? CargoModel.fromMap(cargoData)
        : CargoModel(id: '', codigoCargo: '', nomeCargo: '');

    final setorData = getData(map['setor_id']);
    final setorObj = setorData != null
        ? SetorModel.fromMap(setorData)
        : SetorModel(id: '', codigoSetor: '', nomeSetor: '');

    List<RiscosModel> parseRiscos(dynamic data) {
      if (data == null || data is! List) return [];

      return data
          .whereType<Map<String, dynamic>>()
          .map((item) => RiscosModel.fromMap(item))
          .toList();
    }

    List<EpiModel> parseEpis(dynamic data) {
      if (data == null || data is! List) return [];

      return data
          .whereType<Map<String, dynamic>>()
          .map((item) => EpiModel.fromMap(item))
          .toList();
    }

    return MapeamentoEpiModel(
      id: map['\$id'],
      codigoMapeamento: map['codigo_mapeamento'] ?? '',
      nomeMapeamento: map['nome_mapeamento'] ?? '',
      cargo: cargoObj,
      setor: setorObj,
      riscos: parseRiscos(map['riscos_ids']),
      epis: parseEpis(map['epi_ids']),
      status: map['status'] ?? true,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final epi = epis
        .map((categ) => categ.id)
        .where((id) => id != null && id.isNotEmpty)
        .toList();

    final risco = riscos
        .map((risco) => risco.id)
        .where((id) => id != null && id.isNotEmpty)
        .toList();
    return {
      'codigo_mapeamento': codigoMapeamento,
      'nome_mapeamento': nomeMapeamento,
      'cargo_id': cargo.id,
      'setor_id': setor.id,
      'riscos_ids': risco,
      'epi_ids': epi,
      'status': status,
    };
  }
}
