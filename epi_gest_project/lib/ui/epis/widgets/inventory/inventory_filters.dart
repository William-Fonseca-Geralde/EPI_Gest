import 'package:flutter/material.dart';

class InventoryFilters extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;
  final VoidCallback onClearFilters;

  const InventoryFilters({
    super.key,
    required this.onApplyFilters,
    required this.onClearFilters,
  });

  @override
  State<InventoryFilters> createState() => _InventoryFiltersState();
}

class _InventoryFiltersState extends State<InventoryFilters> {
  final Map<String, dynamic> _tempFilters = {};
  final TextEditingController _produtoController = TextEditingController();
  final TextEditingController _caController = TextEditingController();

  @override
  void dispose() {
    _produtoController.dispose();
    _caController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    widget.onApplyFilters(_tempFilters);
  }

  void _clearFilters() {
    setState(() {
      _tempFilters.clear();
      _produtoController.clear();
      _caController.clear();
    });
    widget.onClearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Filtro de Produto
              Expanded(
                child: TextField(
                  controller: _produtoController,
                  decoration: InputDecoration(
                    labelText: 'Produto',
                    hintText: 'Digite o nome...',
                    prefixIcon: const Icon(Icons.inventory_2_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        _tempFilters.remove('produto');
                      } else {
                        _tempFilters['produto'] = value;
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Filtro de CA
              Expanded(
                child: TextField(
                  controller: _caController,
                  decoration: InputDecoration(
                    labelText: 'C.A',
                    hintText: 'Digite o CA...',
                    prefixIcon: const Icon(Icons.tag_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        _tempFilters.remove('ca');
                      } else {
                        _tempFilters['ca'] = value;
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Botão Limpar Filtros
              OutlinedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Botão Filtrar
              FilledButton.icon(
                onPressed: _tempFilters.isNotEmpty ? _applyFilters : null,
                icon: const Icon(Icons.filter_alt),
                label: const Text('Filtrar'),
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
    );
  }
}