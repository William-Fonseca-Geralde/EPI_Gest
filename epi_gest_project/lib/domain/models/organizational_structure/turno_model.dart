import 'package:epi_gest_project/domain/models/appwrite_model.dart';

class TurnoModel extends AppWriteModel {
  final String turno;
  final String horaEntrada;
  final String horaSaida;
  final String inicioAlmoco;
  final String fimAlomoco;

  TurnoModel({
    super.id,
    required this.turno,
    required this.horaEntrada,
    required this.horaSaida,
    required this.inicioAlmoco,
    required this.fimAlomoco,
  });

  factory TurnoModel.fromMap(Map<String, dynamic> map) {
    return TurnoModel(
      id: map['\$id'],
      turno: map['nome_turno'],
      horaEntrada: map['hora_entrada'],
      horaSaida: map['hora_saida'],
      inicioAlmoco: map['inicio_almoc'],
      fimAlomoco: map['fim_almoc'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'nome_turno': turno,
      'hora_entrada': horaEntrada,
      'hora_saida': horaSaida,
      'inicio_almoc': inicioAlmoco,
      'fim_almoc': fimAlomoco,
    };
  }
}
