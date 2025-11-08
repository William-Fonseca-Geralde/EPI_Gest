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
      'setor_id': [
        {'nomeSetor': setor},
      ],
      'cargo_id': [
        {'nomeCargo': cargo},
      ],
      'vinculo_id': [
        {'nomeVinculo': vinculo},
      ],
      'nomeLider': lider,
      'nomeGestor': gestor,
      'localTrabalho': localTrabalho,
      'turno_id': [
        {'nomeTurno': turno},
      ],
      'epis': epis,
      'riscos': riscos,
      'urlImagem': imagemPath,
      'ativo': statusAtivo,
      'ferias': statusFerias,
      'dataTermino': dataDesligamento?.toIso8601String(),
      'dataRetornoFerias': dataRetornoFerias?.toIso8601String(),
      'motivosTermino': motivoDesligamento,
    };
  }

  factory Employee.fromAppwrite(Row row) {
    final data = row.data;
    return Employee(
      id: row.$id,
      matricula: data['matricula'],
      nome: data['nome'],
      cpf: data['cpf'],
      rg: data['rg'],
      dataNascimento: data['dataNascimento'] != null
          ? DateTime.parse(data['dataNascimento'])
          : null,
      dataEntrada: DateTime.parse(data['dataEntrada']),
      telefone: data['telefone'],
      email: data['email'],
      setor: data['setor_id'][0]['nomeSetor'],
      cargo: data['cargo_id'][0]['nomeCargo'],
      vinculo: data['vinculo_id'][0]['nomeVinculo'],
      lider: data['nomeLider'],
      gestor: data['nomeGestor'],
      localTrabalho: data['localTrabalho'],
      turno: data['turno_id'][0]['nomeTurno'],
      epis: List<String>.from(data['epis'] ?? []),
      riscos: List<String>.from(data['riscos'] ?? []),
      imagemPath: data['urlImagem'],
      statusAtivo: data['ativo'],
      statusFerias: data['ferias'],
      dataRetornoFerias: data['dataRetornoFerias'] != null
          ? DateTime.parse(data['dataRetornoFerias'])
          : null,
      dataDesligamento: data['dataTermino'] != null
          ? DateTime.parse(data['dataTermino'])
          : null,
      motivoDesligamento: data['motivosTermino'],
    );
  }
}

class Cargo {
  final String? id;
  final String nome;

  Cargo({this.id, required this.nome});

  Map<String, dynamic> toJson() {
    return {'id': id, 'nome': nome};
  }

  factory Cargo.fromAppwrite(Row row) {
    final data = row.data;
    return Cargo(id: row.$id, nome: data['nomeCargo']);
  }
}

class Setor {
  final String? id;
  final String nome;

  Setor({this.id, required this.nome});

  Map<String, dynamic> toJson() {
    return {'id': id, 'nome': nome};
  }

  factory Setor.fromAppwrite(Row row) {
    final data = row.data;
    return Setor(id: row.$id, nome: data['nomeSetor']);
  }
}

class Turno {
  final String? id;
  final String nome;

  Turno({this.id, required this.nome});

  Map<String, dynamic> toJson() {
    return {'id': id, 'nome': nome};
  }

  factory Turno.fromAppwrite(Row row) {
    final data = row.data;
    return Turno(id: row.$id, nome: data['nomeTurno']);
  }
}

class Vinculo {
  final String? id;
  final String nome;

  Vinculo({this.id, required this.nome});

  Map<String, dynamic> toJson() {
    return {'id': id, 'nome': nome};
  }

  factory Vinculo.fromAppwrite(Row row) {
    final data = row.data;
    return Vinculo(id: row.$id, nome: data['nomeVinculo']);
  }
}
