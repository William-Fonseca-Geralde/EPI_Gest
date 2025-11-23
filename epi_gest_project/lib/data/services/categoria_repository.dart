import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/core/constants/appwrite_constants.dart';
import 'package:epi_gest_project/data/services/base_repository.dart';
import 'package:epi_gest_project/domain/models/categoria_model.dart';

class CategoriaRepository extends BaseRepository<CategoriaModel> {
  CategoriaRepository(TablesDB databases)
      : super(databases, AppwriteConstants.databaseCategoria);

  @override
  CategoriaModel fromMap(Map<String, dynamic> map) {
    return CategoriaModel.fromMap(map);
  }

  Future<List<CategoriaModel>> getAllCategorias() async {
    return await getAll([]);
  }
}