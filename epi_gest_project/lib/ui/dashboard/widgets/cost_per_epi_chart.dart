import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _epiData = [
      {'epi': 'Capacete', 'custo': 18300, 'cor': Colors.blue, 'quantidade': 150, 'custoUnitario': 122.00},
      {'epi': 'Botas', 'custo': 12500, 'cor': Colors.green, 'quantidade': 200, 'custoUnitario': 62.50},
      {'epi': 'Luvas', 'custo': 8500, 'cor': Colors.orange, 'quantidade': 500, 'custoUnitario': 17.00},
      {'epi': 'Óculos', 'custo': 6200, 'cor': Colors.purple, 'quantidade': 310, 'custoUnitario': 20.00},
      {'epi': 'Prot. Auditivo', 'custo': 4500, 'cor': Colors.red, 'quantidade': 180, 'custoUnitario': 25.00},
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

  Future<void> _exportToPdf() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final pdf = pw.Document();
      final totalGeral = _epiData.fold(0, (sum, epi) => sum + (epi['custo'] as int));
      
      // Adicionar página ao PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              // Cabeçalho
              pw.Header(
                level: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Relatório de Custos de EPI',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Gerado em: ${DateTime.now().toString().split(' ')[0]}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Resumo Geral
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue400, width: 1),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                padding: pw.EdgeInsets.all(15),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'RESUMO GERAL',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue700,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Total Investido:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text(_formatarReal(totalGeral)),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Quantidade de Itens:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text('${_epiData.length} tipos'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Tabela Detalhada
              pw.Text(
                'DETALHAMENTO POR ITEM',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              
              pw.TableHelper.fromTextArray(
                context: context,
                headers: ['EPI', 'Custo Total (R\$)', 'Quantidade', 'Custo Unitário (R\$)'],
                data: _epiData.map((epi) => [
                  epi['epi'],
                  _formatarReal(epi['custo']).replaceAll('R\$', '').trim(),
                  epi['quantidade'].toString(),
                  (epi['custoUnitario'] as double).toStringAsFixed(2),
                ]).toList(),
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                cellStyle: pw.TextStyle(fontSize: 10),
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                rowDecoration: pw.BoxDecoration(color: PdfColors.white),
              ),
              
              pw.SizedBox(height: 20),
              
              // Análise
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.green400, width: 1),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                padding: pw.EdgeInsets.all(15),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ANÁLISE E INSIGHTS',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green700,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    ..._generatePdfInsights(totalGeral),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      // Salvar e abrir o PDF
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/relatorio_epi_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      
      await OpenFile.open(file.path);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PDF exportado com sucesso!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao exportar PDF: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  List<pw.Widget> _generatePdfInsights(int totalGeral) {
    final maiorCusto = _epiData.first;
    final percentualMaiorCusto = (maiorCusto['custo'] / totalGeral * 100);
    
    return [
      pw.Text('• ${maiorCusto['epi']} representa ${percentualMaiorCusto.toStringAsFixed(1)}% do investimento total'),
      pw.SizedBox(height: 5),
      pw.Text('• Custo unitário mais alto: Capacete (R\$${maiorCusto['custoUnitario']})'),
      pw.SizedBox(height: 5),
      pw.Text('• Os 2 itens mais caros representam mais de 60% do total'),
      pw.SizedBox(height: 5),
      pw.Text('• Recomendação: Avaliar compra em maior quantidade para redução de custos'),
    ];
  }

  Future<void> _exportToExcel() async {
  setState(() {
    _isExporting = true;
  });

  try {
    final totalGeral = _epiData.fold(0, (sum, epi) => sum + (epi['custo'] as int));
    
    // Cabeçalhos - REMOVENDO ACENTOS para compatibilidade
    List<List<dynamic>> csvData = [];
    csvData.add(['RELATORIO DE CUSTOS DE EPI']);
    csvData.add(['Gerado em:', '${DateTime.now().toString().split(' ')[0]}']);
    csvData.add([]);
    csvData.add(['RESUMO GERAL']);
    csvData.add(['Total Investido:', 'R\$ ${_formatarExcelTotal(totalGeral)}']);
    csvData.add(['Quantidade de Itens:', '${_epiData.length} tipos']);
    csvData.add([]);
    
    // Tabela detalhada
    csvData.add(['DETALHAMENTO POR ITEM']);
    csvData.add(['EPI', 'Custo Total (R\$)', 'Quantidade', 'Custo Unitario (R\$)', '% do Total']);
    
    for (var epi in _epiData) {
      final percentage = (epi['custo'] / totalGeral * 100);
      csvData.add([
        epi['epi'],
        'R\$ ${_formatarExcelValor(epi['custo'])}',
        epi['quantidade'],
        'R\$ ${(epi['custoUnitario'] as double).toStringAsFixed(2)}',
        '${percentage.toStringAsFixed(1)}%',
      ]);
    }
    
    csvData.add([]);
    csvData.add(['ANALISE E INSIGHTS']);
    
    final maiorCusto = _epiData.first;
    final percentualMaiorCusto = (maiorCusto['custo'] / totalGeral * 100);
    
    csvData.add(['Maior Investimento:', '${maiorCusto['epi']} (${percentualMaiorCusto.toStringAsFixed(1)}%)']);
    csvData.add(['Custo Unitario Mais Alto:', 'Capacete - R\$${maiorCusto['custoUnitario']}']);
    csvData.add(['Recomendacao:', 'Avaliar compra em maior quantidade para reducao de custos']);
    
    // Converter para CSV
    String csv = const ListToCsvConverter().convert(csvData);
    
    // ⚠️⚠️⚠️ MUDANÇA CRÍTICA AQUI ⚠️⚠️⚠️
    // Salvar como .csv (NÃO como .xlsx)
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/relatorio_epi_${DateTime.now().millisecondsSinceEpoch}.csv'); // <- .csv aqui!
    await file.writeAsString(csv);
    
    await OpenFile.open(file.path);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Excel/CSV exportado com sucesso!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
    
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao exportar Excel: $e'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  } finally {
    setState(() {
      _isExporting = false;
    });
  }
}

  String _formatarExcelTotal(int valor) {
    return '${(valor / 1000).toStringAsFixed(0)}k';
  }

  String _formatarExcelValor(int valor) {
    return '${(valor / 1000).toStringAsFixed(1)}k';
  }
  void _showDetailedAnalysis() {
    final totalGeral = _epiData.fold(0, (sum, epi) => sum + (epi['custo'] as int));
    
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
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Análise Detalhada - EPIs',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
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
                  _buildSummaryCard(theme, colorScheme, totalGeral),
                  
                  const SizedBox(height: 24),
                  
                  // Gráfico de Pizza
                  _buildPieChart(theme, colorScheme, totalGeral),
                  
                  const SizedBox(height: 24),
                  
                  // Tabela Detalhada
                  _buildDetailedTable(theme, colorScheme, totalGeral),
                  
                  const SizedBox(height: 24),
                  
                  // Insights
                  _buildInsightsCard(theme, colorScheme, totalGeral),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, ColorScheme colorScheme, int totalGeral) {
    final maiorCusto = _epiData.first;
    final menorCusto = _epiData.last;
    
    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer.withAlpha(30),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo Geral',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    theme,
                    'Total Investido',
                    _formatarReal(totalGeral),
                    Icons.attach_money,
                    colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    theme,
                    'Itens Diferentes',
                    '${_epiData.length} tipos',
                    Icons.category,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    theme,
                    'Maior Custo',
                    '${maiorCusto['epi']}\n${_formatarReal(maiorCusto['custo'])}',
                    Icons.arrow_upward,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    theme,
                    'Menor Custo',
                    '${menorCusto['epi']}\n${_formatarReal(menorCusto['custo'])}',
                    Icons.arrow_downward,
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

  Widget _buildSummaryItem(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildPieChart(ThemeData theme, ColorScheme colorScheme, int totalGeral) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribuição por Percentual',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sections: _epiData.map((epi) {
                          final percentage = (epi['custo'] / totalGeral * 100);
                          return PieChartSectionData(
                            color: epi['cor'],
                            value: percentage,
                            title: '${percentage.toStringAsFixed(1)}%',
                            radius: 60,
                            titleStyle: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _epiData.map((epi) {
                        final percentage = (epi['custo'] / totalGeral * 100);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
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
                              Expanded(
                                child: Text(
                                  epi['epi'],
                                  style: theme.textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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

  Widget _buildDetailedTable(ThemeData theme, ColorScheme colorScheme, int totalGeral) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalhamento por Item',
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
                dataRowMaxHeight: 60,
                columns: [
                  DataColumn(
                    label: Text('EPI', style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
                  ),
                  DataColumn(
                    label: Text('Custo Total', style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
                  ),
                  DataColumn(
                    label: Text('Quantidade', style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
                  ),
                  DataColumn(
                    label: Text('Custo Unit.', style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
                  ),
                  DataColumn(
                    label: Text('% do Total', style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
                  ),
                ],
                rows: _epiData.map((epi) {
                  final percentage = (epi['custo'] / totalGeral * 100);
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
                      DataCell(Text('R\$${epi['custoUnitario'].toStringAsFixed(2)}')),
                      DataCell(Text('${percentage.toStringAsFixed(1)}%')),
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

  Widget _buildInsightsCard(ThemeData theme, ColorScheme colorScheme, int totalGeral) {
    final maiorCusto = _epiData.first;
    final menorCusto = _epiData.last;
    
    final mediaCusto = _epiData.fold(0.0, (sum, epi) => sum + (epi['custo'] as int)) / _epiData.length;
    final percentualMaiorCusto = (maiorCusto['custo'] / totalGeral * 100);
    
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Insights e Recomendações',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              theme,
              '🔍 Maior Investimento',
              '${maiorCusto['epi']} representa ${percentualMaiorCusto.toStringAsFixed(1)}% do total',
            ),
            _buildInsightItem(
              theme,
              '💰 Custo Unitário',
              'Capacete tem o maior custo individual (R\$${maiorCusto['custoUnitario']})',
            ),
            _buildInsightItem(
              theme,
              '📊 Distribuição',
              'Os 2 itens mais caros representam mais de 60% do investimento total',
            ),
            _buildInsightItem(
              theme,
              '📈 Média de Custo',
              'Custo médio por tipo de EPI: R\$${mediaCusto.toStringAsFixed(2)}',
            ),
            _buildInsightItem(
              theme,
              '💡 Recomendação',
              'Avaliar possibilidade de compra em maior quantidade para reduzir custos unitários',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(ThemeData theme, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
        const PopupMenuItem(
          enabled: false,
          child: Divider(height: 1),
        ),
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
        const PopupMenuItem(
          enabled: false,
          child: Divider(height: 1),
        ),
        PopupMenuItem(
          value: 'analysis',
          child: Row(
            children: [
              const Icon(Icons.analytics, size: 20),
              const SizedBox(width: 8),
              const Text('Análise Detalhada'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final double maxCost = 20000;

    return Stack(
      children: [
        Card(
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
                          'Custos por Tipo de EPI',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Distribuição de custos por item',
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
                            enabled: false,
                          ),
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
                                interval: 5000,
                                getTitlesWidget: (value, meta) {
                                  if (value % 5000 == 0) {
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

                      // Valores em cima das colunas
                      if (_showValues)
                        Positioned.fill(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final double chartWidth = constraints.maxWidth;
                              final double chartHeight = constraints.maxHeight;
                              final double barWidth = 32.0;
                              final double spaceBetweenBars = (chartWidth - (_epiData.length * barWidth)) / (_epiData.length + 1);

                              return Stack(
                                children: _epiData.asMap().entries.map((entry) {
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
                                          color: colorScheme.outlineVariant.withAlpha(80),
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
                        _formatarReal(_epiData.fold(0, (sum, epi) => sum + (epi['custo'] as int))),
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

        // Overlay de carregamento
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

  // Função para formatar em Real brasileiro
  String _formatarReal(int valor) {
    return 'R\$${valor.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )},00';
  }
}