import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/data/services/funcionarios/funcionario_repository.dart';
import 'package:epi_gest_project/data/services/funcionarios/mapeamento_funcionario_repository.dart';
import 'package:epi_gest_project/domain/models/filters/funcionario_filter_model.dart';
import 'package:epi_gest_project/domain/models/funcionarios/funcionario_model.dart';
import 'package:epi_gest_project/domain/models/funcionarios/mapeamento_funcionario_model.dart';
import 'package:epi_gest_project/ui/employees/widget/employee_drawer.dart';
import 'package:epi_gest_project/ui/employees/widget/employees_data_table.dart';
import 'package:epi_gest_project/ui/employees/widget/employees_filters.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  bool _showFilters = false;

  late Future<void> _loadEmployeesFuture;
  List<String> _availableMappings = [];
  List<FuncionarioModel> _allEmployees = [];
  List<FuncionarioModel> _filteredEmployees = [];
  FuncionarioFilterModel _appliedFilters = FuncionarioFilterModel.empty();
  Map<String, String> _employeeMappingMap = {};

  final _motivoController = TextEditingController();

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadEmployeesFuture = _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    try {
      final funcRepo = Provider.of<FuncionarioRepository>(
        context,
        listen: false,
      );
      final mapFuncRepo = Provider.of<MapeamentoFuncionarioRepository>(
        context,
        listen: false,
      );

      final results = await Future.wait([
        funcRepo.getAllFuncionarios(),
        mapFuncRepo.getAllRelations(),
      ]);

      final employees = results[0] as List<FuncionarioModel>;
      final mappings = results[1] as List<MapeamentoFuncionarioModel>;

      final mappingMap = <String, String>{};
      final mappingNames = <String>{};
      for (var map in mappings) {
        if (map.funcionario.id != null) {
          mappingMap[map.funcionario.id!] = map.mapeamento.nomeMapeamento;
          mappingNames.add(map.mapeamento.nomeMapeamento);
        }
      }

      if (mounted) {
        setState(() {
          _allEmployees = employees;
          _employeeMappingMap = mappingMap;
          _availableMappings = mappingNames.toList()..sort();
          _applyFilters(_appliedFilters, updateState: false);
        });
      }
    } on AppwriteException catch (e) {
      throw Exception('Falha ao carregar funcionários: ${e.message}');
    } catch (e) {
      throw Exception('Ocorreu um erro inesperado: ${e.toString()}');
    }
  }

  void _reloadData() {
    setState(() {
      _loadEmployeesFuture = _loadEmployees();
    });
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  void _applyFilters(
    FuncionarioFilterModel filters, {
    bool updateState = true,
  }) {
    void performFilter() {
      _appliedFilters = filters;
      if (filters.isEmpty) {
        _filteredEmployees = List.from(_allEmployees);
        return;
      }
      _filteredEmployees = _allEmployees.where((employee) {
        // Filtro por Nome
        if (filters.nome != null &&
            !employee.nomeFunc.toLowerCase().contains(
              filters.nome!.toLowerCase(),
            )) {
          return false;
        }

        // Filtro por Matrícula
        if (filters.matricula != null &&
            !employee.matricula.toLowerCase().contains(
              filters.matricula!.toLowerCase(),
            )) {
          return false;
        }

        // Filtro por Status
        if (filters.status != null && filters.status!.isNotEmpty) {
          final isAtivo = filters.status!.contains('Ativo');
          final isInativo = filters.status!.contains('Inativo');

          if (isAtivo && !isInativo && !employee.statusAtivo) return false;
          if (isInativo && !isAtivo && employee.statusAtivo) return false;
        }

        // Filtro por Data
        if (filters.dataEntrada != null) {
          final fDate = filters.dataEntrada!;
          final eDate = employee.dataEntrada;
          if (eDate.year != fDate.year ||
              eDate.month != fDate.month ||
              eDate.day != fDate.day) {
            return false;
          }
        }

        // Filtro por Mapeamento
        if (filters.mapeamentos != null && filters.mapeamentos!.isNotEmpty) {
          final employeeMapping = _employeeMappingMap[employee.id];
          if (employeeMapping == null ||
              !filters.mapeamentos!.contains(employeeMapping)) {
            return false;
          }
        }

        return true;
      }).toList();
    }

    if (updateState) {
      setState(performFilter);
    } else {
      performFilter();
    }
  }

  void _clearFilters() {
    setState(() {
      _appliedFilters = FuncionarioFilterModel.empty();
      _filteredEmployees = List.from(_allEmployees);
    });
  }

  void _showAddEmployeeDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Adicionar Funcionário',
      pageBuilder: (context, _, __) => EmployeeDrawer(
        onClose: () => Navigator.of(context).pop(),
        onSave: () {
          _reloadData();
        },
      ),
    );
  }

  void _showEditEmployeeDrawer(FuncionarioModel employee) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Editar Funcionário',
      pageBuilder: (context, _, __) => EmployeeDrawer(
        employeeToEdit: employee,
        onClose: () => Navigator.of(context).pop(),
        onSave: () {
          _reloadData();
        },
      ),
    );
  }

  void _showViewEmployeeDrawer(FuncionarioModel employee) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Visualizar Funcionário',
      pageBuilder: (context, _, __) => EmployeeDrawer(
        employeeToEdit: employee,
        view: true,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _inativarFuncionario(FuncionarioModel employee) async {
    _motivoController.clear();
    final theme = Theme.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        bool ativarMotivo = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Confirmar Inativação'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 16,
                      children: [
                        Expanded(
                          child: Text(
                            'Deseja adicionar um motivo para a inativação para o ${employee.nomeFunc}?',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        Switch(
                          value: ativarMotivo,
                          thumbIcon: WidgetStateProperty<Icon>.fromMap({
                            WidgetState.selected: Icon(Icons.check),
                            WidgetState.any: Icon(Icons.close),
                          }),
                          onChanged: (value) {
                            setDialogState(() {
                              ativarMotivo = value;

                              if (!ativarMotivo) {
                                _motivoController.clear();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    TextField(
                      controller: _motivoController,
                      enabled: ativarMotivo,
                      decoration: InputDecoration(
                        labelText: 'Motivo do Desligamento',
                        hintText: 'Digite o motivo (opcional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Inativar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirm == true) {
      if (!mounted) return;
      final repository = Provider.of<FuncionarioRepository>(
        context,
        listen: false,
      );
      try {
        await repository.inactivateEmployee(
          employee.id!,
          motivo: _motivoController.text.trim().isNotEmpty
              ? _motivoController.text.trim()
              : null,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Funcionário inativado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        _reloadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao inativar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _ativarFuncionario(FuncionarioModel employee) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Ativação'),
        content: Text(
          'Tem certeza que deseja ativar novamente ${employee.nomeFunc}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ativar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      final repository = Provider.of<FuncionarioRepository>(
        context,
        listen: false,
      );
      try {
        await repository.activateEmployee(employee.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Funcionário ativado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        _reloadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao ativar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(theme),
          const Divider(height: 1),
          if (_showFilters)
            EmployeesFilters(
              appliedFilters: _appliedFilters,
              mapeamentos: _availableMappings,
              onApplyFilters: (filters) => _applyFilters(filters),
              onClearFilters: _clearFilters,
            ),
          Expanded(
            child: FutureBuilder(
              future: _loadEmployeesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    spacing: 16,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      Text('Carregando dados...'),
                    ],
                  );
                }
                if (snapshot.hasError) {
                  return _buildErrorState(theme, snapshot.error.toString());
                }
                if (_filteredEmployees.isEmpty) {
                  return _buildEmptyState(theme);
                }
                return EmployeesDataTable(
                  employees: _filteredEmployees,
                  employeeMappings: _employeeMappingMap,
                  onView: _showViewEmployeeDrawer,
                  onEdit: _showEditEmployeeDrawer,
                  onInactivate: _inativarFuncionario,
                  onActivate: _ativarFuncionario,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.08),
            colorScheme.surface.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          topLeft: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: 16,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.people,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 40,
                ),
              ),
              Column(
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Funcionários',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    '${_filteredEmployees.length} de ${_allEmployees.length} ${_allEmployees.length == 1 ? 'funcionário' : 'funcionários'}${!_appliedFilters.isEmpty ? ' (filtrado)' : ''}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            spacing: 12,
            children: [
              Badge.count(
                count: _appliedFilters.activeFiltersCount,
                isLabelVisible: _appliedFilters.activeFiltersCount > 0,
                child: IconButton.filledTonal(
                  onPressed: _toggleFilters,
                  icon: Icon(
                    _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
                  ),
                  tooltip: _showFilters ? 'Ocultar filtros' : 'Mostrar filtros',
                ),
              ),
              OutlinedButton.icon(
                onPressed: _showAddEmployeeDrawer,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Funcionário'),
                style: OutlinedButton.styleFrom(
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

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum funcionário encontrado',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            !_appliedFilters.isEmpty
                ? 'Tente ajustar os filtros'
                : 'Adicione um novo funcionário para começar',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (!_appliedFilters.isEmpty) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear_all),
              label: const Text('Limpar Filtros'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Falha na Conexão',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _reloadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
