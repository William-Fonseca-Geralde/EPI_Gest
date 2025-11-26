import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/core/constants/appwrite_constants.dart';
import 'package:epi_gest_project/data/services/base_repository.dart';
import 'package:epi_gest_project/domain/models/fornecedor_model.dart';

class FornecedorRepository extends BaseRepository<FornecedorModel> {
  FornecedorRepository(TablesDB databases)
      : super(databases, AppwriteConstants.databaseFornecedor);

  @override
  FornecedorModel fromMap(Map<String, dynamic> map) {
    return FornecedorModel.fromMap(map);
  }

  Future<List<FornecedorModel>> getAllFornecedores() async {
    return await getAll([Query.orderAsc('nome_fornecedor')]);
  }
}