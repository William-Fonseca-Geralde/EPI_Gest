import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';

class EPIFormPage extends StatelessWidget {
  final Map<String, dynamic> employee;
  final Map<int, Map<String, dynamic>> selectedEPIs;
  final String authorizedBy;
  final String observations;
  
  const EPIFormPage({
    super.key,
    required this.employee,
    required this.selectedEPIs,
    required this.authorizedBy,
    required this.observations,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _getCurrentDate() {
    return _formatDate(DateTime.now());
  }

  // FUNÇÃO DE IMPRESSÃO ATUALIZADA
  Future<void> _showPrintDialog(BuildContext context) async {
    try {
      // Mostra um indicador de carregamento
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Preparando documento para impressão...'),
            ],
          ),
        ),
      );

      // Gera o PDF
      final pdfBytes = await _generatePdf();

      // Fecha o diálogo de carregamento
      if (context.mounted) Navigator.pop(context);

      // Abre o diálogo de impressão
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) => pdfBytes,
      );

    } catch (e) {
      // Fecha o diálogo de carregamento em caso de erro
      if (context.mounted) Navigator.pop(context);
      
      // Mostra mensagem de erro
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erro'),
            content: Text('Erro ao imprimir: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  // FUNÇÃO PARA COMPARTILHAR
  Future<void> _showShareDialog(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Gerando PDF...'),
            ],
          ),
        ),
      );

      final pdfBytes = await _generatePdf();

      if (context.mounted) Navigator.pop(context);

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'ficha_entrega_epi_${employee['registration']}_${_getCurrentDate().replaceAll('/', '-')}.pdf',
      );

    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erro'),
            content: Text('Erro ao compartilhar: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  // FUNÇÃO PARA GERAR O PDF
  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();
    final selectedEPIsList = selectedEPIs.values.toList();
    final totalItems = selectedEPIsList.fold(0, (sum, item) => sum + (item['quantity'] as int));

    // Adiciona uma página ao PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(2.0 * 72.0 / 25.4), // 2cm em todas as bordas
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabeçalho da empresa
              _buildPdfCompanyHeader(),
              pw.SizedBox(height: 20),
              
              // Título do documento
              _buildPdfDocumentTitle(),
              pw.SizedBox(height: 20),
              
              // Informações do colaborador
              _buildPdfEmployeeInfo(),
              pw.SizedBox(height: 20),
              
              // Lista de EPIs
              _buildPdfEPIList(selectedEPIsList),
              pw.SizedBox(height: 20),
              
              // Observações
              if (observations.isNotEmpty) ...[
                _buildPdfObservations(),
                pw.SizedBox(height: 20),
              ],
              
              // Assinaturas
              _buildPdfSignatures(),
              pw.SizedBox(height: 20),
              
              // Rodapé
              _buildPdfFooter(totalItems),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // WIDGETS PDF

  pw.Widget _buildPdfCompanyHeader() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'EMPRESA XYZ LTDA',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'CNPJ: 12.345.678/0001-90',
            style:pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Endereço: Rua Exemplo, 123 - Centro - Cidade/UF',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.Text(
            'Telefone: (11) 9999-9999',
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfDocumentTitle() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey50,
        border: pw.Border.all(color: PdfColors.blueGrey200),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'FICHA DE ENTREGA DE EQUIPAMENTO DE PROTEÇÃO INDIVIDUAL',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Data de Emissão: ${_getCurrentDate()}',
            style:pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfEmployeeInfo() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'DADOS DO COLABORADOR',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey800,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(2),
            },
            children: [
              _buildPdfTableRow('Nome:', employee['name']),
              _buildPdfTableRow('Matrícula:', employee['registration']),
              _buildPdfTableRow('Cargo:', employee['position']),
              _buildPdfTableRow('Setor:', employee['department']),
              _buildPdfTableRow('Data de Admissão:', _getCurrentDate()),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfEPIList(List<Map<String, dynamic>> selectedEPIsList) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'EQUIPAMENTOS ENTREGUES',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey800,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(
              color: PdfColors.grey300,
              width: 1,
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(0.5),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1),
              4: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColors.blueGrey50,
                ),
                children: [
                  _buildPdfTableHeaderCell('Item'),
                  _buildPdfTableHeaderCell('Descrição do EPI'),
                  _buildPdfTableHeaderCell('CA'),
                  _buildPdfTableHeaderCell('Quantidade'),
                  _buildPdfTableHeaderCell('Data de Entrega'),
                ],
              ),
              ...selectedEPIsList.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final epi = item['epi'];
                
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: index.isEven ? PdfColors.white : PdfColors.grey100,
                  ),
                  children: [
                    _buildPdfTableCell('${index + 1}'),
                    _buildPdfTableCell(epi['name']),
                    _buildPdfTableCell(epi['ca']),
                    _buildPdfTableCell('${item['quantity']}'),
                    _buildPdfTableCell(_getCurrentDate()),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfObservations() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'OBSERVAÇÕES',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey800,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            observations,
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfSignatures() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              pw.Expanded(
                child: _buildPdfSignatureField('Assinatura do Colaborador'),
              ),
              pw.SizedBox(width: 32),
              pw.Expanded(
                child: _buildPdfSignatureField('Responsável pela Entrega', authorizedBy),
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            height: 1,
            color: PdfColors.grey300,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Data: ${_getCurrentDate()}',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfFooter(int totalItems) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey50,
        border: pw.Border.all(color: PdfColors.blueGrey200),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'TOTAL DE ITENS ENTREGUES: $totalItems',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Documento gerado automaticamente pelo sistema',
            style: pw.TextStyle(
              fontSize: 8,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  // FUNÇÕES AUXILIARES PDF
  pw.TableRow _buildPdfTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text(
            label,
            style:pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ),
      ],
    );
  }

  pw.Widget _buildPdfTableHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style:pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildPdfTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 9),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildPdfSignatureField(String label, [String? name]) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style:pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          height: 40,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: name != null 
              ? pw.Center(
                  child: pw.Text(
                    name,
                    style:pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                )
              : pw.Center(
                  child: pw.Text(
                    '___________________________',
                    style: pw.TextStyle(color: PdfColors.grey, fontSize: 10),
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedEPIsList = selectedEPIs.values.toList();
    final totalItems = selectedEPIsList.fold(0, (sum, item) => sum + (item['quantity'] as int));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha de Entrega de EPI'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: Colors.white),
            onPressed: () => _showPrintDialog(context),
            tooltip: 'Imprimir',
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _showShareDialog(context),
            tooltip: 'Compartilhar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Cabeçalho da empresa
            _buildCompanyHeader(theme),
            const SizedBox(height: 32),
            
            // Título do documento
            _buildDocumentTitle(theme),
            const SizedBox(height: 24),
            
            // Informações do colaborador
            _buildEmployeeInfo(theme),
            const SizedBox(height: 24),
            
            // Lista de EPIs
            _buildEPIList(theme, selectedEPIsList),
            const SizedBox(height: 24),
            
            // Observações
            if (observations.isNotEmpty) ...[
              _buildObservations(theme),
              const SizedBox(height: 24),
            ],
            
            // Assinaturas
            _buildSignatures(theme),
            const SizedBox(height: 32),
            
            // Rodapé
            _buildFooter(theme, totalItems),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPrintDialog(context),
        icon: const Icon(Icons.print),
        label: const Text('Imprimir'),
        backgroundColor: Colors.blueGrey[800],
      ),
    );
  }

  Widget _buildCompanyHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'EMPRESA XYZ LTDA',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'CNPJ: 12.345.678/0001-90',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Endereço: Rua Exemplo, 123 - Centro - Cidade/UF',
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            'Telefone: (11) 9999-9999',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTitle(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        border: Border.all(color: Colors.blueGrey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'FICHA DE ENTREGA DE EQUIPAMENTO DE PROTEÇÃO INDIVIDUAL',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[900],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Data de Emissão: ${_getCurrentDate()}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeInfo(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DADOS DO COLABORADOR',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800],
            ),
          ),
          const SizedBox(height: 12),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2),
            },
            children: [
              _buildTableRow('Nome:', employee['name']),
              _buildTableRow('Matrícula:', employee['registration']),
              _buildTableRow('Cargo:', employee['position']),
              _buildTableRow('Setor:', employee['department']),
              _buildTableRow('Data de Admissão:', _getCurrentDate()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEPIList(ThemeData theme, List<Map<String, dynamic>> selectedEPIsList) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EQUIPAMENTOS ENTREGUES',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800],
            ),
          ),
          const SizedBox(height: 12),
          Table(
            border: TableBorder.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
            columnWidths: const {
              0: FlexColumnWidth(0.5),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50],
                ),
                children: [
                  _buildTableHeaderCell('Item'),
                  _buildTableHeaderCell('Descrição do EPI'),
                  _buildTableHeaderCell('CA'),
                  _buildTableHeaderCell('Quantidade'),
                  _buildTableHeaderCell('Data de Entrega'),
                ],
              ),
              ...selectedEPIsList.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final epi = item['epi'];
                
                return TableRow(
                  decoration: BoxDecoration(
                    color: index.isEven ? Colors.white : Colors.grey.shade50,
                  ),
                  children: [
                    _buildTableCell('${index + 1}'),
                    _buildTableCell(epi['name']),
                    _buildTableCell(epi['ca']),
                    _buildTableCell('${item['quantity']}'),
                    _buildTableCell(_getCurrentDate()),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildObservations(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OBSERVAÇÕES',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            observations,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSignatures(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildSignatureField('Assinatura do Colaborador', theme),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: _buildSignatureField('Responsável pela Entrega', theme, authorizedBy),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 8),
          Text(
            'Data: ${_getCurrentDate()}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme, int totalItems) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        border: Border.all(color: Colors.blueGrey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'TOTAL DE ITENS ENTREGUES: $totalItems',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Documento gerado automaticamente pelo sistema',
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureField(String label, ThemeData theme, [String? name]) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4),
          ),
          child: name != null 
              ? Center(
                  child: Text(
                    name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : const Center(
                  child: Text(
                    '___________________________________',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
        ),
      ],
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(value),
        ),
      ],
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}