import 'package:flutter/material.dart';
import 'organizational_structure_drawer.dart';

class RisksWidget extends StatefulWidget {
  const RisksWidget({super.key});

  @override
  State<RisksWidget> createState() => RisksWidgetState();
}

class RisksWidgetState extends State<RisksWidget> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _descricaoController = TextEditingController();
  String _categoriaRisco = 'Físicos';

  // LISTA DE RISCOS CADASTRADOS
  final List<Map<String, dynamic>> _riscosCadastrados = [
    {
      'codigo': 'FIS001',
      'descricao': 'Ruído excessivo',
      'categoria': 'Físicos',
    },
    {
      'codigo': 'QUIM001',
      'descricao': 'Poeira industrial',
      'categoria': 'Químicos',
    },
  ];

  @override
  void dispose() {
    _codigoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void showAddDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Novo Risco',
      pageBuilder: (context, _, __) => OrganizationalStructureDrawer(
        title: 'Novo Risco Ocupacional',
        onClose: () => Navigator.of(context).pop(),
        onSave: _salvarRisco,
        child: _buildRiskForm(),
      ),
    );
  }

  Widget _buildRiskForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Informações do Risco'),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _codigoController,
            decoration: const InputDecoration(
              labelText: 'Código do Risco*',
              hintText: 'Ex: NR-06, NR-35, FIS001, QUIM001',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _categoriaRisco,
            items: [
              'Físicos',
              'Químicos', 
              'Biológicos',
              'Ergonômicos',
              'Acidentes'
            ].map((categoria) => DropdownMenuItem(
              value: categoria,
              child: Text(categoria),
            )).toList(),
            onChanged: (value) {
              setState(() {
                _categoriaRisco = value!;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Categoria do Risco*',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _descricaoController,
            decoration: const InputDecoration(
              labelText: 'Descrição do Risco*',
              hintText: 'Ex: Ruído excessivo, Quedas, Poeira, Calor',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          _buildSectionTitle('Exemplos por Categoria'),
          const SizedBox(height: 8),
          
          _buildExemplosCategoria(),
        ],
      ),
    );
  }

  Widget _buildExemplosCategoria() {
    final exemplos = {
      'Físicos': 'Ruído, calor, frio, vibração, radiação, umidade',
      'Químicos': 'Poeira, fumos, névoas, neblinas, gases, vapores',
      'Biológicos': 'Bactérias, vírus, fungos, parasitas, protozoários',
      'Ergonômicos': 'Postura, repetição, levantamento de peso, ritmo',
      'Acidentes': 'Quedas, choques, incêndios, explosões, cortes',
    };
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_categoriaRisco}:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              exemplos[_categoriaRisco] ?? '',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  void _salvarRisco() {
    if (_formKey.currentState!.validate()) {
      final novoRisco = {
        'codigo': _codigoController.text,
        'descricao': _descricaoController.text,
        'categoria': _categoriaRisco,
      };
      
      setState(() {
        _riscosCadastrados.add(novoRisco);
      });
      
      _limparCampos();
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Risco cadastrado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _limparCampos() {
    _codigoController.clear();
    _descricaoController.clear();
    _categoriaRisco = 'Físicos';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riscos Ocupacionais',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Classifique os riscos ocupacionais por atividade',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),
        
        if (_riscosCadastrados.isEmpty)
          _buildEmptyState()
        else
          Expanded(child: _buildRisksList()),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum risco cadastrado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRisksList() {
    return ListView.builder(
      itemCount: _riscosCadastrados.length,
      itemBuilder: (context, index) {
        final risco = _riscosCadastrados[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              Icons.warning_amber_outlined,
              color: _getRiskColor(risco['categoria']),
            ),
            title: Text(
              risco['descricao'],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Código: ${risco['codigo']}'),
                Text('Categoria: ${risco['categoria']}'),
              ],
            ),
            trailing: Chip(
              label: Text(risco['categoria']),
              backgroundColor: _getRiskColor(risco['categoria']).withOpacity(0.1),
            ),
            onTap: () {
              // TODO: Implementar edição
            },
          ),
        );
      },
    );
  }

  Color _getRiskColor(String categoria) {
    switch (categoria) {
      case 'Físicos':
        return Colors.orange;
      case 'Químicos':
        return Colors.red;
      case 'Biológicos':
        return Colors.green;
      case 'Ergonômicos':
        return Colors.blue;
      case 'Acidentes':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}