import 'package:epi_gest_project/ui/widgets/multi_select_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:epi_gest_project/domain/models/epi/inventory_filter_model.dart';

class EpiFilters extends StatefulWidget {
  final InventoryFilterModel appliedFilters;
  final List<String> categories;
  final List<String> suppliers;
  final Function(InventoryFilterModel) onApplyFilters;
  final VoidCallback onClearFilters;

  const EpiFilters({
    super.key,
    required this.appliedFilters,
    required this.categories,
    required this.suppliers,
    required this.onApplyFilters,
    required this.onClearFilters,
  });

  @override
  State<EpiFilters> createState() => _EpiFiltersState();
}

class _EpiFiltersState extends State<EpiFilters> {
  bool _showAdvancedFilters = false;

  // Filtros temporários
  late InventoryFilterModel _tempFilters;

  // Controllers
  final TextEditingController _caController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();

  // Opções de validade
  static const List<Map<String, String>> _validadeOptions = [
    {'value': 'No Prazo', 'label': 'No prazo'},
    {'value': 'À Vencer', 'label': 'À vencer'},
    {'value': 'Vencido', 'label': 'Vencido'},
  ];

  @override
  void initState() {
    super.initState();
    _loadFiltersToTemp();
  }

  void _loadFiltersToTemp() {
    _tempFilters = widget.appliedFilters;
    _caController.text = _tempFilters.ca ?? '';
    _nomeController.text = _tempFilters.nome ?? '';
    _quantidadeController.text = _tempFilters.quantidade?.toString() ?? '';
    _valorController.text = _tempFilters.valor?.toString() ?? '';
  }

