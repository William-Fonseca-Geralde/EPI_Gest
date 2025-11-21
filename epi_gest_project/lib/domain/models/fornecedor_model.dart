import 'package:epi_gest_project/domain/models/appwrite_model.dart';

class FornecedorModel extends AppWriteModel {
  final String cnpj;
  final String nomeFornecedor;
  final String endereco;

  FornecedorModel({
    super.id,
    required this.cnpj,
    required this.nomeFornecedor,
    required this.endereco,
  });

  factory FornecedorModel.fromMap(Map<String, dynamic> map) {
    return FornecedorModel(
      id: map['\$id'],
      cnpj: map['cnpj'],
      nomeFornecedor: map['nome_fornecedor'],
      endereco: map['endereco'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'cnpj': cnpj,
      'nome_fornecedor': nomeFornecedor,
      'endereco': endereco,
    };
  }
}
