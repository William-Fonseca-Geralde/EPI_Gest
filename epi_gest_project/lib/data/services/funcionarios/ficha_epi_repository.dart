import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/core/constants/appwrite_constants.dart';
import 'package:epi_gest_project/data/services/base_repository.dart';
import 'package:epi_gest_project/domain/models/appwrite_model.dart';
import 'package:epi_gest_project/domain/models/ficha_epi_model.dart';

class FichaEpiRepository extends BaseRepository {
  FichaEpiRepository(TablesDB databases)
    : super(databases, AppwriteConstants.databaseFichaEpi);

  @override
  AppWriteModel fromMap(Map<String, dynamic> map) {
    return FichaEpiModel.fromMap(map);
  }
}
