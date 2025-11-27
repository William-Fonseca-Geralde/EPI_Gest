import 'package:epi_gest_project/domain/models/appwrite_model.dart';

class MarcasModel extends AppWriteModel {
  final String nomeMarca;

  MarcasModel({super.id, required this.nomeMarca});

  factory MarcasModel.fromMap(Map<String, dynamic> map) {
    return MarcasModel(id: map['\$id'], nomeMarca: map['nome_marca']);
  }

  @override
  Map<String, dynamic> toMap() {
    return {'nome_marca': nomeMarca};
  }
}
