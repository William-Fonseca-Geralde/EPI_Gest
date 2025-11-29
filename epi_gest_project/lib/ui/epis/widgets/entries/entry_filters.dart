import 'package:epi_gest_project/domain/models/filters/entry_filter_model.dart';
import 'package:epi_gest_project/ui/widgets/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EntryFilters extends StatefulWidget {
  final EntryFilterModel appliedFilters;
  final Function(EntryFilterModel) onApplyFilters;
  final VoidCallback onClearFilters;
  final List<String> fornecedor;
  final List<String> produto;

  const EntryFilters({
    super.key,
    required this.appliedFilters,
    required this.onApplyFilters,
    required this.onClearFilters,
    required this.fornecedor,
    required this.produto,
  });

  @override
  State<EntryFilters> createState() => _EntryFiltersState();
}

class _EntryFiltersState extends State<EntryFilters> {
  late EntryFilterModel _tempFilters;

  // Controllers
  final TextEditingController _notaFiscalController = TextEditingController();
  final TextEditingController _fornecedorController = TextEditingController();
  final TextEditingController _produtoController = TextEditingController();
  final TextEditingController _dateRangeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFilters();

    _notaFiscalController.addListener(_onFieldsChanged);
    _fornecedorController.addListener(_onFieldsChanged);
    _produtoController.addListener(_onFieldsChanged);
  }

  void _loadFilters() {
    _tempFilters = widget.appliedFilters;
    _notaFiscalController.text = _tempFilters.notaFiscal ?? '';
    _fornecedorController.text = _tempFilters.fornecedor ?? '';
    _produtoController.text = _tempFilters.produto ?? '';

    // Formata o texto do Range de Datas
    _updateDateRangeText();
  }

  void _updateDateRangeText() {
    if (_tempFilters.dataInicio != null && _tempFilters.dataFim != null) {
      final start = DateFormat('dd/MM/yyyy').format(_tempFilters.dataInicio!);
      final end = DateFormat('dd/MM/yyyy').format(_tempFilters.dataFim!);
      _dateRangeController.text = '$start - $end';
    } else {
      _dateRangeController.clear();
    }
  }

  // Atualiza o _tempFilters baseado nos controllers
  void _onFieldsChanged() {
    setState(() {
      _tempFilters = EntryFilterModel(
        notaFiscal: _notaFiscalController.text.isEmpty ? null : _notaFiscalController.text,
        fornecedor: _fornecedorController.text.isEmpty ? null : _fornecedorController.text,
        produto: _produtoController.text.isEmpty ? null : _produtoController.text,
        dataInicio: _tempFilters.dataInicio, // Mantém datas existentes
        dataFim: _tempFilters.dataFim,
      );
    });
  }

  @override
  void didUpdateWidget(covariant EntryFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.appliedFilters != oldWidget.appliedFilters) {
      _loadFilters();
    }
  }

  @override
  void dispose() {
    _notaFiscalController.dispose();
    _fornecedorController.dispose();
    _produtoController.dispose();
    _dateRangeController.dispose();
    super.dispose();
  }

  // Novo seletor de Range de Datas
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange:
          (_tempFilters.dataInicio != null && _tempFilters.dataFim != null)
          ? DateTimeRange(
              start: _tempFilters.dataInicio!,
              end: _tempFilters.dataFim!,
            )
          : null,
      locale: const Locale('pt', 'BR'),
      initialEntryMode: DatePickerEntryMode.input,
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: Theme.of(context).colorScheme),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 650, // Largura máxima do dialog
                maxHeight: 500, // Altura máxima do dialog
              ),
              child: child!,
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _tempFilters = _tempFilters.copyWith(
          dataInicio: picked.start,
          dataFim: picked.end,
        );
        final start = DateFormat('dd/MM/yyyy').format(picked.start);
        final end = DateFormat('dd/MM/yyyy').format(picked.end);
        _dateRangeController.text = '$start - $end';
      });
    }
  }

  void _apply() {
    widget.onApplyFilters(_tempFilters);
  }

  bool get _hasChanges {
    return _tempFilters.toMap().toString() != widget.appliedFilters.toMap().toString();
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
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasActiveFilters) ...[
            Row(
              spacing: 8,
              children: [
                Icon(
                  Icons.filter_list,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                Text(
                  'Filtros Ativos:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
            children: [
              Expanded(
                child: TextField(
                  controller: _notaFiscalController,
                  decoration: InputDecoration(
                    labelText: 'Nota Fiscal',
                    hint: Text('Ex: 45217'),
                    prefixIcon: const Icon(Icons.receipt_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  onChanged: (val) => setState(
                    () => _tempFilters = _tempFilters.copyWith(notaFiscal: val),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _dateRangeController,
                  readOnly: true,
                  onTap: _selectDateRange,
                  decoration: InputDecoration(
                    labelText: 'Período (Início - Fim)',
                    prefixIcon: const Icon(Icons.date_range),
                    suffixIcon: _tempFilters.dataInicio != null
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                _tempFilters = _tempFilters.copyWith(
                                  dataInicio: null,
                                  dataFim: null,
                                );
                                _tempFilters = EntryFilterModel(
                                  notaFiscal: _tempFilters.notaFiscal,
                                  fornecedor: _tempFilters.fornecedor,
                                  produto: _tempFilters.produto,
                                  dataInicio: null,
                                  dataFim: null,
                                );
                                _dateRangeController.clear();
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                flex: 2,
                child: CustomAutocompleteField(
                  controller: _fornecedorController,
                  label: 'Fornecedor',
                  hint: 'Selecione...',
                  icon: Icons.business_outlined,
                  suggestions: widget.fornecedor,
                  showAddButton: false, // Filtro não adiciona
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: CustomAutocompleteField(
                  controller: _produtoController,
                  label: 'Produto (Item)',
                  hint: 'Selecione...',
                  icon: Icons.inventory_2_outlined,
                  suggestions: widget.produto,
                  showAddButton: false, // Filtro não adiciona
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: _hasChanges ? _apply : null,
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

  // Gerador de Chips
  List<Widget> _buildActiveFilterChips(ThemeData theme) {
    final chips = <Widget>[];
    final filtersMap = widget.appliedFilters.toMap();
    final filters = widget.appliedFilters;

    filtersMap.forEach((key, value) {
      if (key.endsWith('Operador')) return;

      String label = '';
      String displayValue = '';
      IconData icon = Icons.filter_alt;

      switch (key) {
        case 'data_inicio':
          final start = DateFormat('dd/MM/yyyy').format(filters.dataInicio!);
          final end = DateFormat('dd/MM/yyyy').format(filters.dataFim!);
          label = 'Período';
          displayValue = '$start até $end';
          icon = Icons.calendar_today;
          break;
        case 'nf_ref':
          label = 'NF';
          displayValue = value.toString();
          icon = Icons.receipt;
          break;
        case 'fornecedor':
          label = 'Fornecedor';
          displayValue = value.toString();
          icon = Icons.business;
          break;
        case 'produto':
          label = 'Produto';
          displayValue = value.toString();
          icon = Icons.inventory_2;
          break;
      }

      if (label.isNotEmpty) {
        chips.add(
          Chip(
            avatar: Icon(icon, size: 18),
            label: Text('$label: $displayValue'),
            onDeleted: () {
              final newFiltersMap = Map<String, dynamic>.from(filtersMap);
              newFiltersMap.remove(key);

              final newFilters = EntryFilterModel.fromMap(newFiltersMap);
              widget.onApplyFilters(newFilters);

              setState(() {
                _tempFilters = newFilters;
                if (key == 'nf_ref') _notaFiscalController.clear();
                if (key == 'fornecedor') _fornecedorController.clear();
                if (key == 'produto') _produtoController.clear();
                if (key == 'data_inicio' && key == 'data_fim') _dateRangeController.clear();
              });
            },
            deleteIcon: const Icon(Icons.close, size: 18),
          ),
        );
      }
    });
    

    return chips;
  }
}
