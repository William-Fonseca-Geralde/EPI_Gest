import 'package:epi_gest_project/ui/employees/widget/add_employee_drawer.dart';
import 'package:epi_gest_project/ui/employees/widget/employees_data_table.dart';
import 'package:epi_gest_project/ui/employees/widget/employees_filters.dart';
import 'package:flutter/material.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  bool _showFilters = false;

  // Dados temporários
  final List<Map<String, dynamic>> _allEmployees = [
    {
      'id': '001',
      'nome': 'João Silva',
      'setor': 'Produção',
      'funcao': 'Operador de Máquinas',
      'imagem': null,
      'dataEntrada': DateTime(2022, 3, 15),
    },
    {
      'id': '002',
      'nome': 'Maria Santos',
      'setor': 'Qualidade',
      'funcao': 'Inspetora de Qualidade',
      'imagem': null,
      'dataEntrada': DateTime(2023, 7, 20),
    },
    {
      'id': '003',
      'nome': 'Pedro Oliveira',
      'setor': 'Manutenção',
      'funcao': 'Técnico de Manutenção',
      'imagem': null,
      'dataEntrada': DateTime(2021, 1, 10),
    },
    {
      'id': '004',
      'nome': 'Ana Costa',
      'setor': 'Administrativo',
      'funcao': 'Assistente Administrativo',
      'imagem': null,
      'dataEntrada': DateTime(2024, 2, 5),
    },
  ];

  List<Map<String, dynamic>> _filteredEmployees = [];
  Map<String, dynamic> _appliedFilters = {};

  // Listas para os filtros
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
    _filteredEmployees = List.from(_allEmployees);
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters; // <-- Inverte o estado
    });
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      _appliedFilters = filters;
      _filteredEmployees = _allEmployees.where((employee) {
        // Filtro de nome
        if (filters['nome'] != null && filters['nome'].isNotEmpty) {
          if (!employee['nome'].toLowerCase().contains(
            filters['nome'].toLowerCase(),
          )) {
            return false;
          }
        }

        // Filtro de ID
        if (filters['id'] != null && filters['id'].isNotEmpty) {
          if (!employee['id'].toLowerCase().contains(
            filters['id'].toLowerCase(),
          )) {
            return false;
          }
        }

        // Filtro de setores
        if (filters['setores'] != null &&
            (filters['setores'] as List).isNotEmpty) {
          if (!(filters['setores'] as List).contains(employee['setor'])) {
            return false;
          }
        }

        // Filtro de data de entrada
        if (filters['dataEntrada'] != null) {
          final filterDate = filters['dataEntrada'] as DateTime;
          final employeeDate = employee['dataEntrada'] as DateTime?;
          if (employeeDate == null ||
              employeeDate.year != filterDate.year ||
              employeeDate.month != filterDate.month ||
              employeeDate.day != filterDate.day) {
            return false;
          }
        }

        // Filtro de funções
        if (filters['funcoes'] != null &&
            (filters['funcoes'] as List).isNotEmpty) {
          if (!(filters['funcoes'] as List).contains(employee['funcao'])) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _appliedFilters = {};
      _filteredEmployees = List.from(_allEmployees);
    });
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
              onApplyFilters: _applyFilters,
              onClearFilters: _clearFilters,
            ),

          Expanded(
            child: _filteredEmployees.isEmpty
                ? _buildEmptyState(theme)
                : EmployeesDataTable(employees: _filteredEmployees),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Funcionários',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_filteredEmployees.length} ${_filteredEmployees.length == 1 ? 'funcionário' : 'funcionários'}${_appliedFilters.isNotEmpty ? ' (filtrado)' : ''}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Botões de Ação
          Row(
            children: [
              // Botão Toggle Filtros
              IconButton.filledTonal(
                onPressed: _toggleFilters, // <-- Ação de ocultar/mostrar
                icon: Icon(
                  _showFilters
                      ? Icons
                            .filter_alt_off // Ícone quando filtros visíveis
                      : Icons.filter_alt, // Ícone quando filtros ocultos
                ),
                tooltip: _showFilters
                    ? 'Ocultar filtros' // Tooltip quando filtros visíveis
                    : 'Mostrar filtros', // Tooltip quando filtros ocultos
              ),
              const SizedBox(width: 12),

              // Botão Adicionar Funcionário
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
            'Tente ajustar os filtros',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.clear_all),
            label: const Text('Limpar Filtros'),
          ),
        ],
      ),
    );
  }

  void _showAddEmployeeDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Adicionar Funcionário',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AddEmployeeDrawer(
          onClose: () => Navigator.of(context).pop(),
          onSave: (newEmployee) {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
