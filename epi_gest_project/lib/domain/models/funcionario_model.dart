import 'package:epi_gest_project/domain/models/employee/employee_model.dart';

import 'appwrite_model.dart';

class FuncionarioModel extends AppWriteModel {
  final String matricula;
  final String nomeFunc;
  final DateTime dataEntrada;
  final String email;
  final String telefone;
  final Turno turno;
  final Vinculo vinculo;
  final String lider;
  final String gestor;
  final bool statusAtivo;
  final bool statusFerias;
  final DateTime? dataRetornoFerias;
  final DateTime? dataDesligamento;
  final String? motivoDesligamento;
  final String? imagemPath;

  FuncionarioModel({
    super.id,
    required this.matricula,
    required this.nomeFunc,
    required this.dataEntrada,
    required this.telefone,
    required this.email,
    required this.turno,
    required this.vinculo,
    required this.lider,
    required this.gestor,
    required this.statusAtivo,
    required this.statusFerias,
    this.dataRetornoFerias,
    this.dataDesligamento,
    this.motivoDesligamento,
    this.imagemPath,
    super.createdAt,
    super.updatedAt,
  });

  factory FuncionarioModel.fromMap(Map<String, dynamic> map) {
    return FuncionarioModel(
      id: map['\$id'],
      matricula: map['matricula'] ?? '',
      nomeFunc: map['nome_func'] ?? '',
      dataEntrada: DateTime.parse(map['data_entrada']),
      telefone: map['telefone'] ?? '',
      email: map['email'] ?? '',
      turno: map['turno_id'][0]['nome_turno'] ?? '',
      vinculo: map['vinculo_id'][0]['nome_vinc'] ?? '',
      lider: map['lider'] ?? '',
      gestor: map['gestor'] ?? '',
      statusAtivo: map['status_ativo'] ?? true,
      statusFerias: map['status_ferias'] ?? false,
      dataRetornoFerias: map['data_retorno_ferias'] != null ? DateTime.parse(map['data_retorno_ferias']) : null,
      dataDesligamento: map['data_desligamento'] != null ? DateTime.parse(map['data_desligamento']) : null,
      motivoDesligamento: map['motivo_desligamento'],
      imagemPath: map['urlImagem'],
      createdAt: map['\$createdAt'],
      updatedAt: map['\$updatedAt'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'matricula': matricula,
      'nome_func': nomeFunc,
      'data_entrada': dataEntrada.toIso8601String(),
      'telefone': telefone,
      'email': email,
      'turno_id': turno.id,
      'vinculo_id': vinculo.id,
      'lider': lider,
      'gestor': gestor,
      'status_ativo': statusAtivo,
      'status_ferias': statusFerias,
      'data_retorno_ferias': dataRetornoFerias?.toIso8601String(),
      'data_desligamento': dataDesligamento?.toIso8601String(),
      'motivo_desligamento': motivoDesligamento,
    };
  }
}