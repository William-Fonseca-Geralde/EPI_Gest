import 'package:epi_gest_project/ui/widgets/multi_select_dropdown.dart';
import 'package:flutter/material.dart';

class EntryFilters extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;
  final VoidCallback onClearFilters;

  const EntryFilters({
    super.key,
    required this.onApplyFilters,
    required this.onClearFilters,
  });

  @override
  State<EntryFilters> createState() => _EntryFiltersState();
}

class _EntryFiltersState extends State<EntryFilters> {
  final Map<String, dynamic> _tempFilters = {};
  final TextEditingController _notaFiscalController = TextEditingController();
  final TextEditingController _fornecedorController = TextEditingController();
  final TextEditingController _produtoController = TextEditingController();

  @override
  void dispose() {
    _notaFiscalController.dispose();
    _fornecedorController.dispose();
    _produtoController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    widget.onApplyFilters(_tempFilters);
  }

  void _clearFilters() {
    setState(() {
      _tempFilters.clear();
      _notaFiscalController.clear();
      _fornecedorController.clear();
      _produtoController.clear();
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
              // Filtro de Nota Fiscal
              Expanded(
                child: TextField(
                  controller: _notaFiscalController,
                  decoration: InputDecoration(
                    labelText: 'Nota Fiscal',
                    hintText: 'Digite o número...',
                    prefixIcon: const Icon(Icons.receipt_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        _tempFilters.remove('notaFiscal');
                      } else {
                        _tempFilters['notaFiscal'] = value;
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Filtro de Fornecedor
              Expanded(
                child: TextField(
                  controller: _fornecedorController,
                  decoration: InputDecoration(
                    labelText: 'Fornecedor',
                    hintText: 'Digite o nome...',
                    prefixIcon: const Icon(Icons.business_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        _tempFilters.remove('fornecedor');
                      } else {
                        _tempFilters['fornecedor'] = value;
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),

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