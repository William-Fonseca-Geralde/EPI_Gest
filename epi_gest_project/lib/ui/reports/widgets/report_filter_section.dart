import 'package:epi_gest_project/domain/models/report/report_type.dart';
import 'package:flutter/material.dart';

class ReportFilterSection extends StatelessWidget {
  final ReportType reportType;
  final ReportFilter filter;
  final ValueChanged<ReportFilter> onFilterChanged;

  const ReportFilterSection({
    super.key,
    required this.reportType,
    required this.filter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Período
            _buildDateRangeFilter(context),
            
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            
            // Filtros específicos por tipo de relatório
            ..._buildSpecificFilters(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Período',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DatePickerField(
                label: 'Data Inicial',
                date: filter.startDate,
                onDateSelected: (date) {
                  onFilterChanged(filter.copyWith(startDate: date));
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _DatePickerField(
                label: 'Data Final',
                date: filter.endDate,
                onDateSelected: (date) {
                  onFilterChanged(filter.copyWith(endDate: date));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildSpecificFilters(BuildContext context) {
    final filters = <Widget>[];

    // Adiciona filtros específicos baseado no tipo de relatório
    switch (reportType) {
      case ReportType.epiInventory:
      case ReportType.epiExpiring:
        filters.add(_buildCategoryFilter(context));
        break;
      case ReportType.employeeEpis:
      case ReportType.employeeList:
        filters.add(_buildDepartmentFilter(context));
        break;
      case ReportType.costAnalysis:
        filters.addAll([
          _buildDepartmentFilter(context),
          const SizedBox(height: 20),
          _buildCategoryFilter(context),
        ]);
        break;
      default:
        break;
    }

    // Opção de incluir inativos
    if (filters.isNotEmpty) {
      filters.add(const SizedBox(height: 20));
      filters.add(const Divider());
      filters.add(const SizedBox(height: 20));
    }
    
    filters.add(_buildIncludeInactiveFilter(context));

    return filters;
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categorias de EPI',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('Proteção Respiratória'),
              selected: false,
              onSelected: (selected) {},
            ),
            FilterChip(
              label: const Text('Proteção para Cabeça'),
              selected: false,
              onSelected: (selected) {},
            ),
            FilterChip(
              label: const Text('Proteção para Mãos'),
              selected: false,
              onSelected: (selected) {},
            ),
            FilterChip(
              label: const Text('Proteção para Pés'),
              selected: false,
              onSelected: (selected) {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDepartmentFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Departamento',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Selecione um departamento',
          ),
          items: const [
            DropdownMenuItem(value: 'all', child: Text('Todos')),
            DropdownMenuItem(value: 'prod', child: Text('Produção')),
            DropdownMenuItem(value: 'man', child: Text('Manutenção')),
            DropdownMenuItem(value: 'log', child: Text('Logística')),
          ],
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildIncludeInactiveFilter(BuildContext context) {
    return CheckboxListTile(
      value: filter.includeInactive ?? false,
      onChanged: (value) {
        onFilterChanged(filter.copyWith(includeInactive: value));
      },
      title: const Text('Incluir registros inativos'),
      subtitle: const Text('Exibir EPIs e funcionários desativados'),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final ValueChanged<DateTime?> onDateSelected;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        onDateSelected(selectedDate);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          date != null
              ? '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}'
              : 'Selecione uma data',
          style: date != null
              ? null
              : TextStyle(color: Theme.of(context).hintColor),
        ),
      ),
    );
  }
}
