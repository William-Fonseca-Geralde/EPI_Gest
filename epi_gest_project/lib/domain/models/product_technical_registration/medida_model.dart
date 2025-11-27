import 'package:epi_gest_project/domain/models/appwrite_model.dart';

class MedidaModel extends AppWriteModel {
  final String nomeMedida;
  final bool status;

  MedidaModel({super.id, required this.nomeMedida, this.status = true});

  factory MedidaModel.fromMap(Map<String, dynamic> map) {
    return MedidaModel(
      id: map['\$id'],
      nomeMedida: map['nome_medida'],
      status: map['status'] ?? true,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {'nome_medida': nomeMedida, 'status': status,};
  }
}
