import 'package:epi_gest_project/domain/models/appwrite_model.dart';
import 'package:epi_gest_project/domain/models/epi_model.dart';
import 'package:epi_gest_project/domain/models/product_technical_registration/categoria_model.dart';
import 'package:epi_gest_project/domain/models/product_technical_registration/marcas_model.dart';
import 'package:epi_gest_project/domain/models/product_technical_registration/medida_model.dart';

class EntradasEpiModel extends AppWriteModel {
  final EpiModel epi;
  final int quantidade;
  final double valor;

  EntradasEpiModel({
    super.id,
    required this.epi,
    required this.quantidade,
    required this.valor,
  });

  factory EntradasEpiModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? getData(dynamic data) {
      if (data == null) return null;
      if (data is Map<String, dynamic>) return data;
      if (data is List && data.isNotEmpty)
        return data.first as Map<String, dynamic>;
      return null;
    }

    final epiData = getData(map['epi_id']);

    final epiObj = epiData != null
        ? EpiModel.fromMap(epiData)
        : EpiModel(
            ca: '',
            nomeProduto: '',
            validadeCa: DateTime.now(),
            periodicidade: 0,
            estoque: 0,
            valor: 0,
            marca: MarcasModel(nomeMarca: ''),
            categoria: CategoriaModel(codigoCategoria: '', nomeCategoria: ''),
            medida: MedidaModel(nomeMedida: ''),
          );

    return EntradasEpiModel(
      id: map['\$id'],
      epi: epiObj,
      quantidade: map['quantidade'],
      valor: map['valor'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {'epi_id': epi.id, 'quantidade': quantidade, 'valor': valor};
  }
}
