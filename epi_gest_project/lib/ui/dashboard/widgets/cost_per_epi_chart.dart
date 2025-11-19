import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'dart:convert';

class CostPerEpiChart extends StatefulWidget {
  const CostPerEpiChart({super.key});

  @override
  State<CostPerEpiChart> createState() => _CostPerEpiChartState();
}

class _CostPerEpiChartState extends State<CostPerEpiChart> {
  bool _showValues = true;
  bool _sortedByValue = true;
  List<Map<String, dynamic>> _epiData = [];
  bool _isExporting = false;

  // ========== DADOS FICTÍCIOS ESTRATÉGICOS ==========
  final List<Map<String, dynamic>> _dadosHistoricosCompras = [
    {
      'epi': 'Capacete',
      'compras': [
        {
          'data': '2024-01-15',
          'fornecedor': 'Segurança Total Ltda',
          'quantidade': 50,
          'custoUnitario': 118.00,
        },
        {
          'data': '2024-02-10',
          'fornecedor': 'Proteção Max',
          'quantidade': 60,
          'custoUnitario': 122.00,
        },
        {
          'data': '2024-03-05',
          'fornecedor': 'Segurança Total Ltda',
          'quantidade': 40,
          'custoUnitario': 125.00,
        },
      ],
    },
    {
      'epi': 'Botas',
      'compras': [
        {
          'data': '2024-01-20',
          'fornecedor': 'Calçados Seguros',
          'quantidade': 80,
          'custoUnitario': 58.00,
        },
        {
          'data': '2024-02-15',
          'fornecedor': 'Proteção Pesada',
          'quantidade': 70,
          'custoUnitario': 62.50,
        },
        {
          'data': '2024-03-12',
          'fornecedor': 'Calçados Seguros',
          'quantidade': 50,
          'custoUnitario': 65.00,
        },
      ],
    },
    {
      'epi': 'Luvas',
      'compras': [
        {
          'data': '2024-01-10',
          'fornecedor': 'Proteção Fina',
          'quantidade': 200,
          'custoUnitario': 16.50,
        },
        {
          'data': '2024-02-08',
          'fornecedor': 'Safety Hands',
          'quantidade': 180,
          'custoUnitario': 17.00,
        },
        {
          'data': '2024-03-20',
          'fornecedor': 'Proteção Fina',
          'quantidade': 120,
          'custoUnitario': 17.50,
        },
      ],
    },
    {
      'epi': 'Óculos',
      'compras': [
        {
          'data': '2024-01-25',
          'fornecedor': 'Visão Protegida',
          'quantidade': 100,
          'custoUnitario': 18.50,
        },
        {
          'data': '2024-02-20',
          'fornecedor': 'Safety Vision',
          'quantidade': 110,
          'custoUnitario': 19.50,
        },
        {
          'data': '2024-03-15',
          'fornecedor': 'Visão Protegida',
          'quantidade': 100,
          'custoUnitario': 20.00,
        },
      ],
    },
    {
      'epi': 'Prot. Auditivo',
      'compras': [
        {
          'data': '2024-01-30',
          'fornecedor': 'Som Seguro',
          'quantidade': 60,
          'custoUnitario': 23.00,
        },
        {
          'data': '2024-02-25',
          'fornecedor': 'Proteção Auricular',
          'quantidade': 70,
          'custoUnitario': 24.50,
        },
        {
          'data': '2024-03-18',
          'fornecedor': 'Som Seguro',
          'quantidade': 50,
          'custoUnitario': 25.00,
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _epiData = [
      {
        'epi': 'Capacete',
        'custo': 18300,
        'cor': Colors.blue.shade700,
        'quantidade': 150,
        'custoUnitario': 122.00,
      },
      {
        'epi': 'Botas',
        'custo': 12500,
        'cor': Colors.green.shade700,
        'quantidade': 200,
        'custoUnitario': 62.50,
      },
      {
        'epi': 'Luvas',
        'custo': 8500,
        'cor': Colors.orange.shade700,
        'quantidade': 500,
        'custoUnitario': 17.00,
      },
      {
        'epi': 'Óculos',
        'custo': 6200,
        'cor': Colors.purple.shade700,
        'quantidade': 310,
        'custoUnitario': 20.00,
      },
      {
        'epi': 'Prot. Auditivo',
        'custo': 4500,
        'cor': Colors.red.shade700,
        'quantidade': 180,
        'custoUnitario': 25.00,
      },
    ];
    _sortDataByValue();
  }

  void _sortDataByValue() {
    setState(() {
      _epiData.sort((a, b) => b['custo'].compareTo(a['custo']));
      _sortedByValue = true;
    });
  }

  void _sortDataByName() {
    setState(() {
      _epiData.sort((a, b) => a['epi'].compareTo(b['epi']));
      _sortedByValue = false;
    });
  }

  void _toggleValues() {
    setState(() {
      _showValues = !_showValues;
    });
  }

  // ========== CÁLCULO DO IMPACTO UNITÁRIO ==========
  double _calcularImpactoUnitario(double custoUnitario, int totalGeral) {
    return (custoUnitario / totalGeral) * 100;
  }

  // ========== ANÁLISE DE HISTÓRICO DE COMPRAS ==========
  Map<String, dynamic> _analisarHistoricoCompras(String epiNome) {
    final historico = _dadosHistoricosCompras.firstWhere(
      (item) => item['epi'] == epiNome,
      orElse: () => {'compras': []},
    );

    final compras = List<Map<String, dynamic>>.from(historico['compras']);
    if (compras.isEmpty) {
      return {
        'tendencia': 'estavel',
        'variacaoPercentual': 0.0,
        'menorPreco': 0.0,
        'maiorPreco': 0.0,
        'fornecedorMaisBarato': 'N/A',
        'amplitude': 0.0,
        'mediaPrecos': 0.0,
      };
    }

    final precos = compras.map((c) => c['custoUnitario'] as double).toList();
    final menorPreco = precos.reduce((a, b) => a < b ? a : b);
    final maiorPreco = precos.reduce((a, b) => a > b ? a : b);
    final mediaPrecos = precos.reduce((a, b) => a + b) / precos.length;
    final amplitude = maiorPreco - menorPreco;

    // Calcular variação percentual (última vs primeira compra)
    final variacaoPercentual =
        ((precos.last - precos.first) / precos.first) * 100;

    // Determinar tendência
    String tendencia;
    if (variacaoPercentual > 2) {
      tendencia = 'alta';
    } else if (variacaoPercentual < -2) {
      tendencia = 'baixa';
    } else {
      tendencia = 'estavel';
    }

    // Encontrar fornecedor mais barato
    final fornecedorMaisBarato = compras.reduce(
      (a, b) => (a['custoUnitario'] as double) < (b['custoUnitario'] as double)
          ? a
          : b,
    )['fornecedor'];

    return {
      'tendencia': tendencia,
      'variacaoPercentual': variacaoPercentual,
      'menorPreco': menorPreco,
      'maiorPreco': maiorPreco,
      'fornecedorMaisBarato': fornecedorMaisBarato,
      'amplitude': amplitude,
      'mediaPrecos': mediaPrecos,
      'compras': compras,
    };
  }

  // ========== MODAL DE HISTÓRICO DE COMPRAS ==========
  void _showHistoricoCompras(String epiNome) {
    final analise = _analisarHistoricoCompras(epiNome);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.history, color: colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Histórico de Compras - $epiNome',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Análise temporal e estratégica de preços',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card de Insights
                    _buildInsightsCard(theme, colorScheme, analise),
                    const SizedBox(height: 24),

                    // Tabela de Histórico
                    _buildHistoricoTable(
                      theme,
                      colorScheme,
                      analise['compras'],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard(
    ThemeData theme,
    ColorScheme colorScheme,
    Map<String, dynamic> analise,
  ) {
    final Color tendenciaColor = analise['tendencia'] == 'alta'
        ? Colors.red
        : analise['tendencia'] == 'baixa'
        ? Colors.green
        : Colors.blue;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📈 Insights do Histórico',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildInsightChip(
                  'Tendência',
                  analise['tendencia'].toString().toUpperCase(),
                  tendenciaColor,
                  theme,
                ),
                _buildInsightChip(
                  'Variação',
                  '${analise['variacaoPercentual'].toStringAsFixed(1)}%',
                  tendenciaColor,
                  theme,
                ),
                _buildInsightChip(
                  'Amplitude',
                  'R\$${analise['amplitude'].toStringAsFixed(2)}'.replaceAll(
                    '.',
                    ',',
                  ),
                  Colors.orange,
                  theme,
                ),
                _buildInsightChip(
                  'Fornecedor + Barato',
                  analise['fornecedorMaisBarato'].toString().split(' ').first,
                  Colors.green,
                  theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightChip(
    String label,
    String value,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricoTable(
    ThemeData theme,
    ColorScheme colorScheme,
    List<dynamic> compras,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📋 Últimas 3 Compras',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                dataRowMinHeight: 40,
                headingRowColor: MaterialStateProperty.all(
                  colorScheme.primaryContainer.withOpacity(0.1),
                ),
                columns: [
                  DataColumn(
                    label: Text('Data', style: _getHeaderStyle(theme)),
                  ),
                  DataColumn(
                    label: Text('Fornecedor', style: _getHeaderStyle(theme)),
                  ),
                  DataColumn(
                    label: Text('Quantidade', style: _getHeaderStyle(theme)),
                  ),
                  DataColumn(
                    label: Text('Custo Unit.', style: _getHeaderStyle(theme)),
                  ),
                  DataColumn(
                    label: Text('Custo Total', style: _getHeaderStyle(theme)),
                  ),
                ],
                rows: compras.map((compra) {
                  final custoTotal =
                      (compra['quantidade'] as int) *
                      (compra['custoUnitario'] as double);
                  return DataRow(
                    cells: [
                      DataCell(Text(compra['data'])),
                      DataCell(Text(compra['fornecedor'])),
                      DataCell(Text(compra['quantidade'].toString())),
                      DataCell(
                        Text(
                          'R\$${compra['custoUnitario'].toStringAsFixed(2).replaceAll('.', ',')}',
                        ),
                      ),
                      DataCell(
                        Text(
                          'R\$${custoTotal.toStringAsFixed(2).replaceAll('.', ',')}',
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _getHeaderStyle(ThemeData theme) {
    return theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ) ??
        const TextStyle();
  }

  // ========== ANÁLISE DETALHADA COMPLETA ==========
  void _showDetailedAnalysis() {
    final totalGeral = _epiData.fold(
      0,
      (sum, epi) => sum + (epi['custo'] as int),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAnalysisSheet(totalGeral),
    );
  }

  Widget _buildAnalysisSheet(int totalGeral) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Análise Estratégica - Custos de EPI',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Visão completa com impacto unitário e histórico',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumo Geral
                  _buildEnhancedSummaryCard(theme, colorScheme, totalGeral),

                  const SizedBox(height: 24),

                  // Card de Porcentagem Total
                  _buildPorcentagemTotalCard(theme, colorScheme, totalGeral),

                  const SizedBox(height: 24),

                  // Tabela Detalhada
                  _buildDetailedTable(theme, colorScheme, totalGeral),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPorcentagemTotalCard(
    ThemeData theme,
    ColorScheme colorScheme,
    int totalGeral,
  ) {
    // Ordenar por porcentagem total (maior primeiro)
    final epiComPorcentagem =
        _epiData.map((epi) {
          final porcentagemTotal = (epi['custo'] / totalGeral * 100);
          final impactoUnitario = _calcularImpactoUnitario(
            epi['custoUnitario'],
            totalGeral,
          );
          return {
            ...epi,
            'porcentagemTotal': porcentagemTotal,
            'impactoUnitario': impactoUnitario,
          };
        }).toList()..sort(
          (a, b) => b['porcentagemTotal'].compareTo(a['porcentagemTotal']),
        );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '🎯 Distribuição Percentual no Orçamento',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Participação de cada item no custo total - Para priorização de investimentos',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ...epiComPorcentagem.map((epi) {
              return _buildPorcentagemTotalRow(
                epi['epi'],
                epi['custo'],
                epi['porcentagemTotal'],
                epi['impactoUnitario'],
                epi['cor'],
                theme,
                colorScheme,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPorcentagemTotalRow(
    String epi,
    int custoTotal,
    double porcentagemTotal,
    double impactoUnitario,
    Color cor,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  epi,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_formatarReal(custoTotal)} | ${porcentagemTotal.toStringAsFixed(1)}% do total',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Impacto unitário: ${impactoUnitario.toStringAsFixed(2)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getPorcentagemColor(porcentagemTotal, colorScheme),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${porcentagemTotal.toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPorcentagemColor(double porcentagem, ColorScheme colorScheme) {
    if (porcentagem > 30) return Colors.red;
    if (porcentagem > 15) return Colors.orange;
    return Colors.green;
  }

  Widget _buildEnhancedSummaryCard(
    ThemeData theme,
    ColorScheme colorScheme,
    int totalGeral,
  ) {
    final maiorCusto = _epiData.first;
    final menorCusto = _epiData.last;
    final percentualMaiorCusto = (maiorCusto['custo'] / totalGeral * 100);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Resumo Executivo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Métricas principais
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    theme,
                    colorScheme,
                    'Total Investido',
                    _formatarReal(totalGeral),
                    Icons.attach_money,
                    colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    theme,
                    colorScheme,
                    'Itens Analisados',
                    '${_epiData.length}',
                    Icons.inventory_2,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Destaques
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Destaques Estratégicos',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildHighlightItem(
                    '🎯 Maior Investimento',
                    '${maiorCusto['epi']} - ${_formatarReal(maiorCusto['custo'])} (${percentualMaiorCusto.toStringAsFixed(1)}% do total)',
                    colorScheme.primary,
                  ),
                  _buildHighlightItem(
                    '💰 Menor Investimento',
                    '${menorCusto['epi']} - ${_formatarReal(menorCusto['custo'])}',
                    Colors.green,
                  ),
                  _buildHighlightItem(
                    '📊 Total de Itens',
                    '${_epiData.length} tipos de EPI analisados',
                    Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightItem(String title, String value, Color color) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedTable(
    ThemeData theme,
    ColorScheme colorScheme,
    int totalGeral,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Detalhamento por Item',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                dataRowMinHeight: 40,
                dataRowMaxHeight: 60,
                headingRowColor: MaterialStateProperty.all(
                  colorScheme.primaryContainer.withOpacity(0.1),
                ),
                columns: [
                  DataColumn(label: Text('EPI', style: _getHeaderStyle(theme))),
                  DataColumn(
                    label: Text('Custo Total', style: _getHeaderStyle(theme)),
                  ),
                  DataColumn(
                    label: Text('Quantidade', style: _getHeaderStyle(theme)),
                  ),
                  DataColumn(
                    label: Text('Custo Unit.', style: _getHeaderStyle(theme)),
                  ),
                  DataColumn(
                    label: Text('% Unitário', style: _getHeaderStyle(theme)),
                  ),
                  DataColumn(
                    label: Container(
                      width: 50, // largura tabela
                      child: Text('Ações', style: _getHeaderStyle(theme)),
                    ),
                  ),
                ],
                rows: _epiData.map((epi) {
                  final impactoUnitario = _calcularImpactoUnitario(
                    epi['custoUnitario'],
                    totalGeral,
                  );
                  final porcentagemTotal = (epi['custo'] / totalGeral * 100);
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: epi['cor'],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(epi['epi']),
                          ],
                        ),
                      ),
                      DataCell(Text(_formatarReal(epi['custo']))),
                      DataCell(Text(epi['quantidade'].toString())),
                      DataCell(
                        Text(
                          'R\$${epi['custoUnitario'].toStringAsFixed(2).replaceAll('.', ',')}',
                        ),
                      ),
                      DataCell(
                        Tooltip(
                          message:
                              '${porcentagemTotal.toStringAsFixed(1)}% do total',
                          child: Text('${impactoUnitario.toStringAsFixed(2)}%'),
                        ),
                      ),
                      DataCell(
                        Container(
                          width: 50, // LARGURA FIXA MAIOR
                          child: IconButton(
                            icon: Icon(
                              Icons.history,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                            onPressed: () => _showHistoricoCompras(epi['epi']),
                            tooltip: 'Ver histórico de compras',
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== EXPORT PDF - ATUALIZADO ==========
  Future<void> _exportToPdf() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final pdf = pw.Document();
      final totalGeral = _epiData.fold(
        0,
        (sum, epi) => sum + (epi['custo'] as int),
      );

      // PRIMEIRA PÁGINA - RESUMO E DISTRIBUIÇÃO
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: await _getPdfFont()),
          build: (pw.Context context) {
            return [
              _buildPdfHeader(totalGeral),
              pw.SizedBox(height: 20),
              _buildPdfSummaryCards(totalGeral),
              pw.SizedBox(height: 25),
              _buildPdfPorcentagemTotal(totalGeral),
            ];
          },
        ),
      );

      // SEGUNDA PÁGINA - DETALHAMENTO E HISTÓRICO
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: await _getPdfFont()),
          build: (pw.Context context) {
            return [
              _buildPdfDetalhamentoHeader(),
              pw.SizedBox(height: 20),
              _buildPdfTable(totalGeral),
              pw.SizedBox(height: 25),
              _buildPdfHistoricoCompras(),
            ];
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File(
        '${output.path}/relatorio_estrategico_epi_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(file.path);

      _showSnackBar('PDF estratégico exportado com sucesso!', Colors.green);
    } catch (e) {
      _showSnackBar('Erro ao exportar PDF: $e', Colors.red);
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  pw.Widget _buildPdfDetalhamentoHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Detalhamento por Item',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Análise detalhada de custos e quantidades por tipo de EPI',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
  }

  pw.Widget _buildPdfPorcentagemTotal(int totalGeral) {
    final epiComPorcentagem =
        _epiData.map((epi) {
          final porcentagemTotal = (epi['custo'] / totalGeral * 100);
          final impactoUnitario = _calcularImpactoUnitario(
            epi['custoUnitario'],
            totalGeral,
          );
          return {
            ...epi,
            'porcentagemTotal': porcentagemTotal,
            'impactoUnitario': impactoUnitario,
          };
        }).toList()..sort(
          (a, b) => b['porcentagemTotal'].compareTo(a['porcentagemTotal']),
        );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DISTRIBUIÇÃO PERCENTUAL NO ORÇAMENTO',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Text(
          'Participação de cada item no custo total - Para priorização de investimentos',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 16),
        ...epiComPorcentagem.map((epi) {
          return pw.Container(
            margin: pw.EdgeInsets.only(bottom: 8),
            padding: pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey50,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 10,
                  height: 10,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue700,
                    shape: pw.BoxShape.circle,
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        epi['epi'],
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        '${_formatarReal(epi['custo'])} | ${epi['porcentagemTotal'].toStringAsFixed(1)}% do total',
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Impacto unitário: ${epi['impactoUnitario'].toStringAsFixed(2)}%',
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: epi['porcentagemTotal'] > 30
                        ? PdfColors.red
                        : epi['porcentagemTotal'] > 15
                        ? PdfColors.orange
                        : PdfColors.green,
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Text(
                    '${epi['porcentagemTotal'].toStringAsFixed(1)}%',
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  pw.Widget _buildPdfHistoricoCompras() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'HISTÓRICO ESTRATÉGICO DE COMPRAS',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 12),
        ..._dadosHistoricosCompras.map((epiHistorico) {
          final analise = _analisarHistoricoCompras(epiHistorico['epi']);
          return pw.Container(
            margin: pw.EdgeInsets.only(bottom: 16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${epiHistorico['epi']} - Tendência: ${analise['tendencia'].toString().toUpperCase()} (${analise['variacaoPercentual'].toStringAsFixed(1)}%)',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue700,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.TableHelper.fromTextArray(
                  context: null,
                  headers: [
                    'Data',
                    'Fornecedor',
                    'Qtd',
                    'Custo Unit.',
                    'Total',
                  ],
                  data: (epiHistorico['compras'] as List).map((compra) {
                    final total =
                        (compra['quantidade'] as int) *
                        (compra['custoUnitario'] as double);
                    return [
                      compra['data'],
                      compra['fornecedor'],
                      compra['quantidade'].toString(),
                      'R\$${compra['custoUnitario'].toStringAsFixed(2).replaceAll('.', ',')}',
                      'R\$${total.toStringAsFixed(2).replaceAll('.', ',')}',
                    ];
                  }).toList(),
                  border: pw.TableBorder.all(
                    color: PdfColors.grey300,
                    width: 1,
                  ),
                  headerStyle: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: pw.BoxDecoration(color: PdfColors.blue700),
                  cellStyle: pw.TextStyle(fontSize: 7),
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerLeft,
                    2: pw.Alignment.center,
                    3: pw.Alignment.centerRight,
                    4: pw.Alignment.centerRight,
                  },
                ),
                pw.SizedBox(height: 8),
              ],
            ),
          );
        }),
      ],
    );
  }

  pw.Widget _buildPdfHeader(int totalGeral) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      padding: pw.EdgeInsets.all(25),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 4,
            height: 60,
            decoration: pw.BoxDecoration(
              color: PdfColors.blue700,
              borderRadius: pw.BorderRadius.circular(2),
            ),
          ),
          pw.SizedBox(width: 20),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Relatório Estratégico de Custos de EPI',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Análise completa com distribuição percentual e histórico de compras',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Gerado em: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} às ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
                ),
              ],
            ),
          ),
          pw.Container(
            padding: pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue700,
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Text(
              _formatarReal(totalGeral),
              style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfSummaryCards(int totalGeral) {
    final maiorCusto = _epiData.first;
    final porcentagemMaior = (maiorCusto['custo'] / totalGeral * 100);

    return pw.Row(
      children: [
        _buildPdfSummaryCard(
          'Total Investido',
          _formatarReal(totalGeral),
          PdfColors.blue700,
        ),
        pw.SizedBox(width: 12),
        _buildPdfSummaryCard(
          'Itens Analisados',
          '${_epiData.length} tipos',
          PdfColors.green700,
        ),
        pw.SizedBox(width: 12),
        _buildPdfSummaryCard(
          'Maior Custo',
          '${maiorCusto['epi']} (${porcentagemMaior.toStringAsFixed(1)}%)',
          PdfColors.orange700,
        ),
      ],
    );
  }

  pw.Widget _buildPdfSummaryCard(String title, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(10),
          border: pw.Border.all(color: PdfColors.grey300, width: 1),
        ),
        padding: pw.EdgeInsets.all(16),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildPdfTable(int totalGeral) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          context: null,
          headers: [
            'EPI',
            'Custo Total',
            'Quantidade',
            'Custo Unitário',
            '% Unitário',
            '% Total',
          ],
          data: _epiData.map((epi) {
            final impactoUnitario = _calcularImpactoUnitario(
              epi['custoUnitario'],
              totalGeral,
            );
            final porcentagemTotal = (epi['custo'] / totalGeral * 100);
            return [
              epi['epi'],
              _formatarReal(epi['custo']).replaceAll('R\$', '').trim(),
              epi['quantidade'].toString(),
              'R\$${(epi['custoUnitario'] as double).toStringAsFixed(2).replaceAll('.', ',')}',
              '${impactoUnitario.toStringAsFixed(2)}%',
              '${porcentagemTotal.toStringAsFixed(1)}%',
            ];
          }).toList(),
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 10,
            color: PdfColors.white,
          ),
          headerDecoration: pw.BoxDecoration(color: PdfColors.blue700),
          cellStyle: pw.TextStyle(fontSize: 9),
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerRight,
            2: pw.Alignment.center,
            3: pw.Alignment.centerRight,
            4: pw.Alignment.center,
            5: pw.Alignment.center,
          },
        ),
      ],
    );
  }

  Future<pw.Font> _getPdfFont() async {
    return pw.Font.courier();
  }

  // ========== EXPORT EXCEL ATUALIZADO ==========
  Future<void> _exportToExcel() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final totalGeral = _epiData.fold(
        0,
        (sum, epi) => sum + (epi['custo'] as int),
      );
      List<List<dynamic>> csvData = [];

      // Cabecalho SEM ACENTOS
      csvData.add(['RELATORIO ESTRATEGICO DE CUSTOS DE EPI']);
      csvData.add(['Gerado em:', '${DateTime.now().toString().split(' ')[0]}']);
      csvData.add([]);

      // Resumo
      csvData.add(['RESUMO GERAL']);
      csvData.add(['Total Investido:', '${_formatarReal(totalGeral)}']);
      csvData.add(['Quantidade de Itens:', '${_epiData.length} tipos']);
      csvData.add([]);

      // Distribuicao Percentual
      csvData.add(['DISTRIBUICAO PERCENTUAL - ANALISE ESTRATEGICA']);
      csvData.add([
        'EPI',
        'Custo Total (R\$)',
        'Quantidade',
        '% do Total',
        '% Unitario',
        'Classificacao',
      ]);

      for (var epi in _epiData) {
        final porcentagemTotal = (epi['custo'] / totalGeral * 100);
        final impactoUnitario = _calcularImpactoUnitario(
          epi['custoUnitario'],
          totalGeral,
        );
        String classificacao = porcentagemTotal > 30
            ? 'ALTO IMPACTO'
            : porcentagemTotal > 15
            ? 'MEDIO IMPACTO'
            : 'BAIXO IMPACTO';
        csvData.add([
          epi['epi'],
          _formatarReal(epi['custo']).replaceAll('R\$', '').trim(),
          epi['quantidade'].toString(),
          '${porcentagemTotal.toStringAsFixed(1)}%',
          '${impactoUnitario.toStringAsFixed(2)}%',
          classificacao,
        ]);
      }
      csvData.add([]);

      // Tabela detalhada
      csvData.add(['DETALHAMENTO POR ITEM']);
      csvData.add([
        'EPI',
        'Custo Total (R\$)',
        'Quantidade',
        'Custo Unitario (R\$)',
        '% Unitario',
        '% Total',
      ]);

      for (var epi in _epiData) {
        final impactoUnitario = _calcularImpactoUnitario(
          epi['custoUnitario'],
          totalGeral,
        );
        final porcentagemTotal = (epi['custo'] / totalGeral * 100);
        csvData.add([
          epi['epi'],
          _formatarReal(epi['custo']).replaceAll('R\$', '').trim(),
          epi['quantidade'].toString(),
          (epi['custoUnitario'] as double)
              .toStringAsFixed(2)
              .replaceAll('.', ','),
          '${impactoUnitario.toStringAsFixed(2)}%',
          '${porcentagemTotal.toStringAsFixed(1)}%',
        ]);
      }
      csvData.add([]);

      // Historico de Compras
      csvData.add(['HISTORICO ESTRATEGICO DE COMPRAS']);
      for (var historico in _dadosHistoricosCompras) {
        csvData.add(['ITEM: ${historico['epi']}']);
        csvData.add([
          'Data',
          'Fornecedor',
          'Quantidade',
          'Custo Unitario',
          'Total',
        ]);

        for (var compra in historico['compras']) {
          final total =
              (compra['quantidade'] as int) *
              (compra['custoUnitario'] as double);
          csvData.add([
            compra['data'],
            compra['fornecedor'],
            compra['quantidade'],
            compra['custoUnitario'].toStringAsFixed(2).replaceAll('.', ','),
            total.toStringAsFixed(2).replaceAll('.', ','),
          ]);
        }
        csvData.add([]);
      }

      String csv = const ListToCsvConverter().convert(csvData);
      final output = await getTemporaryDirectory();
      final file = File(
        '${output.path}/relatorio_estrategico_epi_${DateTime.now().millisecondsSinceEpoch}.csv',
      );
      await file.writeAsString(csv);

      await OpenFile.open(file.path);

      _showSnackBar(
        'Excel/CSV estratégico exportado com sucesso!',
        Colors.green,
      );
    } catch (e) {
      _showSnackBar('Erro ao exportar Excel: $e', Colors.red);
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  // ========== INTERFACE PRINCIPAL ==========
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _buildMainContent(theme, colorScheme);
  }

  Widget _buildMainContent(ThemeData theme, ColorScheme colorScheme) {
    final totalGeral = _epiData.fold(
      0,
      (sum, epi) => sum + (epi['custo'] as int),
    );
    final double maxCost = 20000;

    return Stack(
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.outlineVariant, width: 1),
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
                          'Análise Estratégica de Custos por EPI',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Distribuição de custos com percentual total e histórico',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: _isExporting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.more_vert_rounded),
                      onPressed: _isExporting ? null : _showMenuActions,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Gráfico de Barras
                SizedBox(
                  height: 320,
                  child: Stack(
                    children: [
                      BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxCost * 1.15,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  if (value >= 0 && value < _epiData.length) {
                                    final epi = _epiData[value.toInt()];
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      space: 4,
                                      child: Text(
                                        epi['epi'],
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
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
                                interval: 5000,
                                getTitlesWidget: (value, meta) {
                                  if (value % 5000 == 0) {
                                    return Text(
                                      _formatarRealCompacta(value.toInt()),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
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
                            horizontalInterval: 5000,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: colorScheme.outlineVariant.withAlpha(50),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: colorScheme.outlineVariant.withAlpha(80),
                              width: 1,
                            ),
                          ),
                          barGroups: _epiData.asMap().entries.map((entry) {
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

                      if (_showValues)
                        Positioned.fill(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final double chartWidth = constraints.maxWidth;
                              final double chartHeight = constraints.maxHeight;
                              final double barWidth = 32.0;
                              final double spaceBetweenBars =
                                  (chartWidth - (_epiData.length * barWidth)) /
                                  (_epiData.length + 1);

                              return Stack(
                                children: _epiData.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final data = entry.value;

                                  final double xPosition =
                                      spaceBetweenBars +
                                      (index * (barWidth + spaceBetweenBars)) +
                                      (barWidth / 2);
                                  final double yPosition =
                                      chartHeight -
                                      ((data['custo'] / maxCost) *
                                          chartHeight *
                                          0.85) -
                                      25;

                                  return Positioned(
                                    left: xPosition - 30,
                                    top: yPosition,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: colorScheme.outlineVariant
                                              .withAlpha(80),
                                        ),
                                      ),
                                      child: Text(
                                        _formatarReal(data['custo']),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
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
                    color: colorScheme.primaryContainer.withAlpha(50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Investido:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatarReal(totalGeral),
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
        ),

        if (_isExporting)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Exportando...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ========== MENU TRADICIONAL ==========
  void _showMenuActions() {
    if (_isExporting) return;

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          value: 'export_pdf',
          child: Row(
            children: [
              _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf, size: 20),
              const SizedBox(width: 8),
              const Text('Exportar para PDF'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'export_excel',
          child: Row(
            children: [
              _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.table_chart, size: 20),
              const SizedBox(width: 8),
              const Text('Exportar para Excel'),
            ],
          ),
        ),
        const PopupMenuItem(enabled: false, child: Divider(height: 1)),
        PopupMenuItem(
          value: 'toggle_values',
          child: Row(
            children: [
              Icon(
                _showValues ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(_showValues ? 'Ocultar Valores' : 'Mostrar Valores'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'sort',
          child: Row(
            children: [
              const Icon(Icons.sort, size: 20),
              const SizedBox(width: 8),
              Text(_sortedByValue ? 'Ordenar por Nome' : 'Ordenar por Valor'),
            ],
          ),
        ),
        const PopupMenuItem(enabled: false, child: Divider(height: 1)),
        PopupMenuItem(
          value: 'analysis',
          child: Row(
            children: [
              const Icon(Icons.analytics, size: 20),
              const SizedBox(width: 8),
              const Text('Análise Estratégica'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        _handleMenuAction(value);
      }
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export_pdf':
        _exportToPdf();
        break;
      case 'export_excel':
        _exportToExcel();
        break;
      case 'toggle_values':
        _toggleValues();
        break;
      case 'sort':
        if (_sortedByValue) {
          _sortDataByName();
        } else {
          _sortDataByValue();
        }
        break;
      case 'analysis':
        _showDetailedAnalysis();
        break;
    }
  }

  // Função para formatar em Real brasileiro COMPLETO
  String _formatarReal(int valor) {
    return 'R\$${valor.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')},00';
  }

  // Função para formatar em Real brasileiro COMPACTO (para gráfico)
  String _formatarRealCompacta(int valor) {
    if (valor >= 1000) {
      return 'R\$${(valor / 1000).toStringAsFixed(0)}k';
    }
    return 'R\$$valor';
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}