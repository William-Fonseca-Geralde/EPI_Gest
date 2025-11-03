import 'package:epi_gest_project/domain/models/report/report_type.dart';
import 'package:flutter/material.dart';

class ReportFormatSelector extends StatelessWidget {
  final ReportFormat selectedFormat;
  final ValueChanged<ReportFormat> onFormatChanged;

  const ReportFormatSelector({
    super.key,
    required this.selectedFormat,
    required this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ReportFormat.values.map((format) {
        final isSelected = selectedFormat == format;
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _FormatCard(
              format: format,
              isSelected: isSelected,
              onTap: () => onFormatChanged(format),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FormatCard extends StatelessWidget {
  final ReportFormat format;
  final bool isSelected;
  final VoidCallback onTap;

  const _FormatCard({
    required this.format,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getIconForFormat(ReportFormat format) {
    switch (format) {
      case ReportFormat.pdf:
        return Icons.picture_as_pdf_outlined;
      case ReportFormat.excel:
        return Icons.table_chart_outlined;
      case ReportFormat.csv:
        return Icons.text_snippet_outlined;
    }
  }

  Color _getColorForFormat(BuildContext context, ReportFormat format) {
    switch (format) {
      case ReportFormat.pdf:
        return Colors.red;
      case ReportFormat.excel:
        return Colors.green;
      case ReportFormat.csv:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForFormat(context, format);
    
    return Card(
      elevation: 0,
      color: isSelected ? color.withValues(alpha: 0.1) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Icon(
                _getIconForFormat(format),
                size: 40,
                color: isSelected ? color : Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(height: 12),
              Text(
                format.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? color : null,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                format.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
