import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/core/constants/appwrite_constants.dart';
import 'package:epi_gest_project/data/services/base_repository.dart';
import 'package:epi_gest_project/domain/models/turno_model.dart';

class TurnoRepository extends BaseRepository<TurnoModel> {
  TurnoRepository(TablesDB databases)
      : super(databases, AppwriteConstants.databaseTurno);

  @override
  TurnoModel fromMap(Map<String, dynamic> map) {
    return TurnoModel.fromMap(map);
  }

  Future<List<TurnoModel>> getAllTurnos() async {
    return await getAll([]);
  }
}