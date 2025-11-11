import 'package:epi_gest_project/ui/widgets/multi_select_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmployeesFilters extends StatefulWidget {
  final Map<String, dynamic> appliedFilters;
  final List<String> setores;
  final List<String> funcoes;
  final Function(Map<String, dynamic>) onApplyFilters;
  final VoidCallback onClearFilters;
  final Function(String)? onAddSetor;
  final Function(String)? onAddFuncao;

  const EmployeesFilters({
    super.key,
    required this.appliedFilters,
    required this.setores,
    required this.funcoes,
    required this.onApplyFilters,
    required this.onClearFilters,
    this.onAddSetor,
    this.onAddFuncao,
  });

  @override
  State<EmployeesFilters> createState() => _EmployeesFiltersState();
}

class _EmployeesFiltersState extends State<EmployeesFilters> {
  bool _showAdvancedFilters = false;

  late Map<String, dynamic> _tempFilters;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _dataEntradaController = TextEditingController();
  final TextEditingController _novoSetorController = TextEditingController();
  final TextEditingController _novaFuncaoController = TextEditingController();

  // Overlays
  OverlayEntry? _setorOverlay;
  OverlayEntry? _funcaoOverlay;

  @override
  void initState() {
    super.initState();
    _loadFiltersToTemp();
  }

  void _loadFiltersToTemp() {
    _tempFilters = Map<String, dynamic>.from(widget.appliedFilters);
    _nomeController.text = _tempFilters['nome'] ?? '';
    _idController.text = _tempFilters['matricula'] ?? '';

    if (_tempFilters['dataEntrada'] != null) {
      final date = _tempFilters['dataEntrada'] as DateTime;
      _dataEntradaController.text = DateFormat('dd/MM/yyyy').format(date);
    }
  }

  @override
  void didUpdateWidget(EmployeesFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.appliedFilters != oldWidget.appliedFilters) {
      setState(() {
        _loadFiltersToTemp();
      });
    }
  }

  @override
  void dispose() {
    _removeOverlays();
    _nomeController.dispose();
    _idController.dispose();
    _dataEntradaController.dispose();
    _novoSetorController.dispose();
    _novaFuncaoController.dispose();
    super.dispose();
  }

  void _removeOverlays() {
    _setorOverlay?.remove();
    _setorOverlay = null;
    _funcaoOverlay?.remove();
    _funcaoOverlay = null;
  }

  void _applyFilters() {
    widget.onApplyFilters(_tempFilters);
  }

  bool get _hasChanges {
    return _tempFilters.toString() != widget.appliedFilters.toString();
  }

  int get _activeFiltersCount {
    int count = 0;
    _tempFilters.forEach((key, value) {
      if (value != null) {
        if (value is String && value.isNotEmpty) count++;
        if (value is List && value.isNotEmpty) count++;
        if (value is DateTime) count++;
      }
    });
    return count;
  }

  Future<void> _selectDate() async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _tempFilters['dataEntrada'] ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(
              context,
            ).copyWith(colorScheme: Theme.of(context).colorScheme),
            child: child!,
          );
        },
      );

      if (picked != null) {
        setState(() {
          _tempFilters['dataEntrada'] = picked;
          _dataEntradaController.text = DateFormat('dd/MM/yyyy').format(picked);
        });
      }
    } catch (e) {
      debugPrint('Erro ao selecionar data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActiveFilters = _activeFiltersCount > 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasActiveFilters) ...[
            Text(
              'Filtros Ativos:',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              spacing: 16,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _buildActiveFilterChips(theme),
                ),
                OutlinedButton.icon(
                  onPressed: widget.onClearFilters,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Limpar Filtros'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                    side: BorderSide(color: theme.colorScheme.outline),
                  ),
                ),
              ],
            ),
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
          ],

          Row(
            spacing: 16,
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: 'Matricula',
                    hintText: 'Digite o Matricula...',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _tempFilters['matricula'] = value.isEmpty ? null : value;
                    });
                  },
                ),
              ),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _nomeController,
                  decoration: InputDecoration(
                    labelText: 'Nome do Funcionário',
                    hintText: 'Digite o nome...',
                    prefixIcon: const Icon(Icons.person_search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _tempFilters['nome'] = value.isEmpty ? null : value;
                    });
                  },
                ),
              ),
              Expanded(
                flex: 3,
                child: MultiSelectDropdown(
                  label: 'Status do Funcionário',
                  icon: Icons.toggle_on,
                  items: const ['Ativo', 'Inativo'],
                  width: 350,
                  selectedItems: _tempFilters['ativo'] ?? [],
                  allItemsLabel: 'Todos',
                  onChanged: (selected) {
                    setState(() {
                      _tempFilters['ativo'] = selected.isEmpty
                          ? null
                          : selected;
                    });
                  },
                ),
              ),
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
          if (_showAdvancedFilters) ...[
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
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      Icon(
                        Icons.tune,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      Text(
                        'Filtros Avançados',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 16,
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _dataEntradaController,
                          decoration: InputDecoration(
                            labelText: 'Data de Entrada',
                            hintText: 'dd/mm/aaaa',
                            prefixIcon: const Icon(
                              Icons.calendar_today_outlined,
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_tempFilters['dataEntrada'] != null)
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        _tempFilters['dataEntrada'] = null;
                                        _dataEntradaController.clear();
                                      });
                                    },
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.event),
                                  onPressed: _selectDate,
                                ),
                              ],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                          readOnly: true,
                          onTap: _selectDate,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Expanded(
                              child: MultiSelectDropdown(
                                label: 'Setor',
                                icon: Icons.business_outlined,
                                items: widget.setores,
                                selectedItems: _tempFilters['setores'] ?? [],
                                allItemsLabel: 'Todos',
                                width: 300,
                                onChanged: (selected) {
                                  setState(() {
                                    _tempFilters['setores'] = selected.isEmpty
                                        ? null
                                        : selected;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Expanded(
                              child: MultiSelectDropdown(
                                label: 'Funções',
                                icon: Icons.work_outline,
                                items: widget.funcoes,
                                selectedItems: _tempFilters['funcoes'] ?? [],
                                allItemsLabel: 'Todas',
                                width: 300,
                                onChanged: (selected) {
                                  setState(() {
                                    _tempFilters['funcoes'] = selected.isEmpty
                                        ? null
                                        : selected;
                                  });
                                },
                              ),
                            ),
                          ],
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

  List<Widget> _buildActiveFilterChips(ThemeData theme) {
    final chips = <Widget>[];

    _tempFilters.forEach((key, value) {
      if (value == null) return;

      String label = '';
      String displayValue = '';

      switch (key) {
        case 'nome':
          label = 'Nome';
          displayValue = value.toString();
          break;
        case 'matricula':
          label = 'Matricula';
          displayValue = value.toString();
          break;
        case 'setores':
          label = 'Setor';
          final setores = value as List<String>;
          displayValue = setores.length == 1
              ? setores.first
              : '${setores.length} setores';
          break;
        case 'dataEntrada':
          label = 'Data de Entrada';
          displayValue = DateFormat('dd/MM/yyyy').format(value as DateTime);
          break;
        case 'funcoes':
          label = 'Função';
          final funcoes = value as List<String>;
          displayValue = funcoes.length == 1
              ? funcoes.first
              : '${funcoes.length} funções';
          break;
        case 'ativo':
          label = 'Status';
          final status = value as List<String>;
          displayValue = status.length == 1 ? status.first : 'Todos';
      }

      if (label.isNotEmpty) {
        chips.add(
          Chip(
            avatar: const Icon(Icons.filter_alt, size: 18),
            label: Text('$label: $displayValue'),
            onDeleted: () {
              setState(() {
                _tempFilters[key] = null;
                if (key == 'nome') _nomeController.clear();
                if (key == 'id') _idController.clear();
                if (key == 'dataEntrada') _dataEntradaController.clear();
              });
              widget.onApplyFilters(_tempFilters);
            },
            deleteIcon: const Icon(Icons.close, size: 18),
          ),
        );
      }
    });

    return chips;
  }
}
