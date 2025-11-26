import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/core/constants/appwrite_constants.dart';
import 'package:epi_gest_project/data/services/base_repository.dart';
import 'package:epi_gest_project/domain/models/medida_model.dart';

class MedidaRepository extends BaseRepository<MedidaModel> {
  MedidaRepository(TablesDB databases)
      : super(databases, AppwriteConstants.databaseMedida);

  @override
  MedidaModel fromMap(Map<String, dynamic> map) {
    return MedidaModel.fromMap(map);
  }

  Future<List<MedidaModel>> getAllMedidas() async {
    return await getAll([Query.orderAsc('nome_medida')]);
  }
}