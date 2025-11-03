class EpiModel {
  final String id;
  final String nome;
  final String ca; // Certificado de Aprovação
  final String categoria;
  final int quantidadeEstoque;
  final double valorUnitario;
  final DateTime dataValidade;
  final String fornecedor;
  final String descricao;

  EpiModel({
    required this.id,
    required this.nome,
    required this.ca,
    required this.categoria,
    required this.quantidadeEstoque,
    required this.valorUnitario,
    required this.dataValidade,
    required this.fornecedor,
    required this.descricao,
  });

  // Verifica se o EPI está vencido
  bool get isVencido => DateTime.now().isAfter(dataValidade);

  // Verifica se o EPI está próximo do vencimento (30 dias)
  bool get isProximoVencimento {
    final diasParaVencimento = dataValidade.difference(DateTime.now()).inDays;
    return diasParaVencimento <= 30 && diasParaVencimento > 0;
  }

  // Status do EPI baseado na validade
  String get status {
    if (isVencido) return 'Vencido';
    if (isProximoVencimento) return 'Próximo ao Vencimento';
    return 'Regular';
  }

  factory EpiModel.fromJson(Map<String, dynamic> json) {
    return EpiModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      ca: json['ca'] as String,
      categoria: json['categoria'] as String,
      quantidadeEstoque: json['quantidadeEstoque'] as int,
      valorUnitario: (json['valorUnitario'] as num).toDouble(),
      dataValidade: DateTime.parse(json['dataValidade'] as String),
      fornecedor: json['fornecedor'] as String,
      descricao: json['descricao'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'ca': ca,
      'categoria': categoria,
      'quantidadeEstoque': quantidadeEstoque,
      'valorUnitario': valorUnitario,
      'dataValidade': dataValidade.toIso8601String(),
      'fornecedor': fornecedor,
      'descricao': descricao,
    };
  }
}
