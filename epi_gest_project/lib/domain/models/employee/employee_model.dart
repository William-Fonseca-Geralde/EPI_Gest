import 'package:appwrite/models.dart';

class Employee {
  final String? id;
  final String matricula;
  final String nome;
  final String? cpf;
  final String? rg;
  final String? setor;
  final String? cargo;
  final String? vinculo;
  final DateTime dataEntrada;
  final DateTime? dataNascimento;
  final String? telefone;
  final String? email;
  final List<String> epis;
  final List<String> riscos;
  final String? lider;
  final String? gestor;
  final String? localTrabalho;
  final String? turno;
  final bool statusAtivo;
  final bool statusFerias;
  final DateTime? dataRetornoFerias;
  final DateTime? dataDesligamento;
  final String? motivoDesligamento;
  final String? imagemPath;

  Employee({
    this.id,
    required this.matricula,
    required this.nome,
    this.cpf,
    this.rg,
    this.setor,
    this.cargo,
    this.vinculo,
    required this.dataEntrada,
    this.dataNascimento,
    this.telefone,
    this.email,
    required this.epis,
    required this.riscos,
    this.lider,
    this.gestor,
    this.localTrabalho,
    this.turno,
    required this.statusAtivo,
    required this.statusFerias,
    this.dataRetornoFerias,
    this.dataDesligamento,
    this.motivoDesligamento,
    this.imagemPath,
  });

  // Converte um objeto Employee para um Map (JSON) para enviar ao Appwrite
  Map<String, dynamic> toJson() {
    return {
      'matricula': matricula,
      'nome': nome,
      'cpf': cpf,
      'rg': rg,
      'dataNascimento': dataNascimento?.toIso8601String(),
      'dataEntrada': dataEntrada.toIso8601String(),
      'telefone': telefone,
      'email': email,
      'setor': setor,
      'cargo': cargo,
      'vinculo': vinculo,
      'lider': lider,
      'gestor': gestor,
      'localTrabalho': localTrabalho,
      'turno': turno,
      'epis': epis,
      'riscos': riscos,
      'imagemPath': imagemPath,
      'statusAtivo': statusAtivo,
      'statusFerias': statusFerias,
      'dataRetornoFerias': dataRetornoFerias?.toIso8601String(),
      'dataDesligamento': dataDesligamento?.toIso8601String(),
      'motivoDesligamento': motivoDesligamento,
    };
  }

  // Cria um objeto Employee a partir de um Documento do Appwrite
  factory Employee.fromAppwrite(Row row) {
    final data = row.data;
    return Employee(
      id: row.$id,
      matricula: data['matricula'],
      nome: data['nome'],
      cpf: data['cpf'],
      rg: data['rg'],
      dataNascimento: data['dataNascimento'] != null ? DateTime.parse(data['dataNascimento']) : null,
      dataEntrada: DateTime.parse(data['dataEntrada']),
      telefone: data['phone'],
      email: data['email'],
      setor: data['setor'],
      cargo: data['cargo'],
      vinculo: data['vinculo'],
      lider: data['nomeLider'],
      gestor: data['nomeGestor'],
      localTrabalho: data['localTrabalho'],
      turno: data['turno'],
      epis: List<String>.from(data['epis'] ?? []),
      riscos: List<String>.from(data['riscos'] ?? []),
      imagemPath: data['urlImagem'],
      statusAtivo: data['ativo'],
      statusFerias: data['ferias'],
      dataRetornoFerias: data['dataRetornoFerias'] != null ? DateTime.parse(data['dataRetornoFerias']) : null,
      dataDesligamento: data['dataTermino'] != null ? DateTime.parse(data['dataTermino']) : null,
      motivoDesligamento: data['motivosTermino'],
    );
  }

  bool isValid() {
    return id != null &&
        id!.isNotEmpty &&
        matricula != null &&
        matricula!.isNotEmpty &&
        nome != null &&
        nome!.isNotEmpty &&
        dataEntrada != null;
  }
}
