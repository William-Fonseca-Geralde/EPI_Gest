import 'package:flutter/material.dart';

class Shift {
  String id;
  String codigo;
  String nome;
  TimeOfDay entrada;
  TimeOfDay saida;
  TimeOfDay almocoInicio;
  TimeOfDay almocoFim;

  Shift({
    required this.id,
    required this.codigo,
    required this.nome,
    required this.entrada,
    required this.saida,
    required this.almocoInicio,
    required this.almocoFim,
  });

  Shift copyWith({
    String? id,
    String? codigo,
    String? nome,
    TimeOfDay? entrada,
    TimeOfDay? saida,
    TimeOfDay? almocoInicio,
    TimeOfDay? almocoFim,
  }) {
    return Shift(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nome: nome ?? this.nome,
      entrada: entrada ?? this.entrada,
      saida: saida ?? this.saida,
      almocoInicio: almocoInicio ?? this.almocoInicio,
      almocoFim: almocoFim ?? this.almocoFim,
    );
  }
}
