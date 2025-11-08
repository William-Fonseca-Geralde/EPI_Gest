import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/data/services/employee_service.dart';
import 'package:epi_gest_project/domain/models/employee/employee_model.dart';
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

  // MODIFICADO: Gerenciamento de estado com dados reais do Appwrite
  late Future<void> _loadEmployeesFuture;
  List<Employee> _allEmployees = [];
  List<Employee> _filteredEmployees = [];
  Map<String, dynamic> _appliedFilters = {
  };

  // MODIFICADO: Estas listas podem ser preenchidas dinamicamente no futuro
  final List<String> _setores = [
    'Produção',
    'Qualidade',
    'Manutenção',
    'Logística',
    'Administrativo',
    'Recursos Humanos',
    'Financeiro',
    'Comercial',
  ];
  final List<String> _funcoes = [
    'Operador de Máquinas',
    'Inspetor de Qualidade',
    'Técnico de Manutenção',
    'Auxiliar de Produção',
    'Supervisor',
    'Gerente',
    'Analista',
    'Assistente Administrativo',
  ];

  @override
  void initState() {
    super.initState();
    // MODIFICADO: Inicia o carregamento dos dados do Appwrite
    _loadEmployeesFuture = _loadEmployees();
  }

  // ADICIONADO: Método para buscar dados do Appwrite
  Future<void> _loadEmployees({bool showLoading = false}) async {
    // Se showLoading for true, criamos um novo Future para o FutureBuilder mostrar o spinner
    if (showLoading || mounted) {
      setState(() {
        _loadEmployeesFuture = _internalLoad();
      });
    } else {
      // Carregamento inicial ou silencioso
      await _internalLoad();
    }
  }

  Future<void> _internalLoad() async {
    try {
      final employeeService = Provider.of<EmployeeService>(
        context,
        listen: false,
      );
      final employees = await employeeService.getActiveEmployees();
      if (mounted) {
        setState(() {
          _allEmployees = employees;
          _applyFilters(_appliedFilters, updateState: false);
        });
      }
    } on AppwriteException catch (e) {
      throw Exception('Falha ao carregar funcionários: $e');
    }
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  void _applyFilters(Map<String, dynamic> filters, {bool updateState = true}) {
    void apply() {
      _appliedFilters = filters;
      _filteredEmployees = _allEmployees.where((employee) {
        if (filters['nome'] != null &&
            (filters['nome'] as String).isNotEmpty &&
            !employee.nome.toLowerCase().contains(
              (filters['nome'] as String).toLowerCase(),
            )) {
          return false;
        }
        if (filters['matricula'] != null &&
            (filters['matricula'] as String).isNotEmpty &&
            !employee.matricula.toLowerCase().contains(
              (filters['matricula'] as String).toLowerCase(),
            )) {
          return false;
        }
        if (filters['setores'] != null &&
            (filters['setores'] as List).isNotEmpty &&
            !(filters['setores'] as List).contains(employee.setor)) {
          return false;
        }
        if (filters['funcoes'] != null &&
            (filters['funcoes'] as List).isNotEmpty &&
            !(filters['funcoes'] as List).contains(employee.cargo)) {
          return false;
        }
        if (filters['dataEntrada'] != null) {
          final filterDate = filters['dataEntrada'] as DateTime;
          final employeeDate = employee.dataEntrada;
          if (employeeDate.year != filterDate.year ||
              employeeDate.month != filterDate.month ||
              employeeDate.day != filterDate.day) {
            return false;
          }
        }
        return true;
      }).toList();
    }

    if (updateState) {
      setState(apply);
    } else {
      apply();
    }
  }

  void _clearFilters() {
    setState(() {
      _appliedFilters = {};
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
          _loadEmployees(showLoading: true);
        },
      ),
    );
  }

  void _showEditEmployeeDrawer(Employee employee) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Editar Funcionário',
      pageBuilder: (context, _, __) => EmployeeDrawer(
        employeeToEdit: employee,
        onClose: () => Navigator.of(context).pop(),
        onSave: () {
          _loadEmployees(showLoading: true);
        },
      ),
    );
  }

  void _showViewEmployeeDrawer(Employee employee) {
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

  void _inactivateEmployee(Employee employee) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Inativação'),
        content: Text('Tem certeza que deseja inativar ${employee.nome}?'),
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
      ),
    );

    if (confirm == true || mounted) {
      final employeeService = Provider.of<EmployeeService>(
        context,
        listen: false,
      );
      try {
        await employeeService.inactivateEmployee(employee.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Funcionário inativado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadEmployees(showLoading: true);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(theme),
          if (_showFilters)
            EmployeesFilters(
              appliedFilters: _appliedFilters,
              setores: _setores,
              funcoes: _funcoes,
              onApplyFilters: (filters) => _applyFilters(filters),
              onClearFilters: _clearFilters,
            ),
          Expanded(
            // MODIFICADO: Usa FutureBuilder para lidar com o carregamento inicial
            child: FutureBuilder(
              future: _loadEmployeesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro ao carregar dados: ${snapshot.error}'),
                  );
                }
                if (_filteredEmployees.isEmpty) {
                  return _buildEmptyState(theme);
                }
                // MODIFICADO: Passa as funções de ação para o DataTable
                return EmployeesDataTable(
                  employees: _filteredEmployees,
                  onView: _showViewEmployeeDrawer,
                  onEdit: _showEditEmployeeDrawer,
                  onInactivate: _inactivateEmployee,
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
            colorScheme.primary.withOpacity(0.08),
            colorScheme.surface.withOpacity(0.6),
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
              const SizedBox(width: 16),
              Column(
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
                  const SizedBox(height: 4),
                  Text(
                    '${_filteredEmployees.length} de ${_allEmployees.length} ${_allEmployees.length == 1 ? 'funcionário' : 'funcionários'}${_appliedFilters.isNotEmpty ? ' (filtrado)' : ''}',
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
            children: [
              IconButton.filledTonal(
                onPressed: _toggleFilters,
                icon: Icon(
                  _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
                ),
                tooltip: _showFilters ? 'Ocultar filtros' : 'Mostrar filtros',
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _showAddEmployeeDrawer,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Funcionário'),
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
            _appliedFilters.isNotEmpty
                ? 'Tente ajustar os filtros'
                : 'Adicione um novo funcionário para começar',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (_appliedFilters.isNotEmpty) ...[
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
}
