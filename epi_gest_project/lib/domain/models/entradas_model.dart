import 'package:epi_gest_project/domain/models/appwrite_model.dart';
import 'package:epi_gest_project/domain/models/entradas_epi_model.dart';
import 'package:epi_gest_project/domain/models/product_technical_registration/fornecedor_model.dart';

class EntradasModel extends AppWriteModel {
  final String nfReferente;
  final FornecedorModel fornecedorId;
  final List<EntradasEpiModel> entradasId;
  final DateTime dataEntrada;

  EntradasModel({
    super.id,
    super.createdAt,
    required this.nfReferente,
    required this.fornecedorId,
    required this.entradasId,
    required this.dataEntrada,
  });

  factory EntradasModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? getData(dynamic data) {
      if (data == null) return null;
      if (data is Map<String, dynamic>) return data;
      if (data is List && data.isNotEmpty)
        return data.first as Map<String, dynamic>;
      return null;
    }

    final fornecedorData = getData(map['fornecedor_id']);

    final fornecedorObj = fornecedorData != null
        ? FornecedorModel.fromMap(fornecedorData)
        : FornecedorModel(id: '', cnpj: '', nomeFornecedor: '', endereco: '');

    List<EntradasEpiModel> parseEpis(dynamic data) {
      if (data == null || data is! List) return [];

      return data
          .whereType<Map<String, dynamic>>()
          .map((item) => EntradasEpiModel.fromMap(item))
          .toList();
    }

    return EntradasModel(
      id: map['\$id'],
      nfReferente: map['nf_ref'],
      fornecedorId: fornecedorObj,
      entradasId: parseEpis(map['entradas_epi_id']),
      dataEntrada: DateTime.parse(map['data_entrada'])
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'nf_ref': nfReferente,
      'fornecedor_id': fornecedorId.id,
      'entradas_epi_id': entradasId
          .map((epi) => epi.id)
          .where((id) => id != null && id.isNotEmpty)
          .toList(),
      'data_entrada': dataEntrada.toIso8601String()
    };
  }
}
