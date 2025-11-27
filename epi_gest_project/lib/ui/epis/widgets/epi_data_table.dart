import 'package:epi_gest_project/domain/models/epi_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EpiDataTable extends StatefulWidget {
  final List<EpiModel> epis;
  final Function(EpiModel) onView;
  final Function(EpiModel) onEdit;

  const EpiDataTable({
    super.key,
    required this.epis,
    required this.onView,
    required this.onEdit,
  });

  @override
  State<EpiDataTable> createState() => _EpiDataTableState();
}

class _EpiDataTableState extends State<EpiDataTable> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  List<EpiModel> _sortedEpis = [];

  final ScrollController _headerScrollController = ScrollController();
  final ScrollController _bodyScrollController = ScrollController();

  bool _isSyncingScroll = false;

  // Larguras estáticas ajustadas
  static const double caWidth = 110.0;
  static const double nomeWidth = 260.0;
  static const double categoriaWidth = 210.0;
  static const double quantidadeWidth = 140.0;
  static const double valorWidth = 150.0;
  static const double validadeWidth = 160.0;
  static const double acoesWidth = 160.0;

  static const double totalTableWidth =
      caWidth +
      nomeWidth +
      categoriaWidth +
      quantidadeWidth +
      valorWidth +
      validadeWidth +
      acoesWidth;

  @override
  void initState() {
    super.initState();
    _sortedEpis = List.from(widget.epis);
    _headerScrollController.addListener(_syncFromHeader);
    _bodyScrollController.addListener(_syncFromBody);
  }

  @override
  void didUpdateWidget(EpiDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.epis != oldWidget.epis) {
      setState(() {
        _sortedEpis = List.from(widget.epis);
        // Re-aplica a ordenação se necessário
        _sortData(_sortColumnIndex, _sortAscending, updateState: false);
      });
    }
  }

  void _syncFromHeader() {
    if (_isSyncingScroll) return;
    _isSyncingScroll = true;
    if (_bodyScrollController.hasClients) {
      _bodyScrollController.jumpTo(_headerScrollController.offset);
    }
    _isSyncingScroll = false;
  }

  void _syncFromBody() {
    if (_isSyncingScroll) return;
    _isSyncingScroll = true;
    if (_headerScrollController.hasClients) {
      _headerScrollController.jumpTo(_bodyScrollController.offset);
    }
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

  void _sortData(int columnIndex, bool ascending, {bool updateState = true}) {
    void sortLogic() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      _sortedEpis.sort((a, b) {
        int compare;
        switch (columnIndex) {
          case 0: // CA
            compare = a.ca.compareTo(b.ca);
            break;
          case 1: // Nome Produto
            compare = a.nomeProduto.compareTo(b.nomeProduto);
            break;
          case 2: // Categoria (Objeto)
            compare = a.categoria.nomeCategoria.compareTo(
              b.categoria.nomeCategoria,
            );
            break;
          case 3: // Estoque (Double)
            compare = a.estoque.compareTo(b.estoque);
            break;
          case 4: // Valor (Double)
            compare = a.valor.compareTo(b.valor);
            break;
          case 5: // Validade CA (DateTime)
            compare = a.validadeCa.compareTo(b.validadeCa);
            break;
          case 6: // Marca (Objeto)
            compare = a.marca.nomeMarca.compareTo(b.marca.nomeMarca);
            break;
          default:
            compare = 0;
        }
        return ascending ? compare : -compare;
      });
    }

    if (updateState) {
      setState(sortLogic);
    } else {
      sortLogic();
    }
  }

  // Lógica auxiliar para status de vencimento
  bool _isVencido(DateTime validade) {
    return DateTime.now().isAfter(validade);
  }

  bool _isProximoVencimento(DateTime validade) {
    final diasParaVencimento = validade.difference(DateTime.now()).inDays;
    return diasParaVencimento <= 30 && diasParaVencimento > 0;
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
                      'Estoque',
                      quantidadeWidth,
                      3,
                      numeric: true,
                    ),
                    _buildHeaderCell(
                      'Valor Unit.',
                      valorWidth,
                      4,
                      numeric: true,
                    ),
                    _buildHeaderCell('Validade CA', validadeWidth, 5),
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

                        // Lógica local de vencimento
                        final bool vencido = _isVencido(epi.validadeCa);
                        final bool proximoVencimento = _isProximoVencimento(
                          epi.validadeCa,
                        );

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
                                // CA
                                _buildDataCell(
                                  width: caWidth,
                                  context: context,
                                  child: Container(
                                    margin: const EdgeInsets.all(5),
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
                                // NOME PRODUTO
                                _buildDataCell(
                                  width: nomeWidth,
                                  context: context,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        epi.nomeProduto,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      // Exibindo unidade de medida como subtítulo
                                      Text(
                                        'Unidade: ${epi.medida.nomeMedida}',
                                        style: TextStyle(
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // CATEGORIA
                                _buildDataCell(
                                  width: categoriaWidth,
                                  context: context,
                                  child: Text(epi.categoria.nomeCategoria),
                                ),
                                // ESTOQUE
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
                                      Text(
                                        epi.estoque % 1 == 0
                                            ? epi.estoque.toInt().toString()
                                            : epi.estoque.toString(),
                                      ),
                                    ],
                                  ),
                                ),
                                // VALOR
                                _buildDataCell(
                                  width: valorWidth,
                                  context: context,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        currencyFormat.format(epi.valor),
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // VALIDADE CA
                                _buildDataCell(
                                  width: validadeWidth,
                                  context: context,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(dateFormat.format(epi.validadeCa)),
                                      if (vencido || proximoVencimento)
                                        Text(
                                          vencido
                                              ? 'Venceu há ${DateTime.now().difference(epi.validadeCa).inDays} dias'
                                              : 'Vence em ${epi.validadeCa.difference(DateTime.now()).inDays} dias',
                                          style: TextStyle(
                                            color: vencido
                                                ? theme.colorScheme.error
                                                : Colors.orange,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // AÇÕES
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
                                        onPressed: () => widget.onView(epi),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined),
                                        tooltip: 'Editar',
                                        onPressed: () => widget.onEdit(epi),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: theme.colorScheme.error,
                                        ),
                                        tooltip: 'Excluir',
                                        onPressed: () {
                                          // TODO: Implementar diálogo de confirmação e exclusão
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
