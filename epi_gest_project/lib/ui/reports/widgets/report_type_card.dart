import 'package:epi_gest_project/domain/models/report/report_type.dart';
import 'package:flutter/material.dart';

class ReportTypeCard extends StatelessWidget {
  final ReportType reportType;
  final bool isSelected;
  final VoidCallback onTap;

  const ReportTypeCard({
    super.key,
    required this.reportType,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getIconForReportType(ReportType type) {
    switch (type) {
      case ReportType.epiInventory:
        return Icons.inventory_2_outlined;
      case ReportType.epiExpiring:
        return Icons.warning_amber_outlined;
      case ReportType.employeeEpis:
        return Icons.person_outline;
      case ReportType.employeeList:
        return Icons.people_outline;
      case ReportType.epiExchangeHistory:
        return Icons.swap_horiz_outlined;
      case ReportType.costAnalysis:
        return Icons.attach_money_outlined;
      case ReportType.caValidation:
        return Icons.verified_outlined;
      case ReportType.complianceReport:
        return Icons.fact_check_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 2 : 0,
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForReportType(reportType),
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reportType.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reportType.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
