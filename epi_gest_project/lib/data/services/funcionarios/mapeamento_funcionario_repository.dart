import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/core/constants/appwrite_constants.dart';
import 'package:epi_gest_project/data/services/base_repository.dart';
import 'package:epi_gest_project/domain/models/funcionarios/mapeamento_funcionario_model.dart';

class MapeamentoFuncionarioRepository
    extends BaseRepository<MapeamentoFuncionarioModel> {
  MapeamentoFuncionarioRepository(TablesDB databases)
    : super(databases, AppwriteConstants.databaseFuncionarioEpi);

  @override
  MapeamentoFuncionarioModel fromMap(Map<String, dynamic> map) {
    return MapeamentoFuncionarioModel.fromMap(map);
  }

  Future<MapeamentoFuncionarioModel?> getByFuncionarioId(
    String funcionarioId,
  ) async {
    try {
      final result = await getAll([
        Query.equal('funcionario_id', funcionarioId),
        Query.limit(1),
        Query.select(['*', 'mapeamento_id.*', 'unidade_id.*']),
      ]);

      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      return null;
    }
  }

  Future<List<MapeamentoFuncionarioModel>> getAllRelations() async {
    return await getAll([
      Query.select(['funcionario_id.*', 'mapeamento_id.*']),
    ]);
  }

  Future<int> countByMapeamentoId(String mapeamentoId) async {
    try {
      final result = await databases.listRows(
        databaseId: AppwriteConstants.databaseId,
        tableId: tableId,
        queries: [
          Query.equal('mapeamento_id', [mapeamentoId]),
          Query.limit(1), // Apenas para pegar o total no metadado
        ],
      );
      return result.total;
    } catch (e) {
      return 0;
    }
  }

  Future<void> handleMapeamentoInactivation(
    String oldMapeamentoId,
    String? newMapeamentoId,
  ) async {
    try {
      final result = await databases.listRows(
        databaseId: AppwriteConstants.databaseId,
        tableId: tableId,
        queries: [
          Query.equal('mapeamento_id', [oldMapeamentoId]),
          Query.limit(100), 
        ],
      );

      for (var doc in result.rows) {
        if (newMapeamentoId != null) {
          await update(doc.$id, {'mapeamento_id': newMapeamentoId});
        } else {
          await delete(doc.$id);
        }
      }
    } catch (e) {
      throw Exception('Erro ao atualizar vínculos dos funcionários: $e');
    }
  }
}
