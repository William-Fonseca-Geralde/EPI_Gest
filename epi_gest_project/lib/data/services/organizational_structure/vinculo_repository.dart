import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/core/constants/appwrite_constants.dart';
import 'package:epi_gest_project/data/services/base_repository.dart';
import 'package:epi_gest_project/domain/models/organizational_structure/vinculo_model.dart';

class VinculoRepository extends BaseRepository<VinculoModel> {
  VinculoRepository(TablesDB databases)
      : super(databases, AppwriteConstants.databaseVinculo);

  @override
  VinculoModel fromMap(Map<String, dynamic> map) {
    return VinculoModel.fromMap(map);
  }

  Future<List<VinculoModel>> getAllVinculos() async {
    return await getAll([]);
  }
}