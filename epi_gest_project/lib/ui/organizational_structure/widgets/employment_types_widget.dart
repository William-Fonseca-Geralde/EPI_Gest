import 'package:flutter/material.dart';
import 'organizational_structure_drawer.dart';

class EmploymentTypesWidget extends StatefulWidget {
  const EmploymentTypesWidget({super.key});

  @override
  State<EmploymentTypesWidget> createState() => EmploymentTypesWidgetState();
}

class EmploymentTypesWidgetState extends State<EmploymentTypesWidget> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  String _descricaoVinculo = 'CLT';

  // LISTA DE VÍNCULOS CADASTRADOS
  final List<Map<String, dynamic>> _vinculosCadastrados = [
    {
      'codigo': 'VIN001',
      'descricao': 'CLT',
    },
    {
      'codigo': 'VIN002',
      'descricao': 'PJ',
    },
  ];

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  void showAddDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Novo Vínculo',
      pageBuilder: (context, _, __) => OrganizationalStructureDrawer(
        title: 'Novo Tipo de Vínculo',
        onClose: () => Navigator.of(context).pop(),
        onSave: _salvarVinculo,
        child: _buildEmploymentTypeForm(),
      ),
    );
  }

  Widget _buildEmploymentTypeForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Informações do Vínculo'),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _codigoController,
            decoration: const InputDecoration(
              labelText: 'Código Vínculo*',
              hintText: 'Ex: VIN001',
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
            value: _descricaoVinculo,
            items: [
              'CLT',
              'PJ',
              'Terceirizado',
              'Menor Aprendiz',
              'Estagiário',
              'Temporário',
              'Autônomo',
              'Cooperado'
            ].map((vinculo) => DropdownMenuItem(
              value: vinculo,
              child: Text(vinculo),
            )).toList(),
            onChanged: (value) {
              setState(() {
                _descricaoVinculo = value!;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Descrição do Vínculo*',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Selecione um tipo de vínculo';
              }
              return null;
            },
          ),
        ],
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

  void _salvarVinculo() {
    if (_formKey.currentState!.validate()) {
      final novoVinculo = {
        'codigo': _codigoController.text,
        'descricao': _descricaoVinculo,
      };
      
      setState(() {
        _vinculosCadastrados.add(novoVinculo);
      });
      
      _limparCampos();
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vínculo cadastrado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _limparCampos() {
    _codigoController.clear();
    _descricaoVinculo = 'CLT';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipos de Vínculo',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Configure os tipos de vínculo empregatício',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),
        
        if (_vinculosCadastrados.isEmpty)
          _buildEmptyState()
        else
          Expanded(child: _buildEmploymentTypesList()),
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
              Icons.assignment_ind_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum vínculo cadastrado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmploymentTypesList() {
    return ListView.builder(
      itemCount: _vinculosCadastrados.length,
      itemBuilder: (context, index) {
        final vinculo = _vinculosCadastrados[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              Icons.assignment_ind_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              vinculo['descricao'],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('Código: ${vinculo['codigo']}'),
            onTap: () {
              // TODO: Implementar edição
            },
          ),
        );
      },
    );
  }
}