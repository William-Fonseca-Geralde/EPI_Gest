import 'package:epi_gest_project/domain/models/appwrite_model.dart';

class MedidaModel extends AppWriteModel {
  final String nomeMedida;

  MedidaModel({super.id, required this.nomeMedida});

  factory MedidaModel.fromMap(Map<String, dynamic> map) {
    return MedidaModel(id: map['\$id'], nomeMedida: map['nome_medida']);
  }

  @override
  Map<String, dynamic> toMap() {
    return {'nome_medida': nomeMedida};
  }
}
