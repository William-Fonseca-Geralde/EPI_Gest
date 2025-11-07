import 'package:flutter/material.dart';

class TopEmployeesChart extends StatelessWidget {
  const TopEmployeesChart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Dados dos funcionários que mais fazem trocas
    final List<Map<String, dynamic>> employeesData = [
      {
        'posicao': 1,
        'nome': 'Carlos Silva',
        'trocas': 18,
        'valor': 2845.00,
        'ultimaTroca': '15/08/2023',
        'cargo': 'Soldador',
        'cor': Colors.blue
      },
      {
        'posicao': 2,
        'nome': 'Ana Oliveira',
        'trocas': 12,
        'valor': 1920.00,
        'ultimaTroca': '20/08/2023',
        'cargo': 'Operadora',
        'cor': Colors.green
      },
      {
        'posicao': 3,
        'nome': 'Roberto Santos',
        'trocas': 9,
        'valor': 1575.00,
        'ultimaTroca': '22/08/2023',
        'cargo': 'Eletricista',
        'cor': Colors.orange
      },
      {
        'posicao': 4,
        'nome': 'Maria Costa',
        'trocas': 8,
        'valor': 1420.00,
        'ultimaTroca': '18/08/2023',
        'cargo': 'Auxiliar',
        'cor': Colors.purple
      },
      {
        'posicao': 5,
        'nome': 'João Pereira',
        'trocas': 7,
        'valor': 1350.00,
        'ultimaTroca': '25/08/2023',
        'cargo': 'Mecânico',
        'cor': Colors.red
      },
    ];

    // Cálculos dos totais (CORRIGIDOS)
    final totalValor = employeesData.fold<double>(0, (sum, emp) => sum + (emp['valor'] as double));
    final totalTrocas = employeesData.fold<int>(0, (sum, emp) => sum + (emp['trocas'] as int));

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
                      'Top Colaboradores',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ranking por quantidade de trocas de EPIs',
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

            const SizedBox(height: 24),

            // Tabela
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Cabeçalho da tabela
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'POSIÇÃO',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'COLABORADOR',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'QTD. TROCAS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'VALOR TOTAL',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'ÚLTIMA TROCA',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Linhas da tabela
                  ...employeesData.map((employee) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: colorScheme.outlineVariant.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Posição
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: employee['cor'].withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: employee['cor'].withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                '${employee['posicao']}º',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: employee['cor'],
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Nome e Cargo
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  employee['nome'],
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  employee['cargo'],
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Quantidade de Trocas
                          Expanded(
                            flex: 2,
                            child: Text(
                              employee['trocas'].toString(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          // Valor Total
                          Expanded(
                            flex: 2,
                            child: Text(
                              _formatarReal(employee['valor']),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          // Última Troca
                          Expanded(
                            flex: 2,
                            child: Text(
                              employee['ultimaTroca'],
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Rodapé com informações adicionais (CORRIGIDO)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total em Trocas',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        _formatarReal(totalValor),
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
                        'Total de Trocas',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        totalTrocas.toString(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
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

  // Função para formatar em Real brasileiro
  String _formatarReal(double valor) {
    return 'R\$${valor.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+,)'),
      (Match m) => '${m[1]}.',
    )}';
  }
}