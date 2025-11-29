import 'package:epi_gest_project/domain/models/entradas_model.dart';
import 'package:epi_gest_project/ui/epis/widgets/entries/entry_drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EntryDataTable extends StatefulWidget {
  final List<EntradasModel> entries;
  final Function(EntradasModel) onDelete;

  const EntryDataTable({
    super.key,
    required this.entries,
    required this.onDelete,
  });

  @override
  State<EntryDataTable> createState() => _EntryDataTableState();
}

class _EntryDataTableState extends State<EntryDataTable> {
  int _sortColumnIndex = 0;
  bool _sortAscending = false;
  List<EntradasModel> _sortedEntries = [];

  // Larguras das colunas
  static const double dataWidth = 140.0;
  static const double nfWidth = 160.0;
  static const double fornecedorWidth = 250.0;
  static const double qtdItensWidth = 120.0;
  static const double totalWidth = 160.0;
  static const double acoesWidth = 120.0;

  static const double totalTableWidth =
      dataWidth +
      nfWidth +
      fornecedorWidth +
      qtdItensWidth +
      totalWidth +
      acoesWidth;

  @override
  void initState() {
    super.initState();
    _updateSortedEntries();
  }

  @override
  void didUpdateWidget(EntryDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entries != oldWidget.entries) {
      _updateSortedEntries();
    }
  }

  void _updateSortedEntries() {
    setState(() {
      _sortedEntries = List.from(widget.entries);
      _sortData(_sortColumnIndex, _sortAscending, updateState: false);
    });
  }

  void _sortData(int columnIndex, bool ascending, {bool updateState = true}) {
    void sort() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      _sortedEntries.sort((a, b) {
        int compare = 0;
        switch (columnIndex) {
          case 0: // Data
            final dateA = a.dataEntrada;
            final dateB = b.dataEntrada;
            compare = dateA.compareTo(dateB);
            break;
          case 1: // NF
            compare = a.nfReferente.compareTo(b.nfReferente);
            break;
          case 2: // Fornecedor
            compare = a.fornecedorId.nomeFornecedor.compareTo(
              b.fornecedorId.nomeFornecedor,
            );
            break;
          case 4: // Total R$
            final totalA = a.entradasId.fold(
              0.0,
              (sum, e) => sum + (e.quantidade * e.valor),
            );
            final totalB = b.entradasId.fold(
              0.0,
              (sum, e) => sum + (e.quantidade * e.valor),
            );
            compare = totalA.compareTo(totalB);
            break;
        }
        return ascending ? compare : -compare;
      });
    }

    if (updateState) {
      setState(sort);
    } else {
      sort();
    }
  }

  void _showDetails(EntradasModel entrada) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Detalhes da Entrada',
      pageBuilder: (context, _, __) => EntryDrawer(
        onClose: () => Navigator.of(context).pop(),
        entradaToView: entrada,
        view: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Cabeçalho
            Container(
              width: totalTableWidth,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                    width: 2,
                  ),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildHeaderCell('Nº Nota Fiscal', nfWidth, 0),
                    _buildHeaderCell('Data', dataWidth, 1),
                    _buildHeaderCell('Fornecedor', fornecedorWidth, 2),
                    _buildHeaderCell(
                      'Qtd. Itens',
                      qtdItensWidth,
                      3,
                      numeric: true,
                    ),
                    _buildHeaderCell(
                      'Valor Total',
                      totalWidth,
                      4,
                      numeric: true,
                    ),
                    _buildHeaderCell('Ações', acoesWidth, -1, isLast: true),
                  ],
                ),
              ),
            ),

            // Corpo da tabela
            Expanded(
              child: _sortedEntries.isEmpty
                  ? const Center(child: Text("Nenhuma entrada encontrada"))
                  : SizedBox(
                      width: totalTableWidth,
                      child: ListView.builder(
                        itemCount: _sortedEntries.length,
                        itemBuilder: (context, index) {
                          final entry = _sortedEntries[index];
                          final isLast = index == _sortedEntries.length - 1;

                          // Cálculos para exibição
                          final totalValue = entry.entradasId.fold(
                            0.0,
                            (sum, item) => sum + (item.quantidade * item.valor),
                          );
                          final totalItems = entry.entradasId.length;

                          return Container(
                            decoration: BoxDecoration(
                              color: index.isEven
                                  ? theme.colorScheme.surface
                                  : theme.colorScheme.surfaceContainerLowest,
                              border: Border(
                                bottom: isLast
                                    ? BorderSide.none
                                    : BorderSide(
                                        color: theme.colorScheme.outlineVariant
                                            .withValues(alpha: 0.3),
                                      ),
                              ),
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _buildDataCell(
                                    width: nfWidth,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme
                                            .colorScheme
                                            .secondaryContainer,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        entry.nfReferente,
                                        style: TextStyle(
                                          color: theme
                                              .colorScheme
                                              .onSecondaryContainer,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  _buildDataCell(
                                    width: dataWidth,
                                    child: Text(
                                      dateFormat.format(entry.dataEntrada),
                                    ),
                                  ),
                                  _buildDataCell(
                                    width: fornecedorWidth,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry.fornecedorId.nomeFornecedor,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          entry.fornecedorId.cnpj,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildDataCell(
                                    width: qtdItensWidth,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(
                                          Icons.layers,
                                          size: 16,
                                          color: theme.colorScheme.outline,
                                        ),
                                        const SizedBox(width: 8),
                                        Text('$totalItems tipos'),
                                      ],
                                    ),
                                  ),
                                  _buildDataCell(
                                    width: totalWidth,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          currencyFormat.format(totalValue),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildDataCell(
                                    width: acoesWidth,
                                    isLast: true,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.visibility_outlined,
                                          ),
                                          tooltip: 'Ver Itens',
                                          onPressed: () => _showDetails(entry),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          tooltip: 'Excluir Entrada',
                                          color: theme.colorScheme.error,
                                          onPressed: () =>
                                              widget.onDelete(entry),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(
    String label,
    double width,
    int columnIndex, {
    bool isLast = false,
    bool numeric = false,
  }) {
    final theme = Theme.of(context);
    final isActive = columnIndex == _sortColumnIndex;

    return InkWell(
      onTap: columnIndex >= 0
          ? () => _sortData(columnIndex, !_sortAscending)
          : null,
      child: Container(
        width: width,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            right: isLast
                ? BorderSide.none
                : BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.3,
                    ),
                    width: 1,
                  ),
          ),
        ),
        child: Row(
          mainAxisAlignment: numeric
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
            if (columnIndex >= 0)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  isActive
                      ? (_sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward)
                      : Icons.unfold_more,
                  size: 16,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCell({
    required double width,
    required Widget child,
    bool isLast = false,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          right: isLast
              ? BorderSide.none
              : BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
        ),
      ),
      child: child,
    );
  }
}
