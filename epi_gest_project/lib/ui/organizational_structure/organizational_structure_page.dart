import 'package:flutter/material.dart';

class OrganizationalStructurePage extends StatefulWidget {
  const OrganizationalStructurePage({super.key});

  @override
  State<OrganizationalStructurePage> createState() => _OrganizationalStructurePageState();
}

class _OrganizationalStructurePageState extends State<OrganizationalStructurePage> {
  int _selectedSection = 0;

  // Lista das seções da estrutura organizacional
  final List<Map<String, dynamic>> _sections = [
    {
      'title': 'Unidades (Matriz / Filial)',
      'icon': Icons.business_outlined,
      'description': 'Gerencie matriz e filiais da empresa',
    },
    {
      'title': 'Setores / Departamentos',
      'icon': Icons.work_outline,
      'description': 'Configure departamentos e áreas',
    },
    {
      'title': 'Cargos / Funções',
      'icon': Icons.badge_outlined,
      'description': 'Defina cargos e responsabilidades',
    },
    {
      'title': 'Tipos de Vínculo',
      'icon': Icons.assignment_ind_outlined,
      'description': 'Tipos de contratação e vínculos',
    },
    {
      'title': 'Turnos de Trabalho',
      'icon': Icons.access_time_outlined,
      'description': 'Configure jornadas e horários',
    },
    {
      'title': 'Riscos Ocupacionais',
      'icon': Icons.warning_amber_outlined,
      'description': 'Classifique riscos por atividade',
    },
  ];

  void _onSectionSelected(int index) {
    setState(() {
      _selectedSection = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menu lateral com as opções
            Container(
              width: 300,
              child: Card(
                child: ListView.builder(
                  itemCount: _sections.length,
                  itemBuilder: (context, index) {
                    final section = _sections[index];
                    return ListTile(
                      leading: Icon(section['icon']),
                      title: Text(section['title']),
                      subtitle: Text(
                        section['description'],
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      selected: _selectedSection == index,
                      onTap: () => _onSectionSelected(index),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Conteúdo da seção selecionada
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildSectionContent(_selectedSection),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContent(int sectionIndex) {
    switch (sectionIndex) {
      case 0: // Unidades
        return _buildUnitsContent();
      case 1: // Setores
        return _buildDepartmentsContent();
      case 2: // Cargos
        return _buildRolesContent();
      case 3: // Vínculos
        return _buildEmploymentTypesContent();
      case 4: // Turnos
        return _buildShiftsContent();
      case 5: // Riscos
        return _buildRisksContent();
      default:
        return const Center(child: Text('Selecione uma opção'));
    }
  }

  Widget _buildUnitsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unidades (Matriz / Filial)',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Text(
          'Gerencie as unidades da empresa:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        const Text('• Matriz - Unidade principal'),
        const Text('• Filiais - Unidades secundárias'),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implementar cadastro de unidades
          },
          icon: const Icon(Icons.add),
          label: const Text('Nova Unidade'),
        ),
      ],
    );
  }

  Widget _buildDepartmentsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Setores / Departamentos',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Text(
          'Configure os departamentos da empresa:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        const Text('• Produção'),
        const Text('• Administrativo'),
        const Text('• RH'),
        const Text('• Segurança do Trabalho'),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implementar cadastro de departamentos
          },
          icon: const Icon(Icons.add),
          label: const Text('Novo Departamento'),
        ),
      ],
    );
  }

  Widget _buildRolesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cargos / Funções',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Text(
          'Defina os cargos e funções dos colaboradores:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        const Text('• Operador de Máquinas'),
        const Text('• Auxiliar de Produção'),
        const Text('• Supervisor'),
        const Text('• Gerente'),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implementar cadastro de cargos
          },
          icon: const Icon(Icons.add),
          label: const Text('Novo Cargo'),
        ),
      ],
    );
  }

  Widget _buildEmploymentTypesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipos de Vínculo',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Text(
          'Configure os tipos de vínculo empregatício:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        const Text('• CLT'),
        const Text('• PJ'),
        const Text('• Estagiário'),
        const Text('• Temporário'),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implementar cadastro de tipos de vínculo
          },
          icon: const Icon(Icons.add),
          label: const Text('Novo Tipo de Vínculo'),
        ),
      ],
    );
  }

  Widget _buildShiftsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Turnos de Trabalho',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Text(
          'Configure os turnos e jornadas de trabalho:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        const Text('• Manhã - 06:00 às 14:00'),
        const Text('• Tarde - 14:00 às 22:00'),
        const Text('• Noite - 22:00 às 06:00'),
        const Text('• Administrativo - 08:00 às 17:00'),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implementar cadastro de turnos
          },
          icon: const Icon(Icons.add),
          label: const Text('Novo Turno'),
        ),
      ],
    );
  }

  Widget _buildRisksContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riscos Ocupacionais',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Text(
          'Classifique os riscos ocupacionais por atividade:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        const Text('• Físicos - Ruído, calor, vibração'),
        const Text('• Químicos - Poeira, fumos, vapores'),
        const Text('• Biológicos - Bactérias, vírus, fungos'),
        const Text('• Ergonômicos - Postura, repetição'),
        const Text('• Acidentes - Quedas, choques, incêndios'),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implementar cadastro de riscos
          },
          icon: const Icon(Icons.add),
          label: const Text('Novo Risco'),
        ),
      ],
    );
  }
}