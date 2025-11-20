import 'package:epi_gest_project/ui/widgets/base_drawer.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SectorDetailsDrawer extends StatefulWidget {
  final Map<String, dynamic> sector;
  final Function(String) getSectorDetails;
  final Function(String) getSectorConformity;
  final Function(String) getSectorEmployees;
  final Function(String) getSectorEpis;
  final Function(double) getConformityColor;
  final Function(double) getConformityStatus;

  const SectorDetailsDrawer({
    super.key,
    required this.sector,
    required this.getSectorDetails,
    required this.getSectorConformity,
    required this.getSectorEmployees,
    required this.getSectorEpis,
    required this.getConformityColor,
    required this.getConformityStatus,
  });

  @override
  State<SectorDetailsDrawer> createState() => _SectorDetailsDrawerState();
}

class _SectorDetailsDrawerState extends State<SectorDetailsDrawer> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final conformity = widget.sector['conformidade'] as double;
    final gradient = widget.sector['gradient'] as List<Color>;
    final sectorDetails = widget.getSectorDetails(
      widget.sector['setor'] as String,
    );
    final employees = widget.getSectorEmployees(
      widget.sector['setor'] as String,
    );
    final epis = widget.getSectorEpis(widget.sector['setor'] as String);

    return BaseDrawer(
      widthFactor: 0.5,
      onClose: () => Navigator.of(context).pop(),
      header: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.sector['icon'] as IconData,
                size: 24,
                color: gradient[0],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.sector['setor'] as String,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${conformity.toStringAsFixed(1)}% de conformidade',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: cs.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close_rounded, color: cs.onPrimary),
            ),
          ],
        ),
      ),
      body: Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gráfico do Setor
              _buildSectorModalGauge(theme, cs, conformity, gradient),
              const SizedBox(height: 32),

              // Estatísticas Rápidas
              _buildModalStats(
                theme,
                cs,
                sectorDetails,
                widget.sector['setor'] as String,
              ),
              const SizedBox(height: 32),

              // Lista de Colaboradores
              _buildEmployeesSection(theme, cs, employees),
              const SizedBox(height: 32),

              // EPIs do Setor
              _buildEpisSection(theme, cs, epis),
            ],
          ),
        ),
      ),
      footer: Row(),
    );
  }

  Widget _buildSectorModalGauge(
    ThemeData theme,
    ColorScheme cs,
    double conformity,
    List<Color> gradient,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Conformidade do Setor',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 100,
                  showLabels: false,
                  showTicks: false,
                  startAngle: 140,
                  endAngle: 40,
                  axisLineStyle: const AxisLineStyle(
                    thickness: 0.08,
                    color: Colors.transparent,
                  ),
                  pointers: <GaugePointer>[
                    RangePointer(
                      value: 100,
                      width: 0.20,
                      cornerStyle: CornerStyle.bothCurve,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.1),
                    ),
                    RangePointer(
                      value: conformity,
                      width: 0.18,
                      cornerStyle: CornerStyle.bothCurve,
                      gradient: SweepGradient(colors: gradient),
                    ),
                    MarkerPointer(
                      value: conformity,
                      markerHeight: 20,
                      markerWidth: 20,
                      markerType: MarkerType.circle,
                      color: cs.surface,
                      borderWidth: 4,
                      borderColor: widget.getConformityColor(conformity),
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      positionFactor: 0.1,
                      angle: 90,
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${conformity.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: widget.getConformityColor(conformity),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: widget
                                  .getConformityColor(conformity)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.getConformityStatus(conformity),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: widget.getConformityColor(conformity),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalStats(
    ThemeData theme,
    ColorScheme cs,
    Map<String, dynamic> details,
    String setor,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _buildModalStatCard(
          theme,
          cs,
          'Colaboradores',
          '${details['funcionarios']}',
          Icons.people_rounded,
          Colors.blue,
        ),
        _buildModalStatCard(
          theme,
          cs,
          'EPIs Ativos',
          '${details['epis']}',
          Icons.security_rounded,
          Colors.green,
        ),
        _buildModalStatCard(
          theme,
          cs,
          'Conformidade',
          '${widget.getSectorConformity(setor).toStringAsFixed(1)}%',
          Icons.verified_rounded,
          widget.getConformityColor(widget.getSectorConformity(setor)),
        ),
        _buildModalStatCard(
          theme,
          cs,
          'EPIs por Pessoa',
          '${(details['epis'] / details['funcionarios']).toStringAsFixed(1)}',
          Icons.assignment_rounded,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildModalStatCard(
    ThemeData theme,
    ColorScheme cs,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeesSection(
    ThemeData theme,
    ColorScheme cs,
    List<Map<String, dynamic>> employees,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Colaboradores',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${employees.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...employees
            .map((employee) => _buildEmployeeCard(theme, cs, employee))
            .toList(),
      ],
    );
  }

  Widget _buildEmployeeCard(
    ThemeData theme,
    ColorScheme cs,
    Map<String, dynamic> employee,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  (employee['conformidade'] >= 90
                          ? Colors.green
                          : employee['conformidade'] >= 70
                          ? Colors.orange
                          : Colors.red)
                      .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              employee['conformidade'] >= 90
                  ? Icons.verified_rounded
                  : employee['conformidade'] >= 70
                  ? Icons.check_circle_rounded
                  : Icons.warning_rounded,
              size: 20,
              color: employee['conformidade'] >= 90
                  ? Colors.green
                  : employee['conformidade'] >= 70
                  ? Colors.orange
                  : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee['nome'],
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  employee['cargo'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget
                  .getConformityColor(employee['conformidade'])
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${employee['conformidade'].toStringAsFixed(0)}%',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: widget.getConformityColor(employee['conformidade']),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisSection(
    ThemeData theme,
    ColorScheme cs,
    List<Map<String, dynamic>> epis,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'EPIs do Setor',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${epis.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: epis.map((epi) => _buildEpiChip(theme, cs, epi)).toList(),
        ),
      ],
    );
  }

  Widget _buildEpiChip(
    ThemeData theme,
    ColorScheme cs,
    Map<String, dynamic> epi,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            epi['obrigatorio'] ? Icons.security_rounded : Icons.help_rounded,
            size: 16,
            color: epi['obrigatorio'] ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
          Text(
            epi['nome'],
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
