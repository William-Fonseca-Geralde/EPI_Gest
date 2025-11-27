import 'package:epi_gest_project/domain/models/appwrite_model.dart';

class CargoModel extends AppWriteModel {
  final String codigoCargo;
  final String nomeCargo;

  CargoModel({super.id, required this.codigoCargo, required this.nomeCargo});

  factory CargoModel.fromMap(Map<String, dynamic> map) {
    return CargoModel(
      id: map['\$id'],
      codigoCargo: map['codigo_cargo'],
      nomeCargo: map['nome_cargo'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {'codigo_cargo': codigoCargo, 'nome_cargo': nomeCargo};
  }
}
