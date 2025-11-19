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

class CostPerSectorChart extends StatefulWidget {
  const CostPerSectorChart({super.key});

  @override
  State<CostPerSectorChart> createState() => _CostPerSectorChartState();
}

class _CostPerSectorChartState extends State<CostPerSectorChart> {
  bool _showValues = true;
  bool _sortedByValue = true;
  List<Map<String, dynamic>> _sectorData = [];
  bool _isExporting = false;

  // ========== DADOS DE EVOLUÇÃO MENSAL POR SETOR ==========
  final List<Map<String, dynamic>> _evolucaoMensalSetores = [
    {
      'setor': 'Produção',
      'evolucao': [
        {'mes': 'Jan/2024', 'custo': 26500, 'quantidade': 1050},
        {'mes': 'Fev/2024', 'custo': 27800, 'quantidade': 1100},
        {'mes': 'Mar/2024', 'custo': 28500, 'quantidade': 1130},
      ]
    },
    {
      'setor': 'Manutenção',
      'evolucao': [
        {'mes': 'Jan/2024', 'custo': 14200, 'quantidade': 380},
        {'mes': 'Fev/2024', 'custo': 14900, 'quantidade': 390},
        {'mes': 'Mar/2024', 'custo': 15600, 'quantidade': 400},
      ]
    },
    {
      'setor': 'Logística',
      'evolucao': [
        {'mes': 'Jan/2024', 'custo': 9200, 'quantidade': 580},
        {'mes': 'Fev/2024', 'custo': 9500, 'quantidade': 590},
        {'mes': 'Mar/2024', 'custo': 9800, 'quantidade': 600},
      ]
    },
    {
      'setor': 'Qualidade',
      'evolucao': [
        {'mes': 'Jan/2024', 'custo': 11800, 'quantidade': 240},
        {'mes': 'Fev/2024', 'custo': 12000, 'quantidade': 248},
        {'mes': 'Mar/2024', 'custo': 12300, 'quantidade': 255},
      ]
    },
    {
      'setor': 'Administrativo',
      'evolucao': [
        {'mes': 'Jan/2024', 'custo': 8200, 'quantidade': 185},
        {'mes': 'Fev/2024', 'custo': 8400, 'quantidade': 190},
        {'mes': 'Mar/2024', 'custo': 8700, 'quantidade': 195},
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _sectorData = [
      {
        'setor': 'Produção',
        'custo': 28500,
        'cor': const Color(0xFF2196F3),
        'quantidade': 1130,
      },
      {
        'setor': 'Manutenção',
        'custo': 15600,
        'cor': const Color(0xFF4CAF50),
        'quantidade': 400,
      },
      {
        'setor': 'Logística',
        'custo': 9800,
        'cor': const Color(0xFFFFC107),
        'quantidade': 600,
      },
      {
        'setor': 'Qualidade',
        'custo': 12300,
        'cor': const Color(0xFFFF5722),
        'quantidade': 255,
      },
      {
        'setor': 'Administrativo',
        'custo': 8700,
        'cor': const Color(0xFF9C27B0),
        'quantidade': 195,
      },
    ];
    _sortDataByValue();
  }

  void _sortDataByValue() {
    setState(() {
      _sectorData.sort((a, b) => b['custo'].compareTo(a['custo']));
      _sortedByValue = true;
    });
  }

  void _sortDataByName() {
    setState(() {
      _sectorData.sort((a, b) => a['setor'].compareTo(b['setor']));
      _sortedByValue = false;
    });
  }

  void _toggleValues() {
    setState(() {
      _showValues = !_showValues;
    });
  }

  // ========== ANÁLISE DE EVOLUÇÃO MENSAL ==========
  Map<String, dynamic> _analisarEvolucaoSetor(String setorNome) {
    final evolucao = _evolucaoMensalSetores.firstWhere(
      (item) => item['setor'] == setorNome,
      orElse: () => {'evolucao': []},
    );

    final dadosEvolucao = List<Map<String, dynamic>>.from(evolucao['evolucao']);
    if (dadosEvolucao.isEmpty) {
      return {
        'tendencia': 'estavel',
        'variacaoPercentual': 0.0,
        'custoAtual': 0,
        'custoAnterior': 0,
        'crescimentoQuantidade': 0,
      };
    }

    final custos = dadosEvolucao.map((c) => c['custo'] as int).toList();
    final quantidades = dadosEvolucao.map((c) => c['quantidade'] as int).toList();
    
    final custoAtual = custos.last;
    final custoAnterior = custos.first;
    final variacaoPercentual = ((custoAtual - custoAnterior) / custoAnterior) * 100;
    
    final crescimentoQuantidade = quantidades.last - quantidades.first;

    // Determinar tendência
    String tendencia;
    if (variacaoPercentual > 5) {
      tendencia = 'alta';
    } else if (variacaoPercentual < -5) {
      tendencia = 'baixa';
    } else {
      tendencia = 'estavel';
    }

    return {
      'tendencia': tendencia,
      'variacaoPercentual': variacaoPercentual,
      'custoAtual': custoAtual,
      'custoAnterior': custoAnterior,
      'crescimentoQuantidade': crescimentoQuantidade,
      'evolucao': dadosEvolucao,
    };
  }

  // ========== MODAL DE EVOLUÇÃO MENSAL ==========
  void _showEvolucaoSetor(String setorNome) {
    final analise = _analisarEvolucaoSetor(setorNome);
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up, color: colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Evolução Mensal - $setorNome',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Análise temporal dos custos nos últimos 3 meses',
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
                    // Card de Insights
                    _buildInsightsCard(theme, colorScheme, analise),
                    const SizedBox(height: 24),

                    // Tabela de Evolução
                    _buildEvolucaoTable(theme, colorScheme, analise['evolucao']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard(ThemeData theme, ColorScheme colorScheme, Map<String, dynamic> analise) {
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
              '📈 Análise da Evolução',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                  'Variação 3 meses',
                  '${analise['variacaoPercentual'].toStringAsFixed(1)}%',
                  tendenciaColor,
                  theme,
                ),
                _buildInsightChip(
                  'Crescimento EPIs',
                  '+${analise['crescimentoQuantidade']} unidades',
                  Colors.orange,
                  theme,
                ),
                _buildInsightChip(
                  'Custo Atual',
                  _formatarReal(analise['custoAtual']),
                  Colors.blue,
                  theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightChip(String label, String value, Color color, ThemeData theme) {
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

  Widget _buildEvolucaoTable(ThemeData theme, ColorScheme colorScheme, List<dynamic> evolucao) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 Evolução dos Últimos 3 Meses',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                  DataColumn(label: Text('Mês', style: _getHeaderStyle(theme))),
                  DataColumn(label: Text('Custo Total', style: _getHeaderStyle(theme))),
                  DataColumn(label: Text('Quantidade', style: _getHeaderStyle(theme))),
                ],
                rows: evolucao.map((mes) {
                  return DataRow(
                    cells: [
                      DataCell(Text(mes['mes'])),
                      DataCell(Text(_formatarReal(mes['custo']))),
                      DataCell(Text(mes['quantidade'].toString())),
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
    ) ?? const TextStyle();
  }

  // ========== ANÁLISE DETALHADA COMPLETA ==========
  void _showDetailedAnalysis() {
    final totalGeral = _sectorData.fold(0, (sum, setor) => sum + (setor['custo'] as int));
    
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Análise Estratégica - Custos por Setor',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Visão completa com distribuição percentual e evolução mensal',
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

  Widget _buildPorcentagemTotalCard(ThemeData theme, ColorScheme colorScheme, int totalGeral) {
    // Ordenar por porcentagem total (maior primeiro)
    final setoresComPorcentagem = _sectorData.map((setor) {
      final porcentagemTotal = (setor['custo'] / totalGeral * 100);
      return {...setor, 'porcentagemTotal': porcentagemTotal};
    }).toList()
      ..sort((a, b) => b['porcentagemTotal'].compareTo(a['porcentagemTotal']));

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
              'Participação de cada setor no custo total - Para alocação estratégica de recursos',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ...setoresComPorcentagem.map((setor) {
              return _buildPorcentagemTotalRow(
                setor['setor'],
                setor['custo'],
                setor['porcentagemTotal'],
                setor['quantidade'],
                setor['cor'],
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
    String setor, 
    int custoTotal, 
    double porcentagemTotal,
    int quantidade,
    Color cor, 
    ThemeData theme, 
    ColorScheme colorScheme
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
                  setor,
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
                  '$quantidade EPIs utilizados',
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

  Widget _buildEnhancedSummaryCard(ThemeData theme, ColorScheme colorScheme, int totalGeral) {
    final maiorCusto = _sectorData.first;
    final menorCusto = _sectorData.last;
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
                    'Custo Total Mensal',
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
                    'Setores Analisados',
                    '${_sectorData.length}',
                    Icons.business,
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
                    '🎯 Maior Custo',
                    '${maiorCusto['setor']} - ${_formatarReal(maiorCusto['custo'])} (${percentualMaiorCusto.toStringAsFixed(1)}% do total)',
                    colorScheme.primary,
                  ),
                  _buildHighlightItem(
                    '💰 Menor Custo',
                    '${menorCusto['setor']} - ${_formatarReal(menorCusto['custo'])}',
                    Colors.green,
                  ),
                  _buildHighlightItem(
                    '📊 Total de EPIs',
                    '${_sectorData.fold(0, (sum, setor) => sum + (setor['quantidade'] as int))} unidades',
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

  Widget _buildDetailedTable(ThemeData theme, ColorScheme colorScheme, int totalGeral) {
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
                  DataColumn(label: Text('Setor', style: _getHeaderStyle(theme))),
                  DataColumn(label: Text('Custo Total', style: _getHeaderStyle(theme))),
                  DataColumn(label: Text('Quantidade', style: _getHeaderStyle(theme))),
                  DataColumn(label: Text('% do Total', style: _getHeaderStyle(theme))),
                  DataColumn(
                    label: Container(
                      width: 50,
                      child: Text('Ações', style: _getHeaderStyle(theme)),
                    ),
                  ),
                ],
                rows: _sectorData.map((setor) {
                  final porcentagemTotal = (setor['custo'] / totalGeral * 100);
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: setor['cor'],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(setor['setor']),
                          ],
                        ),
                      ),
                      DataCell(Text(_formatarReal(setor['custo']))),
                      DataCell(Text(setor['quantidade'].toString())),
                      DataCell(Text('${porcentagemTotal.toStringAsFixed(1)}%')),
                      DataCell(
                        Container(
                          width: 50,
                          child: IconButton(
                            icon: Icon(Icons.trending_up, size: 20, color: colorScheme.primary),
                            onPressed: () => _showEvolucaoSetor(setor['setor']),
                            tooltip: 'Ver evolução mensal',
                            padding: EdgeInsets.zero,
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

  // ========== EXPORT PDF ==========
  Future<void> _exportToPdf() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final pdf = pw.Document();
      final totalGeral = _sectorData.fold(0, (sum, setor) => sum + (setor['custo'] as int));

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

      // SEGUNDA PÁGINA - DETALHAMENTO E EVOLUÇÃO
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
              _buildPdfEvolucaoMensal(),
            ];
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/relatorio_setores_epi_${DateTime.now().millisecondsSinceEpoch}.pdf');
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
          'Detalhamento por Setor',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Análise detalhada de custos e quantidades por área da empresa',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
  }

  pw.Widget _buildPdfPorcentagemTotal(int totalGeral) {
    final setoresComPorcentagem = _sectorData.map((setor) {
      final porcentagemTotal = (setor['custo'] / totalGeral * 100);
      return {...setor, 'porcentagemTotal': porcentagemTotal};
    }).toList()
      ..sort((a, b) => b['porcentagemTotal'].compareTo(a['porcentagemTotal']));

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
          'Participação de cada setor no custo total - Para alocação estratégica de recursos',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 16),
        ...setoresComPorcentagem.map((setor) {
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
                        setor['setor'],
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        '${_formatarReal(setor['custo'])} | ${setor['porcentagemTotal'].toStringAsFixed(1)}% do total',
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        '${setor['quantidade']} EPIs utilizados',
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
                    color: setor['porcentagemTotal'] > 30 ? PdfColors.red : 
                           setor['porcentagemTotal'] > 15 ? PdfColors.orange : PdfColors.green,
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Text(
                    '${setor['porcentagemTotal'].toStringAsFixed(1)}%',
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

  pw.Widget _buildPdfEvolucaoMensal() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'EVOLUÇÃO MENSAL POR SETOR',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 12),
        ..._evolucaoMensalSetores.map((setorEvolucao) {
          final analise = _analisarEvolucaoSetor(setorEvolucao['setor']);
          return pw.Container(
            margin: pw.EdgeInsets.only(bottom: 16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${setorEvolucao['setor']} - Tendência: ${analise['tendencia'].toString().toUpperCase()} (${analise['variacaoPercentual'].toStringAsFixed(1)}%)',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue700,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.TableHelper.fromTextArray(
                  context: null,
                  headers: ['Mês', 'Custo Total', 'Quantidade'],
                  data: (setorEvolucao['evolucao'] as List).map((mes) {
                    return [
                      mes['mes'],
                      _formatarReal(mes['custo']).replaceAll('R\$', '').trim(),
                      mes['quantidade'].toString(),
                    ];
                  }).toList(),
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
                  headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: pw.BoxDecoration(color: PdfColors.blue700),
                  cellStyle: pw.TextStyle(fontSize: 7),
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerRight,
                    2: pw.Alignment.center,
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
                  'Relatório Estratégico - Custos por Setor',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Análise completa da distribuição de custos de EPI por área da empresa',
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
    final maiorCusto = _sectorData.first;
    final porcentagemMaior = (maiorCusto['custo'] / totalGeral * 100);

    return pw.Row(
      children: [
        _buildPdfSummaryCard(
          'Custo Total Mensal',
          _formatarReal(totalGeral),
          PdfColors.blue700,
        ),
        pw.SizedBox(width: 12),
        _buildPdfSummaryCard(
          'Setores Analisados',
          '${_sectorData.length} áreas',
          PdfColors.green700,
        ),
        pw.SizedBox(width: 12),
        _buildPdfSummaryCard(
          'Maior Custo',
          '${maiorCusto['setor']} (${porcentagemMaior.toStringAsFixed(1)}%)',
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
          headers: ['Setor', 'Custo Total', 'Quantidade', '% do Total'],
          data: _sectorData.map((setor) {
            final porcentagemTotal = (setor['custo'] / totalGeral * 100);
            return [
              setor['setor'],
              _formatarReal(setor['custo']).replaceAll('R\$', '').trim(),
              setor['quantidade'].toString(),
              '${porcentagemTotal.toStringAsFixed(1)}%',
            ];
          }).toList(),
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.white),
          headerDecoration: pw.BoxDecoration(color: PdfColors.blue700),
          cellStyle: pw.TextStyle(fontSize: 9),
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerRight,
            2: pw.Alignment.center,
            3: pw.Alignment.center,
          },
        ),
      ],
    );
  }

  Future<pw.Font> _getPdfFont() async {
    return pw.Font.courier();
  }

  // ========== EXPORT EXCEL ==========
  Future<void> _exportToExcel() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final totalGeral = _sectorData.fold(0, (sum, setor) => sum + (setor['custo'] as int));
      List<List<dynamic>> csvData = [];

      // Cabecalho SEM ACENTOS
      csvData.add(['RELATORIO ESTRATEGICO - CUSTOS POR SETOR']);
      csvData.add(['Gerado em:', '${DateTime.now().toString().split(' ')[0]}']);
      csvData.add([]);

      // Resumo
      csvData.add(['RESUMO GERAL']);
      csvData.add(['Custo Total Mensal:', '${_formatarReal(totalGeral)}']);
      csvData.add(['Setores Analisados:', '${_sectorData.length} areas']);
      csvData.add(['Total de EPIs:', '${_sectorData.fold(0, (sum, setor) => sum + (setor['quantidade'] as int))} unidades']);
      csvData.add([]);

      // Distribuicao Percentual
      csvData.add(['DISTRIBUICAO PERCENTUAL - ANALISE ESTRATEGICA']);
      csvData.add(['Setor', 'Custo Total (R\$)', 'Quantidade', '% do Total', 'Classificacao']);
      
      for (var setor in _sectorData) {
        final porcentagemTotal = (setor['custo'] / totalGeral * 100);
        String classificacao = porcentagemTotal > 30 ? 'ALTO CUSTO' : porcentagemTotal > 15 ? 'MEDIO CUSTO' : 'BAIXO CUSTO';
        csvData.add([
          setor['setor'],
          _formatarReal(setor['custo']).replaceAll('R\$', '').trim(),
          setor['quantidade'].toString(),
          '${porcentagemTotal.toStringAsFixed(1)}%',
          classificacao,
        ]);
      }
      csvData.add([]);

      // Tabela detalhada
      csvData.add(['DETALHAMENTO POR SETOR']);
      csvData.add(['Setor', 'Custo Total (R\$)', 'Quantidade', '% do Total']);

      for (var setor in _sectorData) {
        final porcentagemTotal = (setor['custo'] / totalGeral * 100);
        csvData.add([
          setor['setor'],
          _formatarReal(setor['custo']).replaceAll('R\$', '').trim(),
          setor['quantidade'].toString(),
          '${porcentagemTotal.toStringAsFixed(1)}%',
        ]);
      }
      csvData.add([]);

      // Evolucao Mensal
      csvData.add(['EVOLUCAO MENSAL POR SETOR']);
      for (var evolucao in _evolucaoMensalSetores) {
        final analise = _analisarEvolucaoSetor(evolucao['setor']);
        csvData.add(['SETOR: ${evolucao['setor']} - Tendencia: ${analise['tendencia'].toString().toUpperCase()} (${analise['variacaoPercentual'].toStringAsFixed(1)}%)']);
        csvData.add(['Mes', 'Custo Total (R\$)', 'Quantidade']);
        
        for (var mes in evolucao['evolucao']) {
          csvData.add([
            mes['mes'],
            _formatarReal(mes['custo']).replaceAll('R\$', '').trim(),
            mes['quantidade'].toString(),
          ]);
        }
        csvData.add([]);
      }

      String csv = const ListToCsvConverter().convert(csvData);
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/relatorio_setores_epi_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv);

      await OpenFile.open(file.path);

      _showSnackBar('Excel/CSV estratégico exportado com sucesso!', Colors.green);
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
    final totalGeral = _sectorData.fold(0, (sum, setor) => sum + (setor['custo'] as int));
    final double maxCost = 30000;

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
                          'Custos de EPI por Setor',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Distribuição mensal por área da empresa',
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
                      // Gráfico principal
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
                                  if (value >= 0 && value < _sectorData.length) {
                                    final setor = _sectorData[value.toInt()];
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
                                      _formatarRealCompacta(value.toInt()),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    );
                                  }
                                  return const Text('');
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
                            horizontalInterval: 10000,
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
                          barGroups: _sectorData.asMap().entries.map((entry) {
                            final index = entry.key;
                            final data = entry.value;
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: data['custo'].toDouble(),
                                  color: data['cor'],
                                  width: 32,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
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
                              final double spaceBetweenBars = (chartWidth - (_sectorData.length * barWidth)) / (_sectorData.length + 1);

                              return Stack(
                                children: _sectorData.asMap().entries.map((entry) {
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
                                        border: Border.all(color: colorScheme.outlineVariant.withAlpha(80)),
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
                    color: colorScheme.primaryContainer.withAlpha(50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Custo Total Mensal:',
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
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
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
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
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
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
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
              Icon(_showValues ? Icons.visibility_off : Icons.visibility, size: 20),
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
    return 'R\$${valor.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )},00';
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