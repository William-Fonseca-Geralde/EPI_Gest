import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/domain/models/funcionarios/funcionario_model.dart';
import '../base_repository.dart';
import '../../../core/constants/appwrite_constants.dart';

class FuncionarioRepository extends BaseRepository<FuncionarioModel> {
  FuncionarioRepository(TablesDB databases)
    : super(databases, AppwriteConstants.databaseFuncionarios);

  @override
  FuncionarioModel fromMap(Map<String, dynamic> map) {
    return FuncionarioModel.fromMap(map);
  }

  Future<List<FuncionarioModel>> getAllFuncionarios() async {
    try {
      return await getAll([
        Query.select(['*', 'vinculo_id.*']),
        Query.select(['*', 'turno_id.*']),
      ]);
    } on AppwriteException catch (e) {
      throw Exception('Falha ao carregar funcionários. $e');
    }
  }

  Future<List<FuncionarioModel>> getAllActivatedFuncionarios() async {
    try {
      return await getAll([
        Query.select(['*', 'vinculo_id.*']),
        Query.select(['*', 'turno_id.*']),
        Query.equal('status_ativo', true)
      ]);
    } on AppwriteException catch (e) {
      throw Exception('Falha ao carregar funcionários. $e');
    }
  }

  Future<void> inactivateEmployee(String rowId, {String? motivo}) async {
    try {
      await update(rowId, {
        'status_ativo': false,
        'data_desligamento': DateTime.now().toIso8601String(),
        'motivo_desligamento': motivo,
      });
    } catch (e) {
      throw Exception('Falha ao inativar funcionário.');
    }
  }

  Future<void> activateEmployee(String rowId) async {
    try {
      await update(rowId, {
        'status_ativo': true,
        'data_desligamento': null,
        'motivo_desligamento': null,
      });
    } catch (e) {
      throw Exception('Falha ao reativar funcionário.');
    }
  }
}
