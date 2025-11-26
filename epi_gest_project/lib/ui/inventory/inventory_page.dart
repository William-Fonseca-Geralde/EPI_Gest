import 'package:epi_gest_project/data/datasources/epi_local_datasource.dart';
import 'package:epi_gest_project/data/repositories/epi_repository_impl.dart';
import 'package:epi_gest_project/ui/inventory/inventory_controller.dart';
import 'package:epi_gest_project/ui/inventory/widgets/add_epi_drawer.dart';
import 'package:epi_gest_project/ui/inventory/widgets/epi_drawer.dart';
import 'package:epi_gest_project/ui/inventory/widgets/inventory_data_table.dart';
import 'package:epi_gest_project/ui/inventory/widgets/inventory_filters.dart';
import 'package:epi_gest_project/ui/inventory/widgets/entries/entry_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:epi_gest_project/ui/inventory/widgets/inventory/inventory_list_screen.dart';

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
    final dataSource = EpiLocalDataSource();
    final repository = EpiRepositoryImpl(dataSource);
    _controller = InventoryController(repository);

    _controller.addListener(_onControllerUpdate);

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
        return EpiDrawer(
          onClose: () => Navigator.of(context).pop(),
          onSave: () {
            _controller.loadEpis();
          },
        );
      },
    );
  }

  void _navigateToEntryScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const EntryListScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.08),
                  colorScheme.surface.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                topLeft: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estoque de EPIs',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_controller.filteredCount} ${_controller.filteredCount == 1 ? 'item' : 'itens'} no estoque',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
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
                    FilledButton.icon(
                      onPressed: _navigateToEntryScreen,
                      icon: const Icon(Icons.assignment_add),
                      label: const Text('Realizar Entrada'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const InventoryListScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.inventory_outlined),
                      label: const Text('Realizar Inventário'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
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
          const Divider(height: 1),
          if (_showFilters)
            InventoryFilters(
              appliedFilters: _controller.filters,
              categories: _controller.categories,
              suppliers: _controller.suppliers,
              onApplyFilters: _controller.applyFilters,
              onClearFilters: _controller.clearFilters,
            ),
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
