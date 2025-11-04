class EmployeeFormData {
  String? id;
  String? matricula;
  String? nome;
  String? cpf;
  String? rg;
  String? setor;
  String? funcao;
  String? vinculo;
  DateTime? dataEntrada;
  DateTime? dataNascimento;
  String? telefone;
  String? email;
  List<String> epis;
  String? lider;
  String? gestor;
  String? localTrabalho;
  String? turno;
  bool statusAtivo;
  bool statusFerias;
  DateTime? dataRetornoFerias;
  List<String> riscos;
  DateTime? dataDesligamento;
  String? motivoDesligamento;
  String? imagemPath;

  EmployeeFormData({
    this.id,
    this.matricula,
    this.nome,
    this.cpf,
    this.rg,
    this.setor,
    this.funcao,
    this.vinculo,
    this.dataEntrada,
    this.dataNascimento,
    this.telefone,
    this.email,
    this.epis = const [],
    this.lider,
    this.gestor,
    this.localTrabalho,
    this.turno,
    this.statusAtivo = true,
    this.statusFerias = false,
    this.dataRetornoFerias,
    this.riscos = const [],
    this.dataDesligamento,
    this.motivoDesligamento,
    this.imagemPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'matricula': matricula,
      'nome': nome,
      'cpf': cpf,
      'rg': rg,
      'setor': setor,
      'funcao': funcao,
      'vinculo': vinculo,
      'dataEntrada': dataEntrada,
      'dataNascimento': dataNascimento,
      'telefone': telefone,
      'email': email,
      'epis': epis,
      'lider': lider,
      'gestor': gestor,
      'localTrabalho': localTrabalho,
      'turno': turno,
      'statusAtivo': statusAtivo,
      'statusFerias': statusFerias,
      'dataRetornoFerias': dataRetornoFerias,
      'riscos': riscos,
      'dataDesligamento': dataDesligamento,
      'motivoDesligamento': motivoDesligamento,
      'imagem': imagemPath,
    };
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
