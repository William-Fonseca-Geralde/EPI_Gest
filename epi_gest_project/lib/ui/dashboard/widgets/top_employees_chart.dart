import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'dart:convert';

class TopEmployeesChart extends StatefulWidget {
  const TopEmployeesChart({super.key});

  @override
  State<TopEmployeesChart> createState() => _TopEmployeesChartState();
}

class _TopEmployeesChartState extends State<TopEmployeesChart> {
  bool _showValues = true;
  bool _sortedByTrocas = true;
  List<Map<String, dynamic>> _employeesData = [];
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _employeesData = [
      {
        'posicao': 1,
        'nome': 'Carlos Silva',
        'trocas': 18,
        'valor': 2845.00,
        'ultimaTroca': '15/08/2023',
        'cargo': 'Soldador',
        'cor': Colors.blue,
        'setor': 'Produção',
        'trocasNaoNaturais': 12,
        'percentualNaoNatural': 67,
      },
      {
        'posicao': 2,
        'nome': 'Ana Oliveira',
        'trocas': 12,
        'valor': 1920.00,
        'ultimaTroca': '20/08/2023',
        'cargo': 'Operadora',
        'cor': Colors.green,
        'setor': 'Produção',
        'trocasNaoNaturais': 8,
        'percentualNaoNatural': 67,
      },
      {
        'posicao': 3,
        'nome': 'Roberto Santos',
        'trocas': 9,
        'valor': 1575.00,
        'ultimaTroca': '22/08/2023',
        'cargo': 'Eletricista',
        'cor': Colors.orange,
        'setor': 'Manutenção',
        'trocasNaoNaturais': 6,
        'percentualNaoNatural': 67,
      },
      {
        'posicao': 4,
        'nome': 'Maria Costa',
        'trocas': 8,
        'valor': 1420.00,
        'ultimaTroca': '18/08/2023',
        'cargo': 'Auxiliar',
        'cor': Colors.purple,
        'setor': 'Logística',
        'trocasNaoNaturais': 2,
        'percentualNaoNatural': 25,
      },
      {
        'posicao': 5,
        'nome': 'João Pereira',
        'trocas': 7,
        'valor': 1350.00,
        'ultimaTroca': '25/08/2023',
        'cargo': 'Mecânico',
        'cor': Colors.red,
        'setor': 'Manutenção',
        'trocasNaoNaturais': 3,
        'percentualNaoNatural': 43,
      },
    ];
    _sortDataByTrocas();
  }

  void _sortDataByTrocas() {
    setState(() {
      _employeesData.sort((a, b) => b['trocas'].compareTo(a['trocas']));
      _sortedByTrocas = true;
      _updatePositions();
    });
  }

  void _sortDataByNaoNaturais() {
    setState(() {
      _employeesData.sort(
        (a, b) => b['trocasNaoNaturais'].compareTo(a['trocasNaoNaturais']),
      );
      _sortedByTrocas = false;
      _updatePositions();
    });
  }

  void _updatePositions() {
    for (int i = 0; i < _employeesData.length; i++) {
      _employeesData[i]['posicao'] = i + 1;
    }
  }

  // ========== ANÁLISE DETALHADA ==========
  void _showDetailedAnalysis() {
    final totalTrocas = _employeesData.fold(
      0,
      (sum, emp) => sum + (emp['trocas'] as int),
    );
    final totalValor = _employeesData.fold<double>(
      0,
      (sum, emp) => sum + (emp['valor'] as double),
    );
    final totalNaoNaturais = _employeesData.fold(
      0,
      (sum, emp) => sum + (emp['trocasNaoNaturais'] as int),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _buildAnalysisSheet(totalTrocas, totalValor, totalNaoNaturais),
    );
  }

  Widget _buildAnalysisSheet(
    int totalTrocas,
    double totalValor,
    int totalNaoNaturais,
  ) {
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
                        'Análise Estratégica - Top Colaboradores',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Visão completa com foco em trocas não naturais',
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
                  _buildEnhancedSummaryCard(
                    theme,
                    colorScheme,
                    totalTrocas,
                    totalValor,
                    totalNaoNaturais,
                  ),

                  const SizedBox(height: 24),

                  // Análise de Trocas Não Naturais
                  _buildNaoNaturaisAnalysisCard(theme, colorScheme),

                  const SizedBox(height: 24),

                  // Tabela Detalhada
                  _buildDetailedTable(theme, colorScheme, totalTrocas),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNaoNaturaisAnalysisCard(
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final colaboradoresComAltaNaoNatural = _employeesData
        .where((emp) => emp['percentualNaoNatural'] > 50)
        .toList();
    final percentualTotalNaoNatural =
        (_employeesData.fold(
          0,
          (sum, emp) => sum + (emp['trocasNaoNaturais'] as int),
        ) /
        _employeesData.fold(0, (sum, emp) => sum + (emp['trocas'] as int)) *
        100);

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
                  '🚨 Análise de Trocas Não Naturais',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Trocas por desgaste excessivo, perda, avaria ou outros motivos não programados',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Métricas principais
            Row(
              children: [
                Expanded(
                  child: _buildAnalysisMetric(
                    'Total Não Naturais',
                    '${_employeesData.fold(0, (sum, emp) => sum + (emp['trocasNaoNaturais'] as int))}',
                    'trocas',
                    Colors.orange,
                    theme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAnalysisMetric(
                    'Percentual Geral',
                    '${percentualTotalNaoNatural.toStringAsFixed(1)}%',
                    'do total',
                    Colors.red,
                    theme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Colaboradores com alerta
            if (colaboradoresComAltaNaoNatural.isNotEmpty) ...[
              Text(
                'Colaboradores com Alto Índice (>50%):',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              ...colaboradoresComAltaNaoNatural.map((emp) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${emp['nome']} - ${emp['percentualNaoNatural']}% (${emp['trocasNaoNaturais']} trocas)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisMetric(
    String title,
    String value,
    String subtitle,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSummaryCard(
    ThemeData theme,
    ColorScheme colorScheme,
    int totalTrocas,
    double totalValor,
    int totalNaoNaturais,
  ) {
    final maiorTrocas = _employeesData.first;
    final mediaTrocas = totalTrocas / _employeesData.length;

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
                    'Total de Trocas',
                    totalTrocas.toString(),
                    Icons.swap_horiz,
                    colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    theme,
                    colorScheme,
                    'Trocas Não Naturais',
                    totalNaoNaturais.toString(),
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    theme,
                    colorScheme,
                    'Valor Total',
                    _formatarReal(totalValor),
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
              ],
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

  Widget _buildDetailedTable(
    ThemeData theme,
    ColorScheme colorScheme,
    int totalTrocas,
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
                  'Detalhamento por Colaborador',
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
                  DataColumn(label: Text('Pos', style: _getHeaderStyle(theme))),
                  DataColumn(
                    label: Text('Colaborador', style: _getHeaderStyle(theme)),
                  ),
                  DataColumn(
                    label: Text('Trocas', style: _getHeaderStyle(theme)),
                  ),
                  DataColumn(
                    label: Text('Valor', style: _getHeaderStyle(theme)),
                  ),
                  DataColumn(
                    label: Text('Não Naturais', style: _getHeaderStyle(theme)),
                  ),
                  DataColumn(label: Text('%', style: _getHeaderStyle(theme))),
                ],
                rows: _employeesData.map((emp) {
                  final percentualTrocas = (emp['trocas'] / totalTrocas * 100);
                  final alertaNaoNatural = emp['percentualNaoNatural'] > 50;

                  return DataRow(
                    cells: [
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: emp['cor'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: emp['cor'].withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            '${emp['posicao']}º',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: emp['cor'],
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              emp['nome'],
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${emp['cargo']} - ${emp['setor']}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              emp['trocas'].toString(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                            Text(
                              '${percentualTrocas.toStringAsFixed(1)}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(Text(_formatarReal(emp['valor']))),
                      DataCell(
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              emp['trocasNaoNaturais'].toString(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: alertaNaoNatural
                                    ? Colors.orange
                                    : colorScheme.onSurface,
                              ),
                            ),
                            if (alertaNaoNatural) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.warning,
                                size: 16,
                                color: Colors.orange,
                              ),
                            ],
                          ],
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: alertaNaoNatural
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: alertaNaoNatural
                                  ? Colors.orange.withOpacity(0.3)
                                  : Colors.green.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            '${emp['percentualNaoNatural']}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: alertaNaoNatural
                                  ? Colors.orange
                                  : Colors.green,
                              fontSize: 12,
                            ),
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
      final totalTrocas = _employeesData.fold(
        0,
        (sum, emp) => sum + (emp['trocas'] as int),
      );
      final totalValor = _employeesData.fold<double>(
        0,
        (sum, emp) => sum + (emp['valor'] as double),
      );
      final totalNaoNaturais = _employeesData.fold(
        0,
        (sum, emp) => sum + (emp['trocasNaoNaturais'] as int),
      );

      // PRIMEIRA PÁGINA - RESUMO E ANÁLISE
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: await _getPdfFont()),
          build: (pw.Context context) {
            return [
              _buildPdfHeader(totalTrocas, totalValor, totalNaoNaturais),
              pw.SizedBox(height: 20),
              _buildPdfSummaryCards(totalTrocas, totalValor, totalNaoNaturais),
              pw.SizedBox(height: 25),
              _buildPdfNaoNaturaisAnalysis(),
            ];
          },
        ),
      );

      // SEGUNDA PÁGINA - DETALHAMENTO
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: await _getPdfFont()),
          build: (pw.Context context) {
            return [
              _buildPdfDetalhamentoHeader(),
              pw.SizedBox(height: 20),
              _buildPdfTable(totalTrocas),
            ];
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File(
        '${output.path}/relatorio_colaboradores_epi_${DateTime.now().millisecondsSinceEpoch}.pdf',
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

  pw.Widget _buildPdfHeader(
    int totalTrocas,
    double totalValor,
    int totalNaoNaturais,
  ) {
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
                  'Relatório Estratégico - Top Colaboradores',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Análise completa das trocas de EPI com foco em trocas não naturais',
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
              '$totalTrocas trocas',
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

  pw.Widget _buildPdfSummaryCards(
    int totalTrocas,
    double totalValor,
    int totalNaoNaturais,
  ) {
    final maiorTrocas = _employeesData.first;
    final percentualTotalNaoNatural = (totalNaoNaturais / totalTrocas * 100);

    return pw.Row(
      children: [
        _buildPdfSummaryCard(
          'Total de Trocas',
          totalTrocas.toString(),
          PdfColors.blue700,
        ),
        pw.SizedBox(width: 12),
        _buildPdfSummaryCard(
          'Trocas Não Naturais',
          '$totalNaoNaturais (${percentualTotalNaoNatural.toStringAsFixed(1)}%)',
          PdfColors.orange700,
        ),
        pw.SizedBox(width: 12),
        _buildPdfSummaryCard(
          'Valor Total',
          _formatarReal(totalValor).replaceAll('R\$', '').trim(),
          PdfColors.green700,
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

  pw.Widget _buildPdfNaoNaturaisAnalysis() {
    final colaboradoresComAltaNaoNatural = _employeesData
        .where((emp) => emp['percentualNaoNatural'] > 50)
        .toList();
    final percentualTotalNaoNatural =
        (_employeesData.fold(
          0,
          (sum, emp) => sum + (emp['trocasNaoNaturais'] as int),
        ) /
        _employeesData.fold(0, (sum, emp) => sum + (emp['trocas'] as int)) *
        100);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'ANÁLISE DE TROCAS NÃO NATURAIS',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Text(
          'Trocas por desgaste excessivo, perda, avaria ou outros motivos não programados',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 16),

        // Métricas principais
        pw.Row(
          children: [
            _buildPdfAnalysisMetric(
              'Total Não Naturais',
              '${_employeesData.fold(0, (sum, emp) => sum + (emp['trocasNaoNaturais'] as int))}',
              'trocas',
              PdfColors.orange700,
            ),
            pw.SizedBox(width: 12),
            _buildPdfAnalysisMetric(
              'Percentual Geral',
              '${percentualTotalNaoNatural.toStringAsFixed(1)}%',
              'do total',
              PdfColors.red700,
            ),
          ],
        ),

        if (colaboradoresComAltaNaoNatural.isNotEmpty) ...[
          pw.SizedBox(height: 16),
          pw.Text(
            'Colaboradores com Alto Índice de Trocas Não Naturais (>50%):',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 8),
          ...colaboradoresComAltaNaoNatural.map((emp) {
            return pw.Container(
              margin: pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 6,
                    height: 6,
                    margin: pw.EdgeInsets.only(right: 8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.red700,
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      '${emp['nome']} - ${emp['percentualNaoNatural']}% (${emp['trocasNaoNaturais']} trocas não naturais)',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  pw.Widget _buildPdfAnalysisMetric(
    String title,
    String value,
    String subtitle,
    PdfColor color,
  ) {
    // Converter PdfColor para cor com opacidade manualmente
    final PdfColor lightColor = PdfColor.fromInt(
      (color.red * 0.1).toInt() * 0x1000000 +
          (color.green * 0.1).toInt() * 0x10000 +
          (color.blue * 0.1).toInt() * 0x100,
    );

    final PdfColor borderColor = PdfColor.fromInt(
      (color.red * 0.3).toInt() * 0x1000000 +
          (color.green * 0.3).toInt() * 0x10000 +
          (color.blue * 0.3).toInt() * 0x100,
    );

    return pw.Expanded(
      child: pw.Container(
        decoration: pw.BoxDecoration(
          color: lightColor,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: borderColor),
        ),
        padding: pw.EdgeInsets.all(12),
        child: pw.Column(
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
            pw.Text(
              subtitle,
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
          ],
        ),
      ),
    );
  }
  pw.Widget _buildPdfDetalhamentoHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Detalhamento por Colaborador',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Análise detalhada de trocas, valores e indicadores de uso não natural',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
  }

  pw.Widget _buildPdfTable(int totalTrocas) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          context: null,
          headers: [
            'Pos',
            'Colaborador',
            'Cargo',
            'Setor',
            'Trocas',
            '% Total',
            'Valor (R\$)',
            'Não Naturais',
            '% Não Natural',
          ],
          data: _employeesData.map((emp) {
            final percentualTrocas = (emp['trocas'] / totalTrocas * 100);
            final alertaNaoNatural = emp['percentualNaoNatural'] > 50;

            return [
              '${emp['posicao']}º',
              emp['nome'],
              emp['cargo'],
              emp['setor'],
              emp['trocas'].toString(),
              '${percentualTrocas.toStringAsFixed(1)}%',
              _formatarReal(emp['valor']).replaceAll('R\$', '').trim(),
              '${emp['trocasNaoNaturais']}${alertaNaoNatural ? ' ⚠️' : ''}',
              '${emp['percentualNaoNatural']}%',
            ];
          }).toList(),
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 9,
            color: PdfColors.white,
          ),
          headerDecoration: pw.BoxDecoration(color: PdfColors.blue700),
          cellStyle: pw.TextStyle(fontSize: 8),
          cellAlignments: {
            0: pw.Alignment.center,
            1: pw.Alignment.centerLeft,
            2: pw.Alignment.centerLeft,
            3: pw.Alignment.centerLeft,
            4: pw.Alignment.center,
            5: pw.Alignment.center,
            6: pw.Alignment.centerRight,
            7: pw.Alignment.center,
            8: pw.Alignment.center,
          },
        ),
      ],
    );
  }

  // ========== EXPORT EXCEL ==========
  Future<void> _exportToExcel() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final totalTrocas = _employeesData.fold(
        0,
        (sum, emp) => sum + (emp['trocas'] as int),
      );
      final totalValor = _employeesData.fold<double>(
        0,
        (sum, emp) => sum + (emp['valor'] as double),
      );
      final totalNaoNaturais = _employeesData.fold(
        0,
        (sum, emp) => sum + (emp['trocasNaoNaturais'] as int),
      );

      List<List<dynamic>> csvData = [];

      // Cabeçalho
      csvData.add(['RELATORIO ESTRATEGICO - TOP COLABORADORES']);
      csvData.add(['Gerado em:', '${DateTime.now().toString().split(' ')[0]}']);
      csvData.add([]);

      // Resumo
      csvData.add(['RESUMO GERAL']);
      csvData.add(['Total de Trocas:', totalTrocas.toString()]);
      csvData.add([
        'Trocas Não Naturais:',
        '$totalNaoNaturais (${(totalNaoNaturais / totalTrocas * 100).toStringAsFixed(1)}%)',
      ]);
      csvData.add(['Valor Total:', _formatarReal(totalValor)]);
      csvData.add(['Colaboradores Analisados:', '${_employeesData.length}']);
      csvData.add([
        'Media de Trocas por Colaborador:',
        '${(totalTrocas / _employeesData.length).toStringAsFixed(1)}',
      ]);
      csvData.add([]);

      // Análise de Trocas Não Naturais
      csvData.add(['ANALISE DE TROCAS NAO NATURAIS']);
      csvData.add([
        'Colaboradores com alto indice (>50%)',
        'Percentual',
        'Trocas Não Naturais',
      ]);

      final colaboradoresComAltaNaoNatural = _employeesData
          .where((emp) => emp['percentualNaoNatural'] > 50)
          .toList();
      if (colaboradoresComAltaNaoNatural.isNotEmpty) {
        for (var emp in colaboradoresComAltaNaoNatural) {
          csvData.add([
            emp['nome'],
            '${emp['percentualNaoNatural']}%',
            emp['trocasNaoNaturais'].toString(),
          ]);
        }
      } else {
        csvData.add(['Nenhum colaborador com indice elevado', '-', '-']);
      }

      csvData.add([]);

      // Detalhamento por Colaborador
      csvData.add(['DETALHAMENTO POR COLABORADOR']);
      csvData.add([
        'Posicao',
        'Nome',
        'Cargo',
        'Setor',
        'Total Trocas',
        '% do Total',
        'Valor (R\$)',
        'Trocas Não Naturais',
        '% Não Natural',
        'Status',
      ]);

      for (var emp in _employeesData) {
        final percentualTrocas = (emp['trocas'] / totalTrocas * 100);
        final status = emp['percentualNaoNatural'] > 50
            ? 'ALTO INDICE'
            : 'NORMAL';

        csvData.add([
          '${emp['posicao']}º',
          emp['nome'],
          emp['cargo'],
          emp['setor'],
          emp['trocas'].toString(),
          '${percentualTrocas.toStringAsFixed(1)}%',
          _formatarReal(emp['valor']).replaceAll('R\$', '').trim(),
          emp['trocasNaoNaturais'].toString(),
          '${emp['percentualNaoNatural']}%',
          status,
        ]);
      }

      String csv = const ListToCsvConverter().convert(csvData);
      final output = await getTemporaryDirectory();
      final file = File(
        '${output.path}/relatorio_colaboradores_epi_${DateTime.now().millisecondsSinceEpoch}.csv',
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

  Future<pw.Font> _getPdfFont() async {
    return pw.Font.courier();
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
          value: 'analysis',
          child: Row(
            children: [
              const Icon(Icons.analytics, size: 20),
              const SizedBox(width: 8),
              const Text('Análise Estratégica'),
            ],
          ),
        ),
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
          value: 'sort_trocas',
          child: Row(
            children: [
              const Icon(Icons.sort, size: 20),
              const SizedBox(width: 8),
              const Text('Ordenar por Trocas'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'sort_nao_naturais',
          child: Row(
            children: [
              const Icon(Icons.warning, size: 20),
              const SizedBox(width: 8),
              const Text('Ordenar por Não Naturais'),
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
      case 'analysis':
        _showDetailedAnalysis();
        break;
      case 'export_pdf':
        _exportToPdf();
        break;
      case 'export_excel':
        _exportToExcel();
        break;
      case 'sort_trocas':
        _sortDataByTrocas();
        break;
      case 'sort_nao_naturais':
        _sortDataByNaoNaturais();
        break;
    }
  }

  // ========== INTERFACE PRINCIPAL ==========
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalTrocas = _employeesData.fold(
      0,
      (sum, emp) => sum + (emp['trocas'] as int),
    );
    final totalValor = _employeesData.fold<double>(
      0,
      (sum, emp) => sum + (emp['valor'] as double),
    );

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

                const SizedBox(height: 24),

                // Tabela Principal
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colorScheme.outlineVariant.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Cabeçalho da tabela
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          border: Border(
                            bottom: BorderSide(
                              color: colorScheme.outlineVariant.withOpacity(
                                0.3,
                              ),
                            ),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                'POS',
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
                                'TROCAS',
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
                                'VALOR',
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
                                'NÃO NATURAIS',
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
                      ..._employeesData.map((employee) {
                        final alertaNaoNatural =
                            employee['percentualNaoNatural'] > 50;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: colorScheme.outlineVariant.withOpacity(
                                  0.1,
                                ),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Posição
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: employee['cor'].withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: employee['cor'].withOpacity(0.3),
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
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${employee['cargo']} - ${employee['setor']}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
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

                              // Trocas Não Naturais
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          employee['trocasNaoNaturais']
                                              .toString(),
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: alertaNaoNatural
                                                    ? Colors.orange
                                                    : colorScheme.onSurface,
                                              ),
                                        ),
                                        if (alertaNaoNatural) ...[
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.warning,
                                            size: 16,
                                            color: Colors.orange,
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: alertaNaoNatural
                                            ? Colors.orange.withOpacity(0.1)
                                            : Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: alertaNaoNatural
                                              ? Colors.orange.withOpacity(0.3)
                                              : Colors.green.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        '${employee['percentualNaoNatural']}%',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: alertaNaoNatural
                                              ? Colors.orange
                                              : Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
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

                // Rodapé com totais
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Valor Total',
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

  TextStyle _getHeaderStyle(ThemeData theme) {
    return theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ) ??
        const TextStyle();
  }

  // ========== FUNÇÕES AUXILIARES ==========
  String _formatarReal(double valor) {
    return 'R\$${valor.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+,)'), (Match m) => '${m[1]}.')}';
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