  @override
  void didUpdateWidget(EpiFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.appliedFilters != oldWidget.appliedFilters) {
      setState(() {
        _loadFiltersToTemp();
      });
    }
  }

  @override
  void dispose() {
    _caController.dispose();
    _nomeController.dispose();
    _quantidadeController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    widget.onApplyFilters(_tempFilters);
  }

  bool get _hasChanges {
    return _tempFilters.toMap().toString() !=
        widget.appliedFilters.toMap().toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActiveFilters = widget.appliedFilters.activeFiltersCount > 0;

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
          // Chips de filtros ativos
          if (hasActiveFilters) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _buildActiveFilterChips(theme),
            ),
            const SizedBox(height: 16),
          ],

          // Linha principal de filtros
          Row(
            children: [
              // Filtro de Validade (Multi-Select)
              Expanded(
                flex: 2,
                child: MultiSelectDropdown(
                  label: 'Validade',
                  icon: Icons.calendar_today_outlined,
                  items: ['No Prazo', 'À Vencer', 'Vencido'],
                  selectedItems: _tempFilters.validades ?? [],
                  allItemsLabel: 'Todas',
                  width: 300,
                  onChanged: (selected) {
                    setState(() {
                      _tempFilters = _tempFilters.copyWith(
                        validades: selected.isEmpty ? null : selected,
                      );
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Filtro de CA
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _caController,
                  decoration: InputDecoration(
                    labelText: 'CA',
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
                      _tempFilters = _tempFilters.copyWith(
                        ca: value.isEmpty ? null : value,
                      );
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Filtro de Categoria (Multi-Select)
              Expanded(
                flex: 2,
                child: MultiSelectDropdown(
                  label: 'Categoria',
                  icon: Icons.category_outlined,
                  items: widget.categories,
                  selectedItems: _tempFilters.categorias ?? [],
                  allItemsLabel: 'Todas',
                  width: 300,
                  onChanged: (selected) {
                    setState(() {
                      _tempFilters = _tempFilters.copyWith(
                        categorias: selected.isEmpty ? null : selected,
                      );
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Botão Filtros Avançados
              FilledButton.tonalIcon(
                onPressed: () {
                  setState(() {
                    _showAdvancedFilters = !_showAdvancedFilters;
                  });
                },
                icon: Icon(
                  _showAdvancedFilters ? Icons.keyboard_arrow_up : Icons.tune,
                ),
                label: Text(_showAdvancedFilters ? 'Ocultar' : 'Avançado'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Botão Filtrar
              FilledButton.icon(
                onPressed: _hasChanges ? _applyFilters : null,
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

          // Filtros Avançados
          if (_showAdvancedFilters) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tune,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Filtros Avançados',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Nome do EPI
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _nomeController,
                          decoration: InputDecoration(
                            labelText: 'Nome do EPI',
                            hintText: 'Digite o nome...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _tempFilters = _tempFilters.copyWith(
                                nome: value.isEmpty ? null : value,
                              );
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Fornecedor (Multi-Select)
                      Expanded(
                        flex: 2,
                        child: MultiSelectDropdown(
                          label: 'Fornecedor',
                          icon: Icons.business_outlined,
                          items: widget.suppliers,
                          selectedItems: _tempFilters.fornecedores ?? [],
                          allItemsLabel: 'Todos',
                          width: 300,
                          onChanged: (selected) {
                            setState(() {
                              _tempFilters = _tempFilters.copyWith(
                                fornecedores: selected.isEmpty ? null : selected,
                              );
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Quantidade
                      Expanded(
                        child: _buildNumericFilter(
                          context: context,
                          label: 'Quantidade',
                          icon: Icons.inventory_2_outlined,
                          controller: _quantidadeController,
                          currentValue: _tempFilters.quantidade,
                          currentOperator:
                              _tempFilters.quantidadeOperador ?? '=',
                          onValueChanged: (value, operator) {
                            setState(() {
                              _tempFilters = _tempFilters.copyWith(
                                quantidade: value,
                                quantidadeOperador: operator,
                              );
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Valor Unitário
                      Expanded(
                        child: _buildNumericFilter(
                          context: context,
                          label: 'Valor Unitário',
                          icon: Icons.attach_money,
                          controller: _valorController,
                          currentValue: _tempFilters.valor,
                          currentOperator: _tempFilters.valorOperador ?? '=',
                          isDecimal: true,
                          onValueChanged: (value, operator) {
                            setState(() {
                              _tempFilters = _tempFilters.copyWith(
                                valor: value,
                                valorOperador: operator,
                              );
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNumericFilter({
    required BuildContext context,
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required num? currentValue,
    required String currentOperator,
    required Function(num?, String) onValueChanged,
    bool isDecimal = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Dropdown de operador
        SizedBox(
          width: 80,
          child: DropdownButtonFormField<String>(
            value: currentOperator,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            items: const [
              DropdownMenuItem(value: '=', child: Text('=')),
              DropdownMenuItem(value: '>', child: Text('>')),
              DropdownMenuItem(value: '<', child: Text('<')),
              DropdownMenuItem(value: '>=', child: Text('≥')),
              DropdownMenuItem(value: '<=', child: Text('≤')),
            ],
            onChanged: (value) {
              if (value != null) {
                onValueChanged(currentValue, value);
              }
            },
          ),
        ),
        const SizedBox(width: 8),

        // Campo de valor
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: isDecimal
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.number,
            inputFormatters: [
              if (isDecimal)
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
              else
                FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                final numValue = isDecimal
                    ? double.tryParse(value)
                    : int.tryParse(value);
                onValueChanged(numValue, currentOperator);
              } else {
                onValueChanged(null, currentOperator);
              }
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActiveFilterChips(ThemeData theme) {
    final chips = <Widget>[];
    final filtersMap = widget.appliedFilters.toMap();

    filtersMap.forEach((key, value) {
      // Ignora operadores
      if (key.endsWith('Operador')) return;

      String label = '';
      String displayValue = '';

      switch (key) {
        case 'validades':
          label = 'Validade';
          final validades = value as List<String>;
          displayValue = validades
              .map((v) => _getValidadeLabel(v))
              .join(', ');
          break;
        case 'ca':
          label = 'CA';
          displayValue = value.toString();
          break;
        case 'categorias':
          label = 'Categoria';
          final categorias = value as List<String>;
          displayValue = categorias.length == 1
              ? categorias.first
              : '${categorias.length} categorias';
          break;
        case 'nome':
          label = 'Nome';
          displayValue = value.toString();
          break;
        case 'fornecedores':
          label = 'Fornecedor';
          final fornecedores = value as List<String>;
          displayValue = fornecedores.length == 1
              ? fornecedores.first
              : '${fornecedores.length} fornecedores';
          break;
        case 'quantidade':
          label = 'Quantidade';
          final operator = filtersMap['quantidadeOperador'] ?? '=';
          displayValue = '$operator $value';
          break;
        case 'valor':
          label = 'Valor';
          final operator = filtersMap['valorOperador'] ?? '=';
          displayValue = '$operator R\$ ${value.toStringAsFixed(2)}';
          break;
      }

      if (label.isNotEmpty) {
        chips.add(
          Chip(
            avatar: const Icon(Icons.filter_alt, size: 18),
            label: Text('$label: $displayValue'),
            onDeleted: () {
              final newFiltersMap = Map<String, dynamic>.from(filtersMap);
              newFiltersMap.remove(key);

              // Remove também o operador se for numérico
              if (key == 'quantidade' || key == 'valor') {
                newFiltersMap.remove('${key}Operador');
              }

              final newFilters = InventoryFilterModel.fromMap(newFiltersMap);
              widget.onApplyFilters(newFilters);

              // Atualiza os campos temporários
              setState(() {
                _tempFilters = newFilters;
                if (key == 'ca') _caController.clear();
                if (key == 'nome') _nomeController.clear();
                if (key == 'quantidade') _quantidadeController.clear();
                if (key == 'valor') _valorController.clear();
              });
            },
            deleteIcon: const Icon(Icons.close, size: 18),
          ),
        );
      }
    });

    return chips;
  }

  String _getValidadeLabel(String value) {
    final option = _validadeOptions.firstWhere(
      (e) => e['value'] == value,
      orElse: () => {'value': value, 'label': value},
    );
    return option['label']!;
  }
}
