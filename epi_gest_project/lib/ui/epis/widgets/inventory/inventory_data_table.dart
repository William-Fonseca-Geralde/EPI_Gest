import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InventoryDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> inventories;

  const InventoryDataTable({super.key, required this.inventories});

  @override
  State<InventoryDataTable> createState() => _InventoryDataTableState();
}

class _InventoryDataTableState extends State<InventoryDataTable> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  List<Map<String, dynamic>> _sortedInventories = [];

  // Larguras das colunas
  static const double dataInventarioWidth = 140.0;
  static const double produtoWidth = 220.0;
  static const double caWidth = 120.0;
  static const double quantidadeSistemaWidth = 160.0;
  static const double novaQuantidadeWidth = 160.0;
  static const double diferencaWidth = 140.0;
  static const double acoesWidth = 120.0;

  static const double totalTableWidth =
      dataInventarioWidth +
      produtoWidth +
      caWidth +
      quantidadeSistemaWidth +
      novaQuantidadeWidth +
      diferencaWidth +
      acoesWidth;

  @override
  void initState() {
    super.initState();
    _sortedInventories = List.from(widget.inventories);
  }

  void _sortData(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      _sortedInventories.sort((a, b) {
        int compare = 0;
        switch (columnIndex) {
          case 0:
            compare = (a['dataInventario'] ?? DateTime.now())
                .compareTo(b['dataInventario'] ?? DateTime.now());
            break;
          case 1:
            compare = (a['produtoDescricao'] ?? '')
                .compareTo(b['produtoDescricao'] ?? '');
            break;
          case 2:
            compare = (a['ca'] ?? '').compareTo(b['ca'] ?? '');
            break;
          case 3:
            compare = (a['quantidadeSistema'] ?? 0)
                .compareTo(b['quantidadeSistema'] ?? 0);
            break;
          case 4:
            compare = (a['novaQuantidade'] ?? 0)
                .compareTo(b['novaQuantidade'] ?? 0);
            break;
          case 5:
            compare = (a['diferenca'] ?? 0).compareTo(b['diferenca'] ?? 0);
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
                  _buildHeaderCell('Data Inventário', dataInventarioWidth, 0),
                  _buildHeaderCell('Produto', produtoWidth, 1),
                  _buildHeaderCell('C.A', caWidth, 2),
                  _buildHeaderCell('Qtd. Sistema', quantidadeSistemaWidth, 3),
                  _buildHeaderCell('Nova Qtd.', novaQuantidadeWidth, 4),
                  _buildHeaderCell('Diferença', diferencaWidth, 5),
                  _buildHeaderCell('Ações', acoesWidth, -1, isLast: true),
                ],
              ),
            ),

            // Corpo da tabela
            Expanded(
              child: ListView.builder(
                itemCount: _sortedInventories.length,
                itemBuilder: (context, index) {
                  final inventory = _sortedInventories[index];
                  final isLast = index == _sortedInventories.length - 1;
                  final diferenca = (inventory['novaQuantidade'] ?? 0) - 
                                  (inventory['quantidadeSistema'] ?? 0);

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
                            width: dataInventarioWidth,
                            child: Text(
                              dateFormat.format(
                                inventory['dataInventario'] ?? DateTime.now(),
                              ),
                            ),
                          ),
                          _buildDataCell(
                            width: produtoWidth,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  inventory['produtoCodigo'] ?? '',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  inventory['produtoDescricao'] ?? '',
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
                                  inventory['ca'] ?? '',
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          _buildDataCell(
                            width: quantidadeSistemaWidth,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 16,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text('${inventory['quantidadeSistema'] ?? 0}'),
                              ],
                            ),
                          ),
                          _buildDataCell(
                            width: novaQuantidadeWidth,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.refresh,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text('${inventory['novaQuantidade'] ?? 0}'),
                              ],
                            ),
                          ),
                          _buildDataCell(
                            width: diferencaWidth,
                            child: Text(
                              '${diferenca >= 0 ? '+' : ''}$diferenca',
                              style: TextStyle(
                                color: diferenca == 0
                                    ? theme.colorScheme.onSurfaceVariant
                                    : diferenca > 0
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
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