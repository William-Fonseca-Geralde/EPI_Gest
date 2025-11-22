import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
            onPressed: () {
              _showPrintDialog(context);
            },
            tooltip: 'Imprimir',
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              _showShareDialog(context);
            },
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
        onPressed: () {
          _showPrintDialog(context);
        },
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
              _buildTableRow('Data de Admissão:', _getCurrentDate()), // Mock
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

  void _showPrintDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Imprimir Documento'),
        content: const Text('Esta funcionalidade de impressão será implementada em breve.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compartilhar Documento'),
        content: const Text('Esta funcionalidade de compartilhamento será implementada em breve.'),
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