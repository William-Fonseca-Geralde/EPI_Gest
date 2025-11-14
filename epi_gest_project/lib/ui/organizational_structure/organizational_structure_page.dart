import 'package:epi_gest_project/ui/organizational_structure/widgets/organizational_type_card.dart';
import 'package:flutter/material.dart';
import 'widgets/units/units_widget.dart';
import 'widgets/epi_maping/epi_maping_widget.dart';
import 'widgets/department/departments_widget.dart';
import 'widgets/roles/roles_widget.dart';
import 'widgets/employment_type/employment_types_widget.dart';
import 'widgets/shifts/shifts_widget.dart';
import 'widgets/risks/risks_widget.dart';

class OrganizationalStructurePage extends StatefulWidget {
  const OrganizationalStructurePage({super.key});

  @override
  State<OrganizationalStructurePage> createState() =>
      _OrganizationalStructurePageState();
}

class _OrganizationalStructurePageState
    extends State<OrganizationalStructurePage> {
  int? _selectedSection;

  // Keys para controlar cada widget
  final GlobalKey<UnitsWidgetState> _unitsKey = GlobalKey();
  final GlobalKey<DepartmentsWidgetState> _departmentsKey = GlobalKey();
  final GlobalKey<RolesWidgetState> _rolesKey = GlobalKey();
  final GlobalKey<EmploymentTypesWidgetState> _employmentTypesKey = GlobalKey();
  final GlobalKey<ShiftsWidgetState> _shiftsKey = GlobalKey();
  final GlobalKey<RisksWidgetState> _risksKey = GlobalKey();
  final GlobalKey<EpiMapingWidgetState> _epiMapingKey = GlobalKey();

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
      'title': 'Riscos Ocupacionais',
      'icon': Icons.warning_amber_outlined,
      'description': 'Classifique riscos por atividade',
      'index': 3,
    },
    {
      'title': 'Mapeamento de EPIs',
      'icon': Icons.assignment_turned_in_outlined,
      'description': 'Vincule EPIs a cargos, setores e riscos',
      'index': 4,
    },
    {
      'title': 'Tipos de Vínculo',
      'icon': Icons.assignment_ind_outlined,
      'description': 'Tipos de contratação e vínculos',
      'index': 5,
    },
    {
      'title': 'Turnos de Trabalho',
      'icon': Icons.access_time_outlined,
      'description': 'Configure jornadas e horários',
      'index': 6,
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
        return RisksWidget(key: _risksKey);
      case 4:
        return EpiMapingWidget(key: _epiMapingKey);
      case 5:
        return EmploymentTypesWidget(key: _employmentTypesKey);
      case 6:
        return ShiftsWidget(key: _shiftsKey);
      default:
        return const Center(child: Text('Seção não encontrada'));
    }
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
        return 'Novo Risco';
      case 4:
        return 'Novo Mapeamento';
      case 5:
        return 'Novo Vínculo';
      case 6:
        return 'Novo Turno';
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
        _risksKey.currentState?.showAddDrawer();
        break;
      case 4:
        _epiMapingKey.currentState?.showAddDrawer();
        break;
      case 5:
        _employmentTypesKey.currentState?.showAddDrawer();
      case 6:
        _shiftsKey.currentState?.showAddDrawer();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(flex: 2, child: _buildSelectionPanel()),
          const VerticalDivider(width: 1),
          Expanded(flex: 3, child: _buildConfigurationPanel()),
        ],
      ),
    );
  }

  Widget _buildSelectionPanel() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12)),
          ),
          child: Row(
            spacing: 16,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_tree,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 40,
                ),
              ),
              Column(
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estrutura Organizacional',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      height: 1.1,
                    ),
                  ),
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
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            itemCount: _sections.length,
            itemBuilder: (context, index) {
              final section = _sections[index];
              final isSelected = _selectedSection == index;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OrganizationalTypeCard(
                  icon: section['icon'],
                  title: section['title'],
                  description: section['description'],
                  isSelected: isSelected,
                  onTap: () => _onSectionSelected(index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConfigurationPanel() {
    if (_selectedSection == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_tree_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Selecione um tipo de Seção',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha uma seção no painel lateral para começar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  spacing: 16,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        _sections[_selectedSection!]['icon'],
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 40,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        spacing: 4,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _sections[_selectedSection!]['title'],
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.8,
                                  height: 1.1,
                                ),
                          ),
                          Text(
                            _sections[_selectedSection!]['description'],
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  _triggerAddAction(_selectedSection!);
                },
                icon: const Icon(Icons.add),
                label: Text(_getAddButtonText(_selectedSection!)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _getSectionWidget(_selectedSection!),
          ),
        ),
      ],
    );
  }
}
