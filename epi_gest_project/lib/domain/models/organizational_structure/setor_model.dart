import 'package:epi_gest_project/domain/models/appwrite_model.dart';

class SetorModel extends AppWriteModel {
  final String codigoSetor;
  final String nomeSetor;

  SetorModel({
    super.id,
    required this.codigoSetor,
    required this.nomeSetor,
  });

  factory SetorModel.fromMap(Map<String, dynamic> map) {
    
    return SetorModel(
      id: map['\$id'],
      codigoSetor: map['codigo_setor'],
      nomeSetor: map['nome_setor'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'codigo_setor': codigoSetor,
      'nome_setor': nomeSetor,
    };
  }
}
