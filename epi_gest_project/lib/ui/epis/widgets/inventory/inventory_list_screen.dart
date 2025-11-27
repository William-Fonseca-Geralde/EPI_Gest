import 'package:epi_gest_project/ui/epis/widgets/inventory/inventory_data_table.dart';
import 'package:epi_gest_project/ui/epis/widgets/inventory/inventory_filters.dart';
import 'package:epi_gest_project/ui/epis/widgets/inventory/new_inventory_drawer.dart';
import 'package:flutter/material.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  bool _showFilters = false;
  final List<Map<String, dynamic>> _inventories = []; // Dados mockados por enquanto

  void _goBack() {
    Navigator.of(context).pop();
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
                    // Botão Voltar
                    IconButton(
                      onPressed: _goBack,
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Voltar',
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.inventory_outlined,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inventário de EPIs',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_inventories.length} ${_inventories.length == 1 ? 'inventário realizado' : 'inventários realizados'}',
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
                      onPressed: _showNewInventoryDrawer,
                      icon: const Icon(Icons.add),
                      label: const Text('Novo Inventário'),
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
              onApplyFilters: (filters) {
                // TODO: Implementar filtros
              },
              onClearFilters: () {
                // TODO: Implementar limpar filtros
              },
            ),
          Expanded(
            child: _buildContent(theme),
          ),
        ],
      ),
    );
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  void _showNewInventoryDrawer() {
    showDialog(
      context: context,
      builder: (context) => NewInventoryDrawer(
        onClose: () => Navigator.of(context).pop(),
        onSave: (inventoryData) {
          // TODO: Implementar salvamento real
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_inventories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum inventário registrado',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Clique em "Novo Inventário" para registrar o primeiro inventário',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return InventoryDataTable(inventories: _inventories);
  }
}