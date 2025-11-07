import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class ConformitySelectorChart extends StatefulWidget {
  const ConformitySelectorChart({super.key});

  @override
  State<ConformitySelectorChart> createState() => _ConformitySelectorChartState();
}

class _ConformitySelectorChartState extends State<ConformitySelectorChart>
    with SingleTickerProviderStateMixin {
  String _selectedView = 'Geral';

  // Valor geral (poderia vir de uma API)
  double _conformidadeGeral = 78.5;

  // Simula atualização (apenas demonstração)
  bool _animStarted = false;

  // Dados por setor
  final List<Map<String, dynamic>> _sectorConformity = [
    {'setor': 'Qualidade', 'conformidade': 92.5, 'cor': Colors.green, 'icon': Icons.verified_rounded},
    {'setor': 'Produção', 'conformidade': 78.3, 'cor': Colors.orange, 'icon': Icons.engineering_rounded},
    {'setor': 'Administrativo', 'conformidade': 85.7, 'cor': Colors.blue, 'icon': Icons.work_rounded},
    {'setor': 'Manutenção', 'conformidade': 71.2, 'cor': Colors.red, 'icon': Icons.build_rounded},
    {'setor': 'Logística', 'conformidade': 68.9, 'cor': Colors.purple, 'icon': Icons.local_shipping_rounded},
  ];

  // Controller para transições do segmento
  late final AnimationController _segController;

  @override
  void initState() {
    super.initState();
    _segController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Inicia animação única do gauge ao montar
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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Fundo com glassmorphism
            _buildFrostedBackground(context),

            // Conteúdo
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme, cs),
                  const SizedBox(height: 18),

                  // Conteúdo principal com animação de troca
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeInBack,
                    child: _selectedView == 'Geral'
                        ? _buildPremiumGeralView(theme, cs, key: const ValueKey('Geral'))
                        : _buildPremiumSetorView(theme, cs, key: const ValueKey('Setores')),
                  ),

                  const SizedBox(height: 16),
                  _buildPremiumLegend(theme, cs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fundo com blur e brilho sutil
  Widget _buildFrostedBackground(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Positioned.fill(
      child: Stack(
        children: [
          // Gradiente sutil por trás (substituição segura das propriedades antigas)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.surfaceContainerHighest.withValues(alpha: 0.7),
                  cs.surfaceContainerHigh.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),

          // Blur (glass)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: Colors.transparent,
            ),
          ),

          // Luz decorativa (top-left)
          Positioned(
            left: -60,
            top: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    cs.surfaceBright.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme cs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Título + descrição
        Expanded(
          child: Row(
            children: [
              // Ícone com aura
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      cs.primary.withValues(alpha: 0.95),
                      cs.primaryContainer.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Icon(Icons.verified_user_rounded, color: cs.onPrimary, size: 20),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conformidade de EPIs',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Taxa de colaboradores com EPIs válidos e insights automáticos',
                      style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Segment control custom
        _buildAnimatedSegmentControl(),
      ],
    );
  }

  Widget _buildAnimatedSegmentControl() {
    final cs = Theme.of(context).colorScheme;
    final isGeral = _selectedView == 'Geral';

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segmentButton('Geral', Icons.auto_graph_rounded),
          const SizedBox(width: 6),
          _segmentButton('Setores', Icons.pie_chart_rounded),
        ],
      ),
    );
  }

  Widget _segmentButton(String label, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = _selectedView == label;
    final baseColor = isSelected ? cs.primary : null;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedView = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? baseColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [BoxShadow(color: baseColor!.withValues(alpha: 0.18), blurRadius: 14, offset: const Offset(0, 6))]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? cs.onPrimary : cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? cs.onPrimary : cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumGeralView(ThemeData theme, ColorScheme cs, {Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: LayoutBuilder(builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;

              return Row(
                children: [
                  Expanded(
                    flex: isNarrow ? 0 : 6,
                    child: _buildAnimatedGauge(isNarrow, theme, cs),
                  ),

                  if (!isNarrow) const SizedBox(width: 18),

                  Expanded(
                    flex: isNarrow ? 0 : 4,
                    child: _buildGeralRightColumn(theme, cs),
                  ),
                ],
              );
            }),
          ),

          const SizedBox(height: 18),

          // Estatísticas e insights
          _buildAdditionalStats(theme, cs),
        ],
      ),
    );
  }

  Widget _buildAnimatedGauge(bool isNarrow, ThemeData theme, ColorScheme cs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _animStarted ? _conformidadeGeral : 0),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final gradientColors = _getConformityColors(value);

        return Stack(
          alignment: Alignment.center,
          children: [
            // Halo dinâmico
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: (value / 100).clamp(0.08, 0.28),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [gradientColors.last.withValues(alpha: 0.08), Colors.transparent],
                        radius: 0.9,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // GAUGE COM ESPESSURA AUMENTADA
            SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 100,
                  showLabels: false,
                  showTicks: false,
                  startAngle: 150,
                  endAngle: 30,
                  canRotateLabels: false,
                  axisLineStyle: const AxisLineStyle(
                    thickness: 0.00,
                    color: Colors.transparent,
                  ),
                  pointers: <GaugePointer>[
                    // 1) Fundo tracejado completo - ESPESSURA AUMENTADA
                    RangePointer(
                      value: 100,
                      width: 0.32, // Aumentado de 0.24 para 0.32
                      cornerStyle: CornerStyle.bothCurve,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.25), // Opacidade aumentada
                      dashArray: const <double>[8, 6],
                    ),

                    // 2) Ponteiro de valor real - ESPESSURA AUMENTADA
                    RangePointer(
                      value: value,
                      width: 0.24, // Aumentado de 0.16 para 0.24
                      cornerStyle: CornerStyle.bothCurve,
                      gradient: SweepGradient(colors: gradientColors, stops: const [0.0, 1.0]),
                    ),

                    // 3) Marcador - TAMANHO AUMENTADO
                    MarkerPointer(
                      value: value,
                      markerHeight: 28, // Aumentado de 24 para 28
                      markerWidth: 28,  // Aumentado de 24 para 28
                      markerType: MarkerType.circle,
                      color: cs.surface,
                      borderWidth: 4,   // Aumentado de 3 para 4
                      borderColor: _getConformityColor(value),
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      positionFactor: 0.1,
                      angle: 90,
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TweenAnimationBuilder<int>(
                            tween: IntTween(begin: 0, end: value.round()),
                            duration: const Duration(milliseconds: 1100),
                            builder: (context, val, _) {
                              return Text(
                                '$val%',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  color: _getConformityColor(value),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getConformityColor(value).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _getConformityColor(value).withValues(alpha: 0.22)),
                            ),
                            child: Text(
                              _getConformityStatus(value),
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _getConformityColor(value)),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildGeralRightColumn(ThemeData theme, ColorScheme cs) {
    final avg = _calculateAverageSector();
    final delta = (_conformidadeGeral - avg).toStringAsFixed(1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Média dos setores', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${avg.toStringAsFixed(1)}%', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: cs.onSurface)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (_conformidadeGeral >= avg ? Colors.green : Colors.red).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(_conformidadeGeral >= avg ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 14, color: _conformidadeGeral >= avg ? Colors.green : Colors.red),
                  const SizedBox(width: 6),
                  Text('${delta}pt', style: TextStyle(fontWeight: FontWeight.w700, color: _conformidadeGeral >= avg ? Colors.green : Colors.red)),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Micro-insights
        _buildMicroInsights(),
      ],
    );
  }

  Widget _buildMicroInsights() {
    // Gera 2 insights simples com base nos dados
    final worst = _sectorConformity.reduce((a, b) => (a['conformidade'] as double) < (b['conformidade'] as double) ? a : b);
    final best = _sectorConformity.reduce((a, b) => (a['conformidade'] as double) > (b['conformidade'] as double) ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _insightTile('Melhor setor: ${best['setor']}', 'Conformidade ${best['conformidade'].toStringAsFixed(1)}%'),
        const SizedBox(height: 8),
        _insightTile('Setor mais crítico: ${worst['setor']}', 'Conformidade ${worst['conformidade'].toStringAsFixed(1)}%'),
      ],
    );
  }

  Widget _insightTile(String title, String subtitle) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_rounded, size: 18, color: cs.primary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSetorView(ThemeData theme, ColorScheme cs, {Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.15,
        children: _sectorConformity.map((sector) => _buildSectorGauge(theme, cs, sector)).toList(),
      ),
    );
  }

  Widget _buildSectorGauge(ThemeData theme, ColorScheme cs, Map<String, dynamic> sector) {
    final conformity = sector['conformidade'] as double;
    final color = sector['cor'] as Color;
    final icon = sector['icon'] as IconData;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Exemplo: ação ao tocar no card
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${sector['setor']} - ${conformity.toStringAsFixed(1)}%')));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 6)),
            ],
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.04)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                      child: Icon(icon, size: 18, color: color),
                    ),
                    const SizedBox(width: 10),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(sector['setor'], style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface)),
                      const SizedBox(height: 4),
                      Text('${conformity.toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.w800, color: _getConformityColor(conformity))),
                    ])
                  ]),

                  // Indicador lateral
                  _miniPerformanceBadge(conformity),
                ],
              ),

              // Mini gauge ATUALIZADO
              SizedBox(
                height: 84,
                child: SfRadialGauge(
                  axes: [
                    RadialAxis(
                      minimum: 0,
                      maximum: 100,
                      showTicks: false,
                      showLabels: false,
                      axisLineStyle: AxisLineStyle(thickness: 0.12, color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
                      pointers: [
                        RangePointer(
                          value: conformity, 
                          width: 0.20, // Aumentado de 0.12 para 0.20
                          cornerStyle: CornerStyle.bothCurve, 
                          gradient: SweepGradient(colors: _getConformityColors(conformity))
                        ),
                        MarkerPointer(
                          value: conformity, 
                          markerType: MarkerType.circle, 
                          markerHeight: 16, // Aumentado de 12 para 16
                          markerWidth: 16,  // Aumentado de 12 para 16
                          color: Theme.of(context).colorScheme.surface, 
                          borderWidth: 3,   // Aumentado de 2 para 3
                          borderColor: _getConformityColor(conformity)
                        ),
                      ],
                      annotations: [
                        GaugeAnnotation(widget: Text('${conformity.toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cs.onSurface)), positionFactor: 0.1, angle: 90),
                      ],
                    )
                  ],
                ),
              ),

              // Info compacto
              _buildSectorCompactInfo(sector['setor']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniPerformanceBadge(double conformity) {
    final color = _getConformityColor(conformity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Icon(conformity >= 90 ? Icons.emoji_events_rounded : conformity >= 70 ? Icons.thumb_up_rounded : Icons.warning_rounded, size: 14, color: color),
        const SizedBox(width: 8),
        Text(_getConformityStatus(conformity), style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 12)),
      ]),
    );
  }

  Widget _buildSectorCompactInfo(String setor) {
    final details = _getSectorDetails(setor);
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(color: cs.surfaceContainerLow.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              _iconStat(Icons.people_rounded, details['funcionarios'].toString()),
              const SizedBox(width: 14),
            ],
          ),
          Row(
            children: [
              _iconStat(Icons.security_rounded, details['epis'].toString()),
              const SizedBox(width: 14),
            ],
          ),
          Expanded(
            child: Text(
              details['tiposEpis'],
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconStat(IconData ic, String value) {
    final cs = Theme.of(context).colorScheme;
    return Column(children: [
      Icon(ic, size: 16, color: cs.onSurfaceVariant),
      const SizedBox(height: 6),
      Text(value, style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface)),
    ]);
  }

  Widget _buildAdditionalStats(ThemeData theme, ColorScheme colorScheme) {
    final cs = colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.04)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem('Setores', '${_sectorConformity.length}', Icons.business_rounded, Colors.blue),
          _buildStatItem('Colaboradores', '${_sumEmployees()}', Icons.people_rounded, Colors.green),
          _buildStatItem('EPIs distintos', '${_sumEpis()}', Icons.security_rounded, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: cs.onSurface)),
        Text(label, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildPremiumLegend(ThemeData theme, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.spaceBetween,
        children: [
          _buildPremiumStatusIndicator('Crítico (<70%)', Colors.red),
          _buildPremiumStatusIndicator('Moderado (70-90%)', Colors.orange),
          _buildPremiumStatusIndicator('Excelente (>90%)', Colors.green),
        ],
      ),
    );
  }

  Widget _buildPremiumStatusIndicator(String label, Color color) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 6)]),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface)),
      ],
    );
  }

  // ---------- Helpers ----------

  double _calculateAverageSector() {
    final sum = _sectorConformity.fold<double>(0, (prev, e) => prev + (e['conformidade'] as double));
    return sum / _sectorConformity.length;
  }

  int _sumEmployees() {
    final details = _sectorConformity.map((s) => _getSectorDetails(s['setor'])['funcionarios'] as int).toList();
    return details.fold<int>(0, (p, e) => p + e);
  }

  int _sumEpis() {
    final details = _sectorConformity.map((s) => _getSectorDetails(s['setor'])['epis'] as int).toList();
    return details.fold<int>(0, (p, e) => p + e);
  }

  Map<String, dynamic> _getSectorDetails(String setor) {
    final details = {
      'Qualidade': {
        'funcionarios': 28,
        'epis': 5,
        'tiposEpis': 'Luvas, Óculos, Máscara, Avental, Calçado'
      },
      'Produção': {
        'funcionarios': 65,
        'epis': 8,
        'tiposEpis': 'Capacete, Prot. Auditivo, Luvas, Botas, Óculos'
      },
      'Administrativo': {
        'funcionarios': 22,
        'epis': 3,
        'tiposEpis': 'Nenhum ou Avental, Calçado'
      },
      'Manutenção': {
        'funcionarios': 18,
        'epis': 7,
        'tiposEpis': 'Luvas, Óculos, Máscara, Capacete, Botas'
      },
      'Logística': {
        'funcionarios': 9,
        'epis': 5,
        'tiposEpis': 'Capacete, Luvas, Colete, Botas, Óculos'
      },
    };

    return details[setor] ?? {'funcionarios': 0, 'epis': 0, 'tiposEpis': ''};
  }

  List<Color> _getConformityColors(double value) {
    if (value >= 90) return [Colors.green.shade600, Colors.lightGreenAccent.shade100];
    if (value >= 70) return [Colors.orange.shade700, Colors.amberAccent.shade100];
    return [Colors.red.shade600, Colors.deepOrangeAccent.shade200];
  }

  Color _getConformityColor(double value) {
    if (value >= 90) return Colors.green.shade600;
    if (value >= 70) return Colors.orange.shade700;
    return Colors.red.shade600;
  }

  String _getConformityStatus(double value) {
    if (value >= 90) return 'Excelente';
    if (value >= 70) return 'Moderado';
    return 'Crítico';
  }
}