import 'package:flutter/foundation.dart';
import 'package:epi_gest_project/domain/models/epi/epi_model.dart';
import 'package:epi_gest_project/domain/models/epi/inventory_filter_model.dart';
import 'package:epi_gest_project/domain/repositories/epi_repository.dart';

class InventoryController extends ChangeNotifier {
  final EpiRepository _repository;

  InventoryController(this._repository);

  // Estado
  List<EpiModel> _epis = [];
  List<EpiModel> _filteredEpis = [];
  InventoryFilterModel _filters = InventoryFilterModel.empty();
  List<String> _categories = [];
  List<String> _suppliers = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<EpiModel> get epis => List.unmodifiable(_filteredEpis);
  InventoryFilterModel get filters => _filters;
  List<String> get categories => List.unmodifiable(_categories);
  List<String> get suppliers => List.unmodifiable(_suppliers);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalEpis => _epis.length;
  int get filteredCount => _filteredEpis.length;
  bool get hasActiveFilters => !_filters.isEmpty;

  /// Carrega todos os EPIs
  Future<void> loadEpis() async {
    _setLoading(true);
    _error = null;

    try {
      _epis = await _repository.getAllEpis();
      _filteredEpis = _epis;
      await _loadMetadata();
    } catch (e) {
      _error = 'Erro ao carregar EPIs: $e';
      _epis = [];
      _filteredEpis = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega metadados (categorias e fornecedores)
  Future<void> _loadMetadata() async {
    try {
      _categories = await _repository.getCategories();
      _suppliers = await _repository.getSuppliers();
    } catch (e) {
      debugPrint('Erro ao carregar metadados: $e');
    }
  }

  /// Aplica filtros
  Future<void> applyFilters(InventoryFilterModel filters) async {
    _filters = filters;
    _setLoading(true);
    _error = null;

    try {
      _filteredEpis = await _repository.getFilteredEpis(filters);
    } catch (e) {
      _error = 'Erro ao aplicar filtros: $e';
      _filteredEpis = _epis;
    } finally {
      _setLoading(false);
    }
  }

  /// Limpa todos os filtros
  Future<void> clearFilters() async {
    _filters = InventoryFilterModel.empty();
    _filteredEpis = _epis;
    notifyListeners();
  }

  /// Adiciona um novo EPI
  Future<void> addEpi(EpiModel epi) async {
    _setLoading(true);
    _error = null;

    try {
      await _repository.addEpi(epi);
      await loadEpis();
    } catch (e) {
      _error = 'Erro ao adicionar EPI: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Atualiza um EPI existente
  Future<void> updateEpi(EpiModel epi) async {
    _setLoading(true);
    _error = null;

    try {
      await _repository.updateEpi(epi);
      await loadEpis();
    } catch (e) {
      _error = 'Erro ao atualizar EPI: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Remove um EPI
  Future<void> deleteEpi(String id) async {
    _setLoading(true);
    _error = null;

    try {
      await _repository.deleteEpi(id);
      await loadEpis();
    } catch (e) {
      _error = 'Erro ao remover EPI: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
