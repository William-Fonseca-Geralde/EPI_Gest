import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/core/constants/appwrite_constants.dart';
import 'package:epi_gest_project/data/services/base_repository.dart';
import 'package:epi_gest_project/domain/models/entradas_epi_model.dart';

class EntradasEpiRepository extends BaseRepository<EntradasEpiModel> {
  EntradasEpiRepository(TablesDB databases)
      : super(databases, AppwriteConstants.databaseEntradasEpi);

  @override
  EntradasEpiModel fromMap(Map<String, dynamic> map) {
    return EntradasEpiModel.fromJson(map);
  }
}