import 'package:epi_gest_project/ui/dashboard/widgets/conformity_selector/sector_details_drawer.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class ConformitySelectorChart extends StatefulWidget {
  const ConformitySelectorChart({super.key});

  @override
  State<ConformitySelectorChart> createState() =>
      _ConformitySelectorChartState();
}

class _ConformitySelectorChartState extends State<ConformitySelectorChart>
    with SingleTickerProviderStateMixin {
  String _selectedView = 'Geral';
  final double _conformidadeGeral = 78.5;
  bool _animStarted = false;

  // Dados otimizados com cores mais modernas
  final List<Map<String, dynamic>> _sectorConformity = [
    {
      'setor': 'Qualidade',
      'conformidade': 92.5,
      'cor': Color(0xFF10B981),
      'icon': Icons.verified_rounded,
      'gradient': [Color(0xFF10B981), Color(0xFF34D399)],
    },
    {
      'setor': 'Produção',
      'conformidade': 78.3,
      'cor': Color(0xFFF59E0B),
      'icon': Icons.engineering_rounded,
      'gradient': [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    },
    {
      'setor': 'Administrativo',
      'conformidade': 85.7,
      'cor': Color(0xFF3B82F6),
      'icon': Icons.work_rounded,
      'gradient': [Color(0xFF3B82F6), Color(0xFF60A5FA)],
    },
    {
      'setor': 'Manutenção',
      'conformidade': 71.2,
      'cor': Color(0xFFEF4444),
      'icon': Icons.build_rounded,
      'gradient': [Color(0xFFEF4444), Color(0xFFF87171)],
    },
    {
      'setor': 'Logística',
      'conformidade': 68.9,
      'cor': Color(0xFF8B5CF6),
      'icon': Icons.local_shipping_rounded,
      'gradient': [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    },
  ];

  late final AnimationController _segController;

  @override
  void initState() {
    super.initState();
    _segController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _animStarted = true);
    });
  }

  @override
  void dispose() {
    _segController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [cs.surfaceContainerHigh, cs.surfaceContainerHighest]
                  : [cs.surface, cs.surfaceContainerLow],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme, cs),
                const SizedBox(height: 24),

                // Conteúdo principal responsivo
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isLargeScreen = constraints.maxWidth > 1200;
                    final isMediumScreen = constraints.maxWidth > 600;

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: _selectedView == 'Geral'
                          ? _buildResponsiveGeralView(
                              theme,
                              cs,
                              isLargeScreen,
                              isMediumScreen,
                            )
                          : _buildResponsiveSetorView(
                              theme,
                              cs,
                              isLargeScreen,
                              isMediumScreen,
                            ),
                    );
                  },
                ),

                const SizedBox(height: 20),
                _buildModernLegend(theme, cs),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme cs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ícone e título
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: cs.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conformidade de EPIs',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Monitoramento em tempo real do uso adequado de equipamentos',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Segment control moderno
        _buildModernSegmentControl(),
      ],
    );
  }

  Widget _buildModernSegmentControl() {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _modernSegmentButton('Geral', Icons.donut_large_rounded),
          const SizedBox(width: 8),
          _modernSegmentButton('Setores', Icons.pie_chart_rounded),
        ],
      ),
    );
  }

  Widget _modernSegmentButton(String label, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = _selectedView == label;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedView = label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [cs.primary, cs.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveGeralView(
    ThemeData theme,
    ColorScheme cs,
    bool isLarge,
    bool isMedium,
  ) {
    return Column(
      children: [
        // Gauge principal com layout responsivo
        isLarge
            ? _buildLargeGeralLayout(theme, cs)
            : isMedium
            ? _buildMediumGeralLayout(theme, cs)
            : _buildSmallGeralLayout(theme, cs),

        const SizedBox(height: 24),

        // Estatísticas adicionais
        _buildModernStats(theme, cs),
      ],
    );
  }

  Widget _buildLargeGeralLayout(ThemeData theme, ColorScheme cs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildModernGauge(theme, cs, 280)),
        const SizedBox(width: 32),
        Expanded(flex: 2, child: _buildGeralInsights(theme, cs)),
      ],
    );
  }

  Widget _buildMediumGeralLayout(ThemeData theme, ColorScheme cs) {
    return Column(
      children: [
        _buildModernGauge(theme, cs, 240),
        const SizedBox(height: 24),
        _buildGeralInsights(theme, cs),
      ],
    );
  }

  Widget _buildSmallGeralLayout(ThemeData theme, ColorScheme cs) {
    return Column(
      children: [
        _buildModernGauge(theme, cs, 200),
        const SizedBox(height: 20),
        _buildGeralInsights(theme, cs),
      ],
    );
  }

  Widget _buildModernGauge(ThemeData theme, ColorScheme cs, double size) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _animStarted ? _conformidadeGeral : 0),
      duration: const Duration(milliseconds: 1800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final gradientColors = _getConformityGradient(value);

        return Container(
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Efeito de brilho
              if (value > 70)
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    margin: EdgeInsets.all(size * 0.15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          gradientColors.last.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

              // Gauge principal
              SfRadialGauge(
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
                      // Fundo do gauge
                      RangePointer(
                        value: 100,
                        width: 0.28,
                        cornerStyle: CornerStyle.bothCurve,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.1),
                        dashArray: const [4, 8],
                      ),

                      // Valor principal
                      RangePointer(
                        value: value,
                        width: 0.24,
                        cornerStyle: CornerStyle.bothCurve,
                        gradient: SweepGradient(
                          colors: gradientColors,
                          stops: const [0.2, 0.8],
                        ),
                      ),

                      // Marcador
                      MarkerPointer(
                        value: value,
                        markerHeight: 24,
                        markerWidth: 24,
                        markerType: MarkerType.circle,
                        color: cs.surface,
                        borderWidth: 4,
                        borderColor: _getConformityColor(value),
                      ),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        positionFactor: 0.1,
                        angle: 90,
                        widget: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TweenAnimationBuilder<int>(
                              tween: IntTween(begin: 0, end: value.round()),
                              duration: const Duration(milliseconds: 1400),
                              builder: (context, val, _) {
                                return Text(
                                  '$val%',
                                  style: TextStyle(
                                    fontSize: size * 0.16,
                                    fontWeight: FontWeight.w900,
                                    color: _getConformityColor(value),
                                    height: 1,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _getConformityColor(
                                  value,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getConformityColor(
                                    value,
                                  ).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                _getConformityStatus(value),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _getConformityColor(value),
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildGeralInsights(ThemeData theme, ColorScheme cs) {
    final avg = _calculateAverageSector();
    final delta = _conformidadeGeral - avg;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Análise Detalhada',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        // Média dos setores
        _buildInsightCard(
          theme,
          cs,
          'Média dos Setores',
          '${avg.toStringAsFixed(1)}%',
          delta >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
          delta >= 0 ? Colors.green : Colors.red,
          '${delta.abs().toStringAsFixed(1)}pts ${delta >= 0 ? 'acima' : 'abaixo'}',
        ),

        const SizedBox(height: 12),

        // Insights rápidos
        ..._buildQuickInsights(theme, cs),
      ],
    );
  }

  Widget _buildInsightCard(
    ThemeData theme,
    ColorScheme cs,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildQuickInsights(ThemeData theme, ColorScheme cs) {
    final best = _sectorConformity.reduce(
      (a, b) =>
          (a['conformidade'] as double) > (b['conformidade'] as double) ? a : b,
    );
    final worst = _sectorConformity.reduce(
      (a, b) =>
          (a['conformidade'] as double) < (b['conformidade'] as double) ? a : b,
    );

    return [
      _quickInsightItem(
        'Melhor desempenho: ${best['setor']}',
        '${best['conformidade'].toStringAsFixed(1)}%',
        Icons.emoji_events_rounded,
        Colors.green,
      ),
      const SizedBox(height: 8),
      _quickInsightItem(
        'Setor mais crítico: ${worst['setor']}',
        '${worst['conformidade'].toStringAsFixed(1)}%',
        Icons.warning_rounded,
        Colors.orange,
      ),
    ];
  }

  Widget _quickInsightItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 13, color: cs.onSurface),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveSetorView(
    ThemeData theme,
    ColorScheme cs,
    bool isLarge,
    bool isMedium,
  ) {
    final crossAxisCount = isLarge
        ? 3
        : isMedium
        ? 2
        : 1;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: isLarge ? 1.0 : 1.1,
      children: _sectorConformity
          .map((sector) => _buildModernSectorCard(theme, cs, sector))
          .toList(),
    );
  }

  Widget _buildModernSectorCard(
    ThemeData theme,
    ColorScheme cs,
    Map<String, dynamic> sector,
  ) {
    final conformity = sector['conformidade'] as double;
    final gradient = sector['gradient'] as List<Color>;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showSectorDetails(sector),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header do card - MAIOR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradient),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          sector['icon'] as IconData,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sector['setor'] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${conformity.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _getConformityColor(conformity),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _buildStatusBadge(conformity),
                ],
              ),

              const SizedBox(height: 20),

              // Mini gauge - MAIOR
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: SfRadialGauge(
                      axes: [
                        RadialAxis(
                          minimum: 0,
                          maximum: 100,
                          showTicks: false,
                          showLabels: false,
                          axisLineStyle: AxisLineStyle(
                            thickness: 0.15,
                            color: cs.outlineVariant.withValues(alpha: 0.2),
                          ),
                          pointers: [
                            RangePointer(
                              value: conformity,
                              width: 0.12,
                              cornerStyle: CornerStyle.bothCurve,
                              gradient: SweepGradient(colors: gradient),
                            ),
                            MarkerPointer(
                              value: conformity,
                              markerType: MarkerType.circle,
                              markerHeight: 18,
                              markerWidth: 18,
                              color: cs.surface,
                              borderWidth: 3,
                              borderColor: _getConformityColor(conformity),
                            ),
                          ],
                          annotations: [
                            GaugeAnnotation(
                              widget: Text(
                                '${conformity.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Informações compactas - MAIOR
              _buildSectorCompactInfo(sector['setor'] as String),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(double conformity) {
    final color = _getConformityColor(conformity);
    final status = _getConformityStatus(conformity);
    final icon = conformity >= 90
        ? Icons.verified_rounded
        : conformity >= 70
        ? Icons.check_circle_rounded
        : Icons.warning_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorCompactInfo(String setor) {
    final details = _getSectorDetails(setor);
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _compactInfoItem(
            Icons.people_rounded,
            '${details['funcionarios']}',
            'Pessoas',
          ),
          _compactInfoItem(
            Icons.security_rounded,
            '${details['epis']}',
            'EPIs',
          ),
        ],
      ),
    );
  }

  Widget _compactInfoItem(IconData icon, String value, String label) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildModernStats(ThemeData theme, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Setores Ativos',
            '${_sectorConformity.length}',
            Icons.business_center_rounded,
            Color(0xFF3B82F6),
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            'Colaboradores',
            '${_sumEmployees()}',
            Icons.people_alt_rounded,
            Color(0xFF10B981),
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            'EPIs Monitorados',
            '${_sumEpis()}',
            Icons.security_rounded,
            Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.2),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildModernLegend(ThemeData theme, ColorScheme cs) {
    return Wrap(
      spacing: 20,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem('Crítico (<70%)', Colors.red),
        _buildLegendItem('Moderado (70-90%)', Colors.orange),
        _buildLegendItem('Excelente (>90%)', Colors.green),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  void _showSectorDetails(Map<String, dynamic> sector) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            SectorDetailsDrawer(
              sector: sector,
              getSectorDetails: _getSectorDetails,
              getSectorConformity: _getSectorConformity,
              getSectorEmployees: _getSectorEmployees,
              getSectorEpis: _getSectorEpis,
              getConformityColor: _getConformityColor,
              getConformityStatus: _getConformityStatus,
            ),
      ),
    );
  }

  // ========== MÉTODOS AUXILIARES (mantidos para serem passados ao novo widget) ==========

  double _calculateAverageSector() {
    final sum = _sectorConformity.fold<double>(
      0,
      (prev, e) => prev + (e['conformidade'] as double),
    );
    return sum / _sectorConformity.length;
  }

  int _sumEmployees() {
    final details = _sectorConformity
        .map((s) => _getSectorDetails(s['setor'])['funcionarios'] as int)
        .toList();
    return details.fold<int>(0, (p, e) => p + e);
  }

  int _sumEpis() {
    final details = _sectorConformity
        .map((s) => _getSectorDetails(s['setor'])['epis'] as int)
        .toList();
    return details.fold<int>(0, (p, e) => p + e);
  }

  Map<String, dynamic> _getSectorDetails(String setor) {
    final details = {
      'Qualidade': {'funcionarios': 28, 'epis': 5},
      'Produção': {'funcionarios': 65, 'epis': 8},
      'Administrativo': {'funcionarios': 22, 'epis': 3},
      'Manutenção': {'funcionarios': 18, 'epis': 7},
      'Logística': {'funcionarios': 9, 'epis': 5},
    };
    return details[setor] ?? {'funcionarios': 0, 'epis': 0};
  }

  double _getSectorConformity(String setor) {
    final sector = _sectorConformity.firstWhere((s) => s['setor'] == setor);
    return sector['conformidade'] as double;
  }

  List<Map<String, dynamic>> _getSectorEmployees(String setor) {
    final employees = {
      'Qualidade': [
        {'nome': 'Ana Silva', 'cargo': 'Analista QA', 'conformidade': 95.0},
        {'nome': 'Carlos Santos', 'cargo': 'Inspetor', 'conformidade': 90.0},
        {
          'nome': 'Marina Oliveira',
          'cargo': 'Coordenadora',
          'conformidade': 100.0,
        },
        {'nome': 'Roberto Alves', 'cargo': 'Técnico', 'conformidade': 85.0},
      ],
      'Produção': [
        {'nome': 'João Pereira', 'cargo': 'Operador', 'conformidade': 85.0},
        {'nome': 'Pedro Costa', 'cargo': 'Supervisor', 'conformidade': 92.0},
        {'nome': 'Lucia Fernandes', 'cargo': 'Operadora', 'conformidade': 76.0},
        {'nome': 'Fernando Lima', 'cargo': 'Auxiliar', 'conformidade': 68.0},
      ],
      'Administrativo': [
        {
          'nome': 'Patricia Santos',
          'cargo': 'Assistente',
          'conformidade': 88.0,
        },
        {'nome': 'Ricardo Oliveira', 'cargo': 'Analista', 'conformidade': 92.0},
        {'nome': 'Camila Rodrigues', 'cargo': 'Gerente', 'conformidade': 95.0},
      ],
      'Manutenção': [
        {'nome': 'Marcos Silva', 'cargo': 'Técnico', 'conformidade': 72.0},
        {'nome': 'Juliana Costa', 'cargo': 'Eletricista', 'conformidade': 85.0},
        {'nome': 'Rodrigo Almeida', 'cargo': 'Mecânico', 'conformidade': 65.0},
      ],
      'Logística': [
        {'nome': 'Bruno Santos', 'cargo': 'Conferente', 'conformidade': 70.0},
        {'nome': 'Amanda Lima', 'cargo': 'Auxiliar', 'conformidade': 75.0},
        {'nome': 'Thiago Oliveira', 'cargo': 'Motorista', 'conformidade': 62.0},
      ],
    };
    return employees[setor] ?? [];
  }

  List<Map<String, dynamic>> _getSectorEpis(String setor) {
    final epis = {
      'Qualidade': [
        {'nome': 'Luvas de Proteção', 'obrigatorio': true},
        {'nome': 'Óculos de Segurança', 'obrigatorio': true},
        {'nome': 'Máscara', 'obrigatorio': true},
        {'nome': 'Avental', 'obrigatorio': false},
        {'nome': 'Calçado Safety', 'obrigatorio': true},
      ],
      'Produção': [
        {'nome': 'Capacete', 'obrigatorio': true},
        {'nome': 'Protetor Auditivo', 'obrigatorio': true},
        {'nome': 'Luvas', 'obrigatorio': true},
        {'nome': 'Botas', 'obrigatorio': true},
        {'nome': 'Óculos', 'obrigatorio': true},
        {'nome': 'Máscara', 'obrigatorio': true},
        {'nome': 'Colete Reflexivo', 'obrigatorio': true},
        {'nome': 'Avental', 'obrigatorio': false},
      ],
      'Administrativo': [
        {'nome': 'Calçado Safety', 'obrigatorio': true},
        {'nome': 'Avental', 'obrigatorio': false},
        {'nome': 'Máscara', 'obrigatorio': false},
      ],
      'Manutenção': [
        {'nome': 'Capacete', 'obrigatorio': true},
        {'nome': 'Óculos', 'obrigatorio': true},
        {'nome': 'Luvas', 'obrigatorio': true},
        {'nome': 'Botas', 'obrigatorio': true},
        {'nome': 'Máscara', 'obrigatorio': true},
        {'nome': 'Protetor Auditivo', 'obrigatorio': false},
        {'nome': 'Cinto de Segurança', 'obrigatorio': true},
      ],
      'Logística': [
        {'nome': 'Capacete', 'obrigatorio': true},
        {'nome': 'Luvas', 'obrigatorio': true},
        {'nome': 'Colete Reflexivo', 'obrigatorio': true},
        {'nome': 'Botas', 'obrigatorio': true},
        {'nome': 'Óculos', 'obrigatorio': false},
      ],
    };
    return epis[setor] ?? [];
  }

  // Métodos de cores e status
  List<Color> _getConformityGradient(double value) {
    if (value >= 90) return [Color(0xFF10B981), Color(0xFF34D399)];
    if (value >= 70) return [Color(0xFFF59E0B), Color(0xFFFBBF24)];
    return [Color(0xFFEF4444), Color(0xFFF87171)];
  }

  Color _getConformityColor(double value) {
    if (value >= 90) return Color(0xFF10B981);
    if (value >= 70) return Color(0xFFF59E0B);
    return Color(0xFFEF4444);
  }

  String _getConformityStatus(double value) {
    if (value >= 90) return 'Excelente';
    if (value >= 70) return 'Moderado';
    return 'Crítico';
  }
}