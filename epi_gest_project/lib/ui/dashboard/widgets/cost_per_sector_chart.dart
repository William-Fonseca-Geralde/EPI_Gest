import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CostPerSectorChart extends StatelessWidget {
  const CostPerSectorChart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Dados dos setores
    final List<Map<String, dynamic>> sectorData = [
      {'setor': 'Produção', 'custo': 28500, 'cor': const Color(0xFF2196F3)},
      {'setor': 'Manutenção', 'custo': 15600, 'cor': const Color(0xFF4CAF50)},
      {'setor': 'Logística', 'custo': 9800, 'cor': const Color(0xFFFFC107)},
      {'setor': 'Qualidade', 'custo': 12300, 'cor': const Color(0xFFFF5722)},
      {'setor': 'Administrativo', 'custo': 8700, 'cor': const Color(0xFF9C27B0)},
    ];

    final double maxCost = 30000;

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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Custo por Setor',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Distribuição mensal por área',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded),
                  onPressed: () {
                    // Ações futuras
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Gráfico de Barras com valores fixos
            SizedBox(
              height: 320,
              child: Stack(
                children: [
                  // Gráfico principal
                  BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxCost * 1.15,
                      barTouchData: BarTouchData(
                        enabled: false, // Sem tooltip
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              if (value >= 0 && value < sectorData.length) {
                                final setor = sectorData[value.toInt()];
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 4,
                                  child: Text(
                                    setor['setor'],
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 10000,
                            getTitlesWidget: (value, meta) {
                              if (value % 10000 == 0) {
                                return Text(
                                  'R\$ ${(value / 1000).toStringAsFixed(0)}k',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        drawVerticalLine: false,
                        horizontalInterval: 10000,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      barGroups: sectorData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: data['custo'].toDouble(),
                              color: data['cor'],
                              width: 32,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  // Valores em cima das colunas
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double chartWidth = constraints.maxWidth;
                        final double chartHeight = constraints.maxHeight;
                        final double barWidth = 32.0;
                        final double spaceBetweenBars = (chartWidth - (sectorData.length * barWidth)) / (sectorData.length + 1);

                        return Stack(
                          children: sectorData.asMap().entries.map((entry) {
                            final index = entry.key;
                            final data = entry.value;
                            
                            final double xPosition = spaceBetweenBars + (index * (barWidth + spaceBetweenBars)) + (barWidth / 2);
                            final double yPosition = chartHeight - ((data['custo'] / maxCost) * chartHeight * 0.85) - 25;

                            return Positioned(
                              left: xPosition - 30,
                              top: yPosition,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  _formatarReal(data['custo']),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Total geral
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Custo Total Mensal',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatarReal(sectorData.fold(0, (sum, setor) => sum + (setor['custo'] as int))),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Função para formatar em Real brasileiro
  String _formatarReal(int valor) {
    return 'R\$${valor.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )},00';
  }
}