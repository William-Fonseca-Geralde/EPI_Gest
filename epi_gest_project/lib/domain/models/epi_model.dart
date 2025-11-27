import 'package:epi_gest_project/domain/models/product_technical_registration/categoria_model.dart';
import 'package:epi_gest_project/domain/models/product_technical_registration/marcas_model.dart';
import 'package:epi_gest_project/domain/models/product_technical_registration/medida_model.dart';

import 'appwrite_model.dart';

class EpiModel extends AppWriteModel {
  final String ca;
  final String nomeProduto;
  final DateTime validadeCa;
  final int periodicidade;
  final double estoque;
  final double valor;
  final MarcasModel marca;
  final CategoriaModel categoria;
  final MedidaModel medida;

  EpiModel({
    super.id,
    required this.ca,
    required this.nomeProduto,
    required this.validadeCa,
    required this.periodicidade,
    required this.estoque,
    required this.valor,
    required this.marca,
    required this.categoria,
    required this.medida,
  });

  factory EpiModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? getData(dynamic data) {
      if (data == null) return null;
      if (data is Map<String, dynamic>) return data;
      if (data is List && data.isNotEmpty)
        return data.first as Map<String, dynamic>;
      return null;
    }

    final marcaData = getData(map['marca_id']);
    final categoriaData = getData(map['categoria_id']);
    final medidaData = getData(map['medida_id']);

    final marcaObj = marcaData != null
        ? MarcasModel.fromMap(marcaData)
        : MarcasModel(id: '', nomeMarca: '');

    final categoriaObj = categoriaData != null
        ? CategoriaModel.fromMap(categoriaData)
        : CategoriaModel(id: '', codigoCategoria: '', nomeCategoria: '');

    final medidaObj = medidaData != null
        ? MedidaModel.fromMap(medidaData)
        : MedidaModel(id: '', nomeMedida: '');

    return EpiModel(
      id: map['\$id'],
      ca: map['ca'] ?? '',
      nomeProduto: map['nome_produto'] ?? '',
      validadeCa: DateTime.parse(map['validade_ca']),
      periodicidade: map['periodicidade'] ?? 0,
      estoque: (map['estoque'] ?? 0).toDouble(),
      valor: (map['valor'] ?? 0).toDouble(),
      marca: marcaObj,
      categoria: categoriaObj,
      medida: medidaObj,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'ca': ca,
      'nome_produto': nomeProduto,
      'validade_ca': validadeCa.toIso8601String(),
      'periodicidade': periodicidade,
      'estoque': estoque,
      'valor': valor,
      'marca_id': marca.id,
      'categoria_id': categoria.id,
      'medida_id': medida.id,
    };
  }
}
