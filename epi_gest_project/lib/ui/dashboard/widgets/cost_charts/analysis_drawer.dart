import 'package:flutter/material.dart';
import 'package:epi_gest_project/ui/widgets/base_drawer.dart';

class AnalysisDrawer extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  final VoidCallback? onExportPdf;
  final VoidCallback? onExportExcel;

  const AnalysisDrawer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.onExportPdf,
    this.onExportExcel,
  });

  @override
  State<AnalysisDrawer> createState() => _AnalysisDrawerState();
}

class _AnalysisDrawerState extends State<AnalysisDrawer> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BaseDrawer(
      widthFactor: MediaQuery.of(context).size.width > 1200 ? 0.5 : 0.85,
      onClose: () => Navigator.of(context).pop(),

      header: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.primary, cs.tertiary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics_rounded,
                color: cs.onPrimary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.close_rounded, color: cs.onPrimary),
              tooltip: 'Fechar Análise',
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.children,
        ),
      ),

      footer: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outlineVariant)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            if (widget.onExportExcel != null)
              OutlinedButton.icon(
                onPressed: widget.onExportExcel,
                icon: const Icon(Icons.table_view_rounded),
                label: const Text('Excel'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            if (widget.onExportPdf != null)
              FilledButton.icon(
                onPressed: widget.onExportPdf,
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('Relatório PDF'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
