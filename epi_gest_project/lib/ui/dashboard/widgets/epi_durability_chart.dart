import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EpiDurabilityChart extends StatelessWidget {
  const EpiDurabilityChart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List<Map<String, dynamic>> durabilityData = [
      {
        'epi': 'Luvas de Raspa',
        'duracaoReal': 25,
        'duracaoEsperada': 90,
        'eficiencia': 28, // 25/90 * 100
        'status': 'Crítico',
        'cor': Colors.red,
        'icone': Icons.work_outline_rounded,
      },
      {
        'epi': 'Botas de Segurança',
        'duracaoReal': 180,
        'duracaoEsperada': 210,
        'eficiencia': 86,
        'status': 'Bom',
        'cor': Colors.orange,
        'icone': Icons.engineering_rounded,
      },
      {
        'epi': 'Capacete',
        'duracaoReal': 365,
        'duracaoEsperada': 365,
        'eficiencia': 100,
        'status': 'Excelente',
        'cor': Colors.green,
        'icone': Icons.security_rounded,
      },
      {
        'epi': 'Óculos de Proteção',
        'duracaoReal': 85,
        'duracaoEsperada': 180,
        'eficiencia': 47,
        'status': 'Atenção',
        'cor': Colors.amber,
        'icone': Icons.visibility_rounded,
      },
      {
        'epi': 'Protetor Auditivo',
        'duracaoReal': 200,
        'duracaoEsperada': 180,
        'eficiencia': 111,
        'status': 'Acima',
        'cor': Colors.blue,
        'icone': Icons.hearing_rounded,
      },
    ];

    final double maxY = durabilityData.map((e) => e['duracaoEsperada']).reduce((a, b) => a > b ? a : b).toDouble() * 1.1;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Duração Real vs Esperada',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded),
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            // GRÁFICO DE BARRAS AGRUPADAS SIMPLIFICADO
            SizedBox(
              height: 320,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => colorScheme.surfaceContainerHighest,
                      tooltipPadding: const EdgeInsets.all(12),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final epi = durabilityData[groupIndex];
                        final isReal = rodIndex == 0;
                        final valor = isReal ? epi['duracaoReal'] : epi['duracaoEsperada'];
                        final label = isReal ? 'Duração Real' : 'Duração Esperada';
                        
                        if (isReal) {
                          // Tooltip para a barra REAL - mostra dias e porcentagem
                          return BarTooltipItem(
                            '$label: ${epi['duracaoReal']} dias\n'
                            'Eficiência: ${epi['eficiencia']}%',
                            TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          );
                        } else {
                          // Tooltip para a barra ESPERADA - mais simples
                          return BarTooltipItem(
                            '$label: ${epi['duracaoEsperada']} dias',
                            TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value >= 0 && value < durabilityData.length) {
                            final epi = durabilityData[value.toInt()];
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 4,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(epi['icone'], size: 16, color: epi['cor']),
                                  const SizedBox(height: 4),
                                  Text(
                                    _abreviar(epi['epi']),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 100,
                        getTitlesWidget: (value, meta) {
                          if (value % 100 == 0) {
                            return Text(
                              '${value.toInt()}d',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    horizontalInterval: 100,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: colorScheme.outlineVariant.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: colorScheme.outlineVariant.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  // BARRAS AGRUPADAS - REAL E ESPERADO
                  barGroups: durabilityData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final epi = entry.value;

                    return BarChartGroupData(
                      x: index,
                      groupVertically: true,
                      barRods: [
                        // BARRA DA DURAÇÃO REAL (colorida)
                        BarChartRodData(
                          toY: epi['duracaoReal'].toDouble(),
                          width: 20,
                          color: epi['cor'],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        // BARRA DA DURAÇÃO ESPERADA (cinza)
                        BarChartRodData(
                          toY: epi['duracaoEsperada'].toDouble(),
                          width: 20,
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // APENAS A LEGENDA SIMPLIFICADA
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Duração Real', Colors.blue, Icons.bar_chart_rounded),
                const SizedBox(width: 20),
                _buildLegendItem('Duração Esperada', Colors.grey, Icons.timeline_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _abreviar(String nome) {
    final ab = {
      'Luvas de Raspa': 'Luvas',
      'Botas de Segurança': 'Botas',
      'Óculos de Proteção': 'Óculos',
      'Protetor Auditivo': 'Prot. Auditivo',
    };
    return ab[nome] ?? nome;
  }
}