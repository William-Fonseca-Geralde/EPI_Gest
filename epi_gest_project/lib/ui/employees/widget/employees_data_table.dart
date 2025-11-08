// lib/ui/employees/widget/employees_data_table.dart (VERSÃO ATUALIZADA)

import 'package:epi_gest_project/domain/models/employee/employee_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmployeesDataTable extends StatefulWidget {
  // MODIFICADO: Recebe uma lista de Employee e callbacks
  final List<Employee> employees;
  final Function(Employee) onView;
  final Function(Employee) onEdit;
  final Function(Employee) onInactivate;

  const EmployeesDataTable({
    super.key,
    required this.employees,
    required this.onView,
    required this.onEdit,
    required this.onInactivate,
  });

  @override
  State<EmployeesDataTable> createState() => _EmployeesDataTableState();
}

class _EmployeesDataTableState extends State<EmployeesDataTable> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  late List<Employee> _sortedEmployees; // MODIFICADO: Usa o modelo Employee

  final ScrollController _headerScrollController = ScrollController();
  final ScrollController _bodyScrollController = ScrollController();
  bool _isSyncingScroll = false;

  static const double idWidth = 110.0;
  static const double nomeWidth = 280.0;
  static const double setorWidth = 200.0;
  static const double funcaoWidth = 220.0;
  static const double dataEntradaWidth = 160.0;
  static const double acoesWidth = 160.0;
  static const double totalTableWidth =
      idWidth +
      nomeWidth +
      setorWidth +
      funcaoWidth +
      dataEntradaWidth +
      acoesWidth;

  @override
  void initState() {
    super.initState();
    _sortedEmployees = List.from(widget.employees);
    _headerScrollController.addListener(_syncFromHeader);
    _bodyScrollController.addListener(_syncFromBody);
  }

  // ADICIONADO: didUpdateWidget para atualizar a lista quando os filtros mudam
  @override
  void didUpdateWidget(covariant EmployeesDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.employees != oldWidget.employees) {
      setState(() {
        _sortedEmployees = List.from(widget.employees);
        // Re-aplica a ordenação atual
        _sortData(_sortColumnIndex, _sortAscending, applySetState: false);
      });
    }
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

  // MODIFICADO: Lógica de ordenação para usar o modelo Employee
  void _sortData(int columnIndex, bool ascending, {bool applySetState = true}) {
    void sort() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      _sortedEmployees.sort((a, b) {
        int compare;
        switch (columnIndex) {
          case 0:
            compare = a.matricula.compareTo(b.matricula);
            break;
          case 1:
            compare = a.nome.compareTo(b.nome);
            break;
          case 2:
            compare = (a.setor ?? '').compareTo(b.setor ?? '');
            break;
          case 3:
            compare = (a.vinculo ?? '').compareTo(b.vinculo ?? '');
            break;
          case 4:
            compare = a.dataEntrada.compareTo(b.dataEntrada);
            break;
          default:
            compare = 0;
        }
        return ascending ? compare : -compare;
      });
    }

    if (applySetState) {
      setState(sort);
    } else {
      sort();
    }
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
                    _buildHeaderCell('ID', idWidth, 0),
                    _buildHeaderCell('Nome do Funcionário', nomeWidth, 1),
                    _buildHeaderCell('Setor', setorWidth, 2),
                    _buildHeaderCell('Função na Empresa', funcaoWidth, 3),
                    _buildHeaderCell('Data de Entrada', dataEntradaWidth, 4),
                    _buildHeaderCell('Ações', acoesWidth, -1, isLast: true),
                  ],
                ),
              ),
            ),
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
                      itemCount: _sortedEmployees.length,
                      itemBuilder: (context, index) {
                        final employee = _sortedEmployees[index];
                        final isLast = index == _sortedEmployees.length - 1;

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
                                // MODIFICADO: Usa dados do modelo Employee
                                _buildDataCell(
                                  width: idWidth,
                                  context: context,
                                  child: Container(
                                    margin: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Text(
                                        employee.matricula,
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
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor:
                                            theme.colorScheme.primaryContainer,
                                        backgroundImage:
                                            employee.imagemPath != null
                                            ? NetworkImage(employee.imagemPath!)
                                            : null,
                                        child: employee.imagemPath == null
                                            ? Text(
                                                employee.nome.isNotEmpty
                                                    ? employee.nome[0]
                                                          .toUpperCase()
                                                    : '',
                                                style: TextStyle(
                                                  color: theme
                                                      .colorScheme
                                                      .onPrimaryContainer,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          employee.nome,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildDataCell(
                                  width: setorWidth,
                                  context: context,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.business_outlined,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          employee.setor ?? '-',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildDataCell(
                                  width: funcaoWidth,
                                  context: context,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.work_outline,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          employee.vinculo ?? '-',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildDataCell(
                                  width: dataEntradaWidth,
                                  context: context,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dateFormat.format(employee.dataEntrada),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _getTempoServico(employee.dataEntrada),
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
                                _buildDataCell(
                                  width: acoesWidth,
                                  isLast: true,
                                  context: context,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // MODIFICADO: Usa callbacks
                                      IconButton(
                                        icon: const Icon(
                                          Icons.visibility_outlined,
                                        ),
                                        tooltip: 'Visualizar',
                                        onPressed: () =>
                                            widget.onView(employee),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined),
                                        tooltip: 'Editar',
                                        onPressed: () =>
                                            widget.onEdit(employee),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.person_off_outlined,
                                          color: theme.colorScheme.error,
                                        ),
                                        tooltip: 'Inativar',
                                        onPressed: () =>
                                            widget.onInactivate(employee),
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

  // ... (Seus métodos _buildHeaderCell, _buildDataCell, _getTempoServico estão perfeitos e não precisam de alteração)
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
                  color: theme.colorScheme.outlineVariant.withOpacity(0.3),
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
                  color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                ),
        ),
      ),
      child: child,
    );
  }

  String _getTempoServico(DateTime dataEntrada) {
    final agora = DateTime.now();
    final diferenca = agora.difference(dataEntrada);
    final anos = diferenca.inDays ~/ 365;
    final meses = (diferenca.inDays % 365) ~/ 30;
    if (anos > 0) {
      return '$anos ${anos == 1 ? 'ano' : 'anos'}${meses > 0 ? ' e $meses ${meses == 1 ? 'mês' : 'meses'}' : ''}';
    } else if (meses > 0) {
      return '$meses ${meses == 1 ? 'mês' : 'meses'}';
    } else {
      final dias = diferenca.inDays;
      return '$dias ${dias == 1 ? 'dia' : 'dias'}';
    }
  }
}
