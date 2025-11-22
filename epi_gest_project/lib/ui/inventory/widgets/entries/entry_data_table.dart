import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EntryDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> entries;

  const EntryDataTable({super.key, required this.entries});

  @override
  State<EntryDataTable> createState() => _EntryDataTableState();
}

class _EntryDataTableState extends State<EntryDataTable> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  List<Map<String, dynamic>> _sortedEntries = [];

  // Larguras das colunas
  static const double notaFiscalWidth = 140.0;
  static const double dataEntregaWidth = 140.0;
  static const double fornecedorWidth = 200.0;
  static const double produtoWidth = 220.0;
  static const double caWidth = 120.0;
  static const double quantidadeWidth = 140.0;
  static const double acoesWidth = 120.0;

  static const double totalTableWidth =
      notaFiscalWidth +
      dataEntregaWidth +
      fornecedorWidth +
      produtoWidth +
      caWidth +
      quantidadeWidth +
      acoesWidth;

  @override
  void initState() {
    super.initState();
    _sortedEntries = List.from(widget.entries);
  }

  void _sortData(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      _sortedEntries.sort((a, b) {
        int compare = 0;
        switch (columnIndex) {
          case 0:
            compare = (a['notaFiscal'] ?? '').compareTo(b['notaFiscal'] ?? '');
            break;
          case 1:
            compare = (a['dataEntrega'] ?? DateTime.now())
                .compareTo(b['dataEntrega'] ?? DateTime.now());
            break;
          case 2:
            compare = (a['fornecedorDescricao'] ?? '')
                .compareTo(b['fornecedorDescricao'] ?? '');
            break;
          case 3:
            compare = (a['produtoDescricao'] ?? '')
                .compareTo(b['produtoDescricao'] ?? '');
            break;
          case 4:
            compare = (a['ca'] ?? '').compareTo(b['ca'] ?? '');
            break;
          case 5:
            compare = (a['quantidade'] ?? 0).compareTo(b['quantidade'] ?? 0);
            break;
        }
        return ascending ? compare : -compare;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

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
              child: Row(
                children: [
                  _buildHeaderCell('Nota Fiscal', notaFiscalWidth, 0),
                  _buildHeaderCell('Data Entrega', dataEntregaWidth, 1),
                  _buildHeaderCell('Fornecedor', fornecedorWidth, 2),
                  _buildHeaderCell('Produto', produtoWidth, 3),
                  _buildHeaderCell('C.A', caWidth, 4),
                  _buildHeaderCell('Quantidade', quantidadeWidth, 5),
                  _buildHeaderCell('Ações', acoesWidth, -1, isLast: true),
                ],
              ),
            ),

            // Corpo da tabela
            Expanded(
              child: ListView.builder(
                itemCount: _sortedEntries.length,
                itemBuilder: (context, index) {
                  final entry = _sortedEntries[index];
                  final isLast = index == _sortedEntries.length - 1;

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
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildDataCell(
                            width: notaFiscalWidth,
                            child: Text(entry['notaFiscal'] ?? ''),
                          ),
                          _buildDataCell(
                            width: dataEntregaWidth,
                            child: Text(
                              dateFormat.format(
                                entry['dataEntrega'] ?? DateTime.now(),
                              ),
                            ),
                          ),
                          _buildDataCell(
                            width: fornecedorWidth,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry['fornecedorCodigo'] ?? '',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  entry['fornecedorDescricao'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          _buildDataCell(
                            width: produtoWidth,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry['produtoCodigo'] ?? '',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  entry['produtoDescricao'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          _buildDataCell(
                            width: caWidth,
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  entry['ca'] ?? '',
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          _buildDataCell(
                            width: quantidadeWidth,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 16,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text('${entry['quantidade'] ?? 0}'),
                              ],
                            ),
                          ),
                          _buildDataCell(
                            width: acoesWidth,
                            isLast: true,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined),
                                  tooltip: 'Visualizar',
                                  onPressed: () {
                                    // TODO: Implementar visualização
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  tooltip: 'Editar',
                                  onPressed: () {
                                    // TODO: Implementar edição
                                  },
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
  }) {
    final theme = Theme.of(context);
    final isActive = columnIndex == _sortColumnIndex;

    return Container(
      width: width,
      height: 56,
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
      child: InkWell(
        onTap: columnIndex >= 0
            ? () => _sortData(columnIndex, !_sortAscending)
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
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
      ),
    );
  }

  Widget _buildDataCell({
    required double width,
    required Widget child,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          right: isLast
              ? BorderSide.none
              : BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  ),
                ),
        ),
      ),
      child: child,
    );
  }
}