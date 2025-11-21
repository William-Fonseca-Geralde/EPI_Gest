import 'package:epi_gest_project/domain/models/appwrite_model.dart';
import 'package:flutter/material.dart';

class TurnoModel extends AppWriteModel {
  final String turno;
  final TimeOfDay horaEntrada;
  final TimeOfDay horaSaida;
  final TimeOfDay inicioAlmoco;
  final TimeOfDay fimAlomoco;

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
