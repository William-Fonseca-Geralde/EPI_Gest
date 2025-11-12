import 'package:flutter/material.dart';
import 'widgets/units_widget.dart';
import 'widgets/departments_widget.dart';
import 'widgets/roles_widget.dart';
import 'widgets/employment_types_widget.dart';
import 'widgets/shifts_widget.dart';
import 'widgets/risks_widget.dart';

class OrganizationalStructurePage extends StatefulWidget {
  const OrganizationalStructurePage({super.key});

  @override
  State<OrganizationalStructurePage> createState() => _OrganizationalStructurePageState();
}

class _OrganizationalStructurePageState extends State<OrganizationalStructurePage> {
  int _selectedSection = 0;

  // Keys para controlar cada widget
  final GlobalKey<UnitsWidgetState> _unitsKey = GlobalKey();
  final GlobalKey<DepartmentsWidgetState> _departmentsKey = GlobalKey();
  final GlobalKey<RolesWidgetState> _rolesKey = GlobalKey();
  final GlobalKey<EmploymentTypesWidgetState> _employmentTypesKey = GlobalKey();
  final GlobalKey<ShiftsWidgetState> _shiftsKey = GlobalKey();
  final GlobalKey<RisksWidgetState> _risksKey = GlobalKey();

  final List<Map<String, dynamic>> _sections = [
    {
      'title': 'Unidades (Matriz / Filial)',
      'icon': Icons.business_outlined,
      'description': 'Gerencie matriz e filiais da empresa',
      'index': 0,
    },
    {
      'title': 'Setores / Departamentos',
      'icon': Icons.work_outline,
      'description': 'Configure departamentos e áreas',
      'index': 1,
    },
    {
      'title': 'Cargos / Funções',
      'icon': Icons.badge_outlined,
      'description': 'Defina cargos e responsabilidades',
      'index': 2,
    },
    {
      'title': 'Tipos de Vínculo',
      'icon': Icons.assignment_ind_outlined,
      'description': 'Tipos de contratação e vínculos',
      'index': 3,
    },
    {
      'title': 'Turnos de Trabalho',
      'icon': Icons.access_time_outlined,
      'description': 'Configure jornadas e horários',
      'index': 4,
    },
    {
      'title': 'Riscos Ocupacionais',
      'icon': Icons.warning_amber_outlined,
      'description': 'Classifique riscos por atividade',
      'index': 5,
    },
  ];

  void _onSectionSelected(int index) {
    setState(() {
      _selectedSection = index;
    });
  }

  Widget _getSectionWidget(int index) {
    switch (index) {
      case 0:
        return UnitsWidget(key: _unitsKey);
      case 1:
        return DepartmentsWidget(key: _departmentsKey);
      case 2:
        return RolesWidget(key: _rolesKey);
      case 3:
        return EmploymentTypesWidget(key: _employmentTypesKey);
      case 4:
        return ShiftsWidget(key: _shiftsKey);
      case 5:
        return RisksWidget(key: _risksKey);
      default:
        return const Center(child: Text('Seção não encontrada'));
    }
  }

  String _getSectionTitle(int index) {
    return _sections[index]['title'];
  }

  IconData _getSectionIcon(int index) {
    return _sections[index]['icon'];
  }

  String _getAddButtonText(int sectionIndex) {
    switch (sectionIndex) {
      case 0:
        return 'Nova Unidade';
      case 1:
        return 'Novo Departamento';
      case 2:
        return 'Novo Cargo';
      case 3:
        return 'Novo Vínculo';
      case 4:
        return 'Novo Turno';
      case 5:
        return 'Novo Risco';
      default:
        return 'Adicionar';
    }
  }

  void _triggerAddAction(int sectionIndex) {
    switch (sectionIndex) {
      case 0:
        _unitsKey.currentState?.showAddDrawer();
        break;
      case 1:
        _departmentsKey.currentState?.showAddDrawer();
        break;
      case 2:
        _rolesKey.currentState?.showAddDrawer();
        break;
      case 3:
        _employmentTypesKey.currentState?.showAddDrawer();
        break;
      case 4:
        _shiftsKey.currentState?.showAddDrawer();
        break;
      case 5:
        _risksKey.currentState?.showAddDrawer();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSidebar(context),
                  const SizedBox(width: 16),
                  _buildMainContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
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
                  _getSectionIcon(_selectedSection),
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 40,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getSectionTitle(_selectedSection),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_sections.length} seções de gestão',
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
              FilledButton.icon(
                onPressed: () {
                  _triggerAddAction(_selectedSection);
                },
                icon: const Icon(Icons.add),
                label: Text(_getAddButtonText(_selectedSection)),
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

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 300,
      child: Card(
        child: ListView.separated(
          itemCount: _sections.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final section = _sections[index];
            return ListTile(
              leading: Icon(section['icon']),
              title: Text(
                section['title'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: _selectedSection == index 
                      ? FontWeight.w600 
                      : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                section['description'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              selected: _selectedSection == index,
              selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              onTap: () => _onSectionSelected(index),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _getSectionWidget(_selectedSection),
        ),
      ),
    );
  }
}