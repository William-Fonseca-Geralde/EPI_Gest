import 'package:epi_gest_project/data/datasources/epi_local_datasource.dart';
import 'package:epi_gest_project/domain/models/epi/epi_model.dart';
import 'package:epi_gest_project/domain/models/epi/inventory_filter_model.dart';
import 'package:epi_gest_project/domain/repositories/epi_repository.dart';

class EpiRepositoryImpl implements EpiRepository {
  final EpiLocalDataSource _dataSource;

  EpiRepositoryImpl(this._dataSource);

  @override
  Future<List<EpiModel>> getAllEpis() async {
    return await _dataSource.getAllEpis();
  }

  @override
  Future<List<EpiModel>> getFilteredEpis(InventoryFilterModel filters) async {
    final allEpis = await _dataSource.getAllEpis();

    if (filters.isEmpty) {
      return allEpis;
    }

    return allEpis.where((epi) {
      // Filtro de Validade (múltiplos valores)
      if (filters.validades != null && filters.validades!.isNotEmpty) {
        bool matchesAnyValidade = false;
        
        for (final validade in filters.validades!) {
          switch (validade) {
            case 'Vencido':
              if (epi.isVencido) matchesAnyValidade = true;
              break;
            case 'À Vencer':
              if (epi.isProximoVencimento) matchesAnyValidade = true;
              break;
            case 'No Prazo':
              if (!epi.isVencido && !epi.isProximoVencimento) {
                matchesAnyValidade = true;
              }
              break;
          }
          if (matchesAnyValidade) break;
        }
        
        if (!matchesAnyValidade) return false;
      }

      // Filtro de CA (case-insensitive, busca parcial)
      if (filters.ca != null && filters.ca!.isNotEmpty) {
        if (!epi.ca.toLowerCase().contains(filters.ca!.toLowerCase())) {
          return false;
        }
      }

      // Filtro de Categoria (múltiplos valores)
      if (filters.categorias != null && filters.categorias!.isNotEmpty) {
        if (!filters.categorias!.contains(epi.categoria)) {
          return false;
        }
      }

      // Filtro de Nome (case-insensitive, busca parcial)
      if (filters.nome != null && filters.nome!.isNotEmpty) {
        if (!epi.nome.toLowerCase().contains(filters.nome!.toLowerCase())) {
          return false;
        }
      }

      // Filtro de Fornecedor (múltiplos valores)
      if (filters.fornecedores != null && filters.fornecedores!.isNotEmpty) {
        if (!filters.fornecedores!.contains(epi.fornecedor)) {
          return false;
        }
      }

      // Filtro de Quantidade
      if (filters.quantidade != null) {
        final operator = filters.quantidadeOperador ?? '=';
        if (!_compareNumeric(
          epi.quantidadeEstoque,
          filters.quantidade!,
          operator,
        )) {
          return false;
        }
      }

      // Filtro de Valor
      if (filters.valor != null) {
        final operator = filters.valorOperador ?? '=';
        if (!_compareNumeric(epi.valorUnitario, filters.valor!, operator)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  bool _compareNumeric(num value, num target, String operator) {
    switch (operator) {
      case '=':
        return value == target;
      case '>':
        return value > target;
      case '<':
        return value < target;
      case '>=':
        return value >= target;
      case '<=':
        return value <= target;
      default:
        return true;
    }
  }

  @override
  Future<EpiModel?> getEpiById(String id) async {
    return await _dataSource.getEpiById(id);
  }

  @override
  Future<void> addEpi(EpiModel epi) async {
    await _dataSource.addEpi(epi);
  }

  @override
  Future<void> updateEpi(EpiModel epi) async {
    await _dataSource.updateEpi(epi);
  }

  @override
  Future<void> deleteEpi(String id) async {
    await _dataSource.deleteEpi(id);
  }

  @override
  Future<List<String>> getCategories() async {
    final epis = await _dataSource.getAllEpis();
    final categories = epis.map((e) => e.categoria).toSet().toList();
    categories.sort();
    return categories;
  }

  @override
  Future<List<String>> getSuppliers() async {
    final epis = await _dataSource.getAllEpis();
    final suppliers = epis.map((e) => e.fornecedor).toSet().toList();
    suppliers.sort();
    return suppliers;
  }
}
