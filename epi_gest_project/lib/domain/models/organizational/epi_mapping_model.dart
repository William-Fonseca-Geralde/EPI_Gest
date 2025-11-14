import 'package:epi_gest_project/domain/models/epi/epi_model.dart';
import 'package:epi_gest_project/domain/models/organizational/risk_model.dart';
import 'package:epi_gest_project/domain/models/organizational/role_model.dart';

class MappedRisk {
  Risk risk;
  List<EpiModel> requiredEpis;

  MappedRisk({required this.risk, required this.requiredEpis});

  MappedRisk copyWith({
    Risk? risk,
    List<EpiModel>? requiredEpis,
  }) {
    return MappedRisk(
      risk: risk ?? this.risk,
      requiredEpis: requiredEpis ?? this.requiredEpis,
    );
  }
}

class EpiMapping {
  String id;
  Role role;
  List<MappedRisk> mappedRisks;

  EpiMapping({
    required this.id,
    required this.role,
    required this.mappedRisks,
  });

  EpiMapping copyWith({
    String? id,
    Role? role,
    List<MappedRisk>? mappedRisks,
  }) {
    return EpiMapping(
      id: id ?? this.id,
      role: role ?? this.role,
      mappedRisks: mappedRisks ?? this.mappedRisks,
    );
  }
}
