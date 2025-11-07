import 'package:flutter/material.dart';

class CriticalStockWidget extends StatelessWidget {
  const CriticalStockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Dados de estoque crítico
    final List<Map<String, dynamic>> criticalStock = [
      {
        'epi': 'Luvas de Raspa',
        'estoqueAtual': 50,
        'estoqueMinimo': 200,
        'diasRestantes': 3,
        'consumoDiario': 15,
        'cor': Colors.red,
      },
      {
        'epi': 'Mascara PFF2',
        'estoqueAtual': 120,
        'estoqueMinimo': 300,
        'diasRestantes': 8,
        'consumoDiario': 15,
        'cor': Colors.orange,
      },
      {
        'epi': 'Óculos de Proteção',
        'estoqueAtual': 45,
        'estoqueMinimo': 100,
        'diasRestantes': 6,
        'consumoDiario': 7,
        'cor': Colors.orange,
      },
      {
        'epi': 'Capacete',
        'estoqueAtual': 25,
        'estoqueMinimo': 50,
        'diasRestantes': 12,
        'consumoDiario': 2,
        'cor': Colors.yellow,
      },
      {
        'epi': 'Botas de Segurança',
        'estoqueAtual': 35,
        'estoqueMinimo': 80,
        'diasRestantes': 15,
        'consumoDiario': 2,
        'cor': Colors.yellow,
      },
    ];

    // Ordenar por dias restantes (menor primeiro)
    criticalStock.sort((a, b) => a['diasRestantes'].compareTo(b['diasRestantes']));

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
                      'Alertas de Estoque',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Itens com estoque crítico',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded),
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Lista de itens críticos
            ...criticalStock.take(5).map((item) {
              final percentual = (item['estoqueAtual'] / item['estoqueMinimo']) * 100;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: item['cor'].withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    // Indicador de criticidade
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item['cor'],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Informações do item
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['epi'],
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${item['estoqueAtual']} unidades',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '•',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Mín: ${item['estoqueMinimo']}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Dias restantes
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: item['cor'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${item['diasRestantes']}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: item['cor'],
                            ),
                          ),
                          Text(
                            'dias',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: item['cor'],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            // Resumo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Itens em alerta',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${criticalStock.length} EPIs',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Próximo a acabar',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        criticalStock.first['epi'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}