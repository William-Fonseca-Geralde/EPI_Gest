import 'package:epi_gest_project/domain/models/epi/epi_model.dart';
import 'package:epi_gest_project/domain/models/epi/inventory_filter_model.dart';

abstract class EpiRepository {
  /// Retorna todos os EPIs
  Future<List<EpiModel>> getAllEpis();

  /// Retorna EPIs filtrados
  Future<List<EpiModel>> getFilteredEpis(InventoryFilterModel filters);

  /// Retorna um EPI por ID
  Future<EpiModel?> getEpiById(String id);

  /// Adiciona um novo EPI
  Future<void> addEpi(EpiModel epi);

  /// Atualiza um EPI existente
  Future<void> updateEpi(EpiModel epi);

  /// Remove um EPI
  Future<void> deleteEpi(String id);

  /// Retorna todas as categorias únicas
  Future<List<String>> getCategories();

  /// Retorna todos os fornecedores únicos
  Future<List<String>> getSuppliers();
}
