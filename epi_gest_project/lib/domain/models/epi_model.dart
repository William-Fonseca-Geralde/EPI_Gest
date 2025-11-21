import 'appwrite_model.dart';

class EpiModel extends AppWriteModel {
  final String ca;
  final String nomeProduto;
  final DateTime validadeCa;
  final DateTime validadeProduto;
  final double estoque;
  final double valor;
  final String marcaId;
  final String armazemId;
  final String fornecedorId;
  final String categoriaId;
  final String medidaId;

  EpiModel({
    super.id,
    required this.ca,
    required this.nomeProduto,
    required this.validadeCa,
    required this.validadeProduto,
    required this.estoque,
    required this.valor,
    required this.marcaId,
    required this.armazemId,
    required this.fornecedorId,
    required this.categoriaId,
    required this.medidaId,
  });

  factory EpiModel.fromMap(Map<String, dynamic> map) {
    return EpiModel(
      id: map['\$id'],
      ca: map['ca'] ?? '',
      nomeProduto: map['nome_produto'] ?? '',
      validadeCa: DateTime.parse(map['validade_ca']),
      validadeProduto: DateTime.parse(map['validade_produto']),
      estoque: (map['estoque'] ?? 0).toDouble(),
      valor: (map['valor'] ?? 0).toDouble(),
      marcaId: map['marca_id'] ?? '',
      armazemId: map['armazem_id'] ?? '',
      fornecedorId: map['fornecedor_id'] ?? '',
      categoriaId: map['categoria_id'] ?? '',
      medidaId: map['medida_id'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'ca': ca,
      'nome_produto': nomeProduto,
      'validade_ca': validadeCa.toIso8601String(),
      'validade_produto': validadeProduto.toIso8601String(),
      'estoque': estoque,
      'valor': valor,
      'marca_id': marcaId,
      'armazem_id': armazemId,
      'fornecedor_id': fornecedorId,
      'categoria_id': categoriaId,
      'medida_id': medidaId,
    };
  }
}