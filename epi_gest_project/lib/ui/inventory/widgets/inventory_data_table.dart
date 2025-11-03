import 'package:epi_gest_project/domain/models/epi/epi_model.dart';
import 'package:epi_gest_project/ui/inventory/widgets/edit_epi_drawer.dart';
import 'package:epi_gest_project/ui/inventory/widgets/view_epi_drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Versão equilibrada: cabeçalho fixo + scroll sincronizado + largura estática original
class InventoryDataTable extends StatefulWidget {
  final List<EpiModel> epis;

  const InventoryDataTable({super.key, required this.epis});

  @override
  State<InventoryDataTable> createState() => _InventoryDataTableState();
}

class _InventoryDataTableState extends State<InventoryDataTable> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  List<EpiModel> _sortedEpis = [];

  // Scroll controllers independentes sincronizados
  final ScrollController _headerScrollController = ScrollController();
  final ScrollController _bodyScrollController = ScrollController();

  bool _isSyncingScroll = false;

  // Larguras estáticas originais
  static const double caWidth = 110.0;
  static const double nomeWidth = 260.0; // <=== voltou ao tamanho original
  static const double categoriaWidth = 210.0;
  static const double quantidadeWidth = 140.0;
  static const double valorWidth = 150.0;
  static const double validadeWidth = 160.0;
  static const double fornecedorWidth = 180.0;
  static const double acoesWidth = 160.0;

  // Largura total fixa (causa scroll se tela for menor)
  static const double totalTableWidth =
      caWidth +
      nomeWidth +
      categoriaWidth +
      quantidadeWidth +
      valorWidth +
      validadeWidth +
      fornecedorWidth +
      acoesWidth;

  @override
  void initState() {
    super.initState();
    _sortedEpis = List.from(widget.epis);
    // Sincronizar scroll horizontal (header x body)
    _headerScrollController.addListener(_syncFromHeader);
    _bodyScrollController.addListener(_syncFromBody);
  }

  void _syncFromHeader() {
    if (_isSyncingScroll) return;
    _isSyncingScroll = true;
    _bodyScrollController.jumpTo(_headerScrollController.offset);
    _isSyncingScroll = false;
  }

  void _syncFromBody() {
    if (_isSyncingScroll) return;
    _isSyncingScroll = true;
    _headerScrollController.jumpTo(_bodyScrollController.offset);
    _isSyncingScroll = false;
  }

  @override
  void dispose() {
    _headerScrollController.removeListener(_syncFromHeader);
    _bodyScrollController.removeListener(_syncFromBody);
    _headerScrollController.dispose();
    _bodyScrollController.dispose();
    super.dispose();
  }

  void _sortData(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      _sortedEpis.sort((a, b) {
        int compare;
        switch (columnIndex) {
          case 0:
            compare = a.ca.compareTo(b.ca);
            break;
          case 1:
            compare = a.nome.compareTo(b.nome);
            break;
          case 2:
            compare = a.categoria.compareTo(b.categoria);
            break;
          case 3:
            compare = a.quantidadeEstoque.compareTo(b.quantidadeEstoque);
            break;
          case 4:
            compare = a.valorUnitario.compareTo(b.valorUnitario);
            break;
          case 5:
            compare = a.dataValidade.compareTo(b.dataValidade);
            break;
          case 6:
            compare = a.fornecedor.compareTo(b.fornecedor);
            break;
          default:
            compare = 0;
        }
        return ascending ? compare : -compare;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
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
            // ====== CABEÇALHO FIXO ======
            SingleChildScrollView(
              controller: _headerScrollController,
              scrollDirection: Axis.horizontal,
              child: Container(
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
                    _buildHeaderCell('CA', caWidth, 0),
                    _buildHeaderCell('Nome do EPI', nomeWidth, 1),
                    _buildHeaderCell('Categoria', categoriaWidth, 2),
                    _buildHeaderCell(
                      'Quantidade',
                      quantidadeWidth,
                      3,
                      numeric: true,
                    ),
                    _buildHeaderCell(
                      'Valor Unitário',
                      valorWidth,
                      4,
                      numeric: true,
                    ),
                    _buildHeaderCell('Validade', validadeWidth, 5),
                    _buildHeaderCell('Fornecedor', fornecedorWidth, 6),
                    _buildHeaderCell('Ações', acoesWidth, -1, isLast: true),
                  ],
                ),
              ),
            ),

            // ====== CORPO DA TABELA ======
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                controller: _bodyScrollController,
                child: SingleChildScrollView(
                  controller: _bodyScrollController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: totalTableWidth,
                    child: ListView.builder(
                      itemCount: _sortedEpis.length,
                      itemBuilder: (context, index) {
                        final epi = _sortedEpis[index];
                        final isLast = index == _sortedEpis.length - 1;

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
                                  width: caWidth,
                                  context: context,
                                  child: Container(
                                    margin: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Text(
                                        epi.ca,
                                        style: TextStyle(
                                          color: theme
                                              .colorScheme
                                              .onPrimaryContainer,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                _buildDataCell(
                                  width: nomeWidth,
                                  context: context,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        epi.nome,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      Text(
                                        epi.descricao,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildDataCell(
                                  width: categoriaWidth,
                                  context: context,
                                  child: Text(epi.categoria),
                                ),
                                _buildDataCell(
                                  width: quantidadeWidth,
                                  context: context,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.inventory_2_outlined,
                                        size: 16,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text('${epi.quantidadeEstoque}'),
                                    ],
                                  ),
                                ),
                                _buildDataCell(
                                  width: valorWidth,
                                  context: context,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        currencyFormat.format(
                                          epi.valorUnitario,
                                        ),
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildDataCell(
                                  width: validadeWidth,
                                  context: context,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(dateFormat.format(epi.dataValidade)),
                                      if (epi.isVencido ||
                                          epi.isProximoVencimento)
                                        Text(
                                          epi.isVencido
                                              ? 'Venceu há ${DateTime.now().difference(epi.dataValidade).inDays} dias'
                                              : 'Vence em ${epi.dataValidade.difference(DateTime.now()).inDays} dias',
                                          style: TextStyle(
                                            color: epi.isVencido
                                                ? theme.colorScheme.error
                                                : Colors.orange,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                _buildDataCell(
                                  width: fornecedorWidth,
                                  context: context,
                                  child: Text(epi.fornecedor),
                                ),
                                _buildDataCell(
                                  width: acoesWidth,
                                  isLast: true,
                                  context: context,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.visibility_outlined,
                                        ),
                                        tooltip: 'Visualizar',
                                        onPressed: () {
                                          showGeneralDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            barrierLabel: 'View EPI',
                                            transitionDuration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            pageBuilder:
                                                (
                                                  context,
                                                  animation,
                                                  secondaryAnimation,
                                                ) {
                                                  return ViewEpiDrawer(
                                                    epi: epi,
                                                    onClose: () => Navigator.of(
                                                      context,
                                                    ).pop(),
                                                  );
                                                },
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined),
                                        tooltip: 'Editar',
                                        onPressed: () {
                                          showGeneralDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            barrierLabel: 'Edit EPI',
                                            transitionDuration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            pageBuilder:
                                                (
                                                  context,
                                                  animation,
                                                  secondaryAnimation,
                                                ) {
                                                  return EditEpiDrawer(
                                                    epi: epi,
                                                    onClose: () => Navigator.of(
                                                      context,
                                                    ).pop(),
                                                    onSave: (data) {
                                                      // TODO: Implementar salvamento real
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                    },
                                                  );
                                                },
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: theme.colorScheme.error,
                                        ),
                                        tooltip: 'Excluir',
                                        onPressed: () {},
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
    bool numeric = false,
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
    required BuildContext context,
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
