import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/core/constants/appwrite_constants.dart';
import 'package:epi_gest_project/data/services/base_repository.dart';
import 'package:epi_gest_project/domain/models/unidade_model.dart';

class UnidadeRepository extends BaseRepository<UnidadeModel> {
  UnidadeRepository(TablesDB databases)
      : super(databases, AppwriteConstants.databaseLocalTrabalho);  

  @override
  UnidadeModel fromMap(Map<String, dynamic> map) {
    return UnidadeModel.fromMap(map);
  }

  Future<List<UnidadeModel>> getAllUnidades() async {
    return await getAll([]);
  }

  Future<void> inativarUnidade(String rowId) async {
    try {
      await update(rowId, {
        'status': false,
      });
    } catch (e) {
      throw Exception('Falha ao inativar unidade.');
    }
  }

  Future<void> ativarUnidade(String rowId) async {
    try {
      await update(rowId, {
        'status': true,
      });
    } catch (e) {
      throw Exception('Falha ao reativar unidade.');
    }
  }
}