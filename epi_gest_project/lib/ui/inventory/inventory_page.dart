import 'package:epi_gest_project/data/datasources/epi_local_datasource.dart';
import 'package:epi_gest_project/data/repositories/epi_repository_impl.dart';
import 'package:epi_gest_project/ui/inventory/inventory_controller.dart';
import 'package:epi_gest_project/ui/inventory/widgets/add_epi_drawer.dart';
import 'package:epi_gest_project/ui/inventory/widgets/inventory_data_table.dart';
import 'package:epi_gest_project/ui/inventory/widgets/inventory_filters.dart';
import 'package:flutter/material.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  late final InventoryController _controller;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    // Inicializa o controller com as dependências
    final dataSource = EpiLocalDataSource();
    final repository = EpiRepositoryImpl(dataSource);
    _controller = InventoryController(repository);

    // Adiciona listener para reconstruir a UI
    _controller.addListener(_onControllerUpdate);

    // Carrega os dados iniciais
    _controller.loadEpis();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  void _showAddEpiDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Add EPI',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AddEpiDrawer(
          onClose: () => Navigator.of(context).pop(),
          onSave: (data) {
            // TODO: Implementar salvamento real
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 16,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 40,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estoque de EPIs',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_controller.filteredCount} ${_controller.filteredCount == 1 ? 'item' : 'itens'} no estoque',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Botão Toggle Filtros
                    IconButton.filledTonal(
                      onPressed: _toggleFilters,
                      icon: Icon(
                        _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
                      ),
                      tooltip: _showFilters
                          ? 'Ocultar filtros'
                          : 'Mostrar filtros',
                    ),
                    const SizedBox(width: 12),
                    // Botão Adicionar EPI
                    FilledButton.icon(
                      onPressed: _showAddEpiDrawer,
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar EPI'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filtros (condicional)
          if (_showFilters)
            InventoryFilters(
              appliedFilters: _controller.filters,
              categories: _controller.categories,
              suppliers: _controller.suppliers,
              onApplyFilters: _controller.applyFilters,
              onClearFilters: _controller.clearFilters,
            ),

          // Conteúdo principal
          Expanded(child: _buildContent(theme)),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    // Estado de loading
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Estado de erro
    if (_controller.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar dados',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _controller.error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _controller.loadEpis,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    // Estado vazio
    if (_controller.epis.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum EPI encontrado',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _controller.hasActiveFilters
                  ? 'Tente ajustar os filtros'
                  : 'Adicione novos EPIs ao estoque',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            if (_controller.hasActiveFilters)
              FilledButton.icon(
                onPressed: _controller.clearFilters,
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpar Filtros'),
              ),
          ],
        ),
      );
    }

    // Tabela de EPIs
    return InventoryDataTable(epis: _controller.epis);
  }
}
