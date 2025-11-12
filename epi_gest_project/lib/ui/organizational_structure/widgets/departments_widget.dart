import 'package:flutter/material.dart';
import 'organizational_structure_drawer.dart';

class DepartmentsWidget extends StatefulWidget {
  const DepartmentsWidget({super.key});

  @override
  State<DepartmentsWidget> createState() => DepartmentsWidgetState();
}

class DepartmentsWidgetState extends State<DepartmentsWidget> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _descricaoController = TextEditingController();
  String _unidadeVinculada = 'Matriz';

  // LISTA DE DEPARTAMENTOS CADASTRADOS
  final List<Map<String, dynamic>> _departamentosCadastrados = [
    {
      'codigo': 'PROD001',
      'descricao': 'Produção',
      'unidade': 'Matriz',
    },
    {
      'codigo': 'ADM001', 
      'descricao': 'Administrativo',
      'unidade': 'Matriz',
    },
  ];

  @override
  void dispose() {
    _codigoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  // MÉTODO CHAMADO PELO BOTÃO DO HEADER
  void showAddDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Novo Departamento',
      pageBuilder: (context, _, __) => OrganizationalStructureDrawer(
        title: 'Novo Departamento',
        onClose: () => Navigator.of(context).pop(),
        onSave: _salvarDepartamento,
        child: _buildDepartmentForm(),
      ),
    );
  }

  Widget _buildDepartmentForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Informações do Departamento'),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _codigoController,
            decoration: const InputDecoration(
              labelText: 'Código do Setor*',
              hintText: 'Ex: PROD001',
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
          
          TextFormField(
            controller: _descricaoController,
            decoration: const InputDecoration(
              labelText: 'Descrição do Setor*',
              hintText: 'Ex: Produção, Administrativo, RH',
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
            value: _unidadeVinculada,
            items: ['Matriz', 'Filial SP', 'Filial RJ', 'Filial MG']
                .map((unidade) => DropdownMenuItem(
                      value: unidade,
                      child: Text(unidade),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _unidadeVinculada = value!;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Unidade Vinculada*',
              border: OutlineInputBorder(),
            ),
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

  void _salvarDepartamento() {
    if (_formKey.currentState!.validate()) {
      final novoDepartamento = {
        'codigo': _codigoController.text,
        'descricao': _descricaoController.text,
        'unidade': _unidadeVinculada,
      };
      
      setState(() {
        _departamentosCadastrados.add(novoDepartamento);
      });
      
      _limparCampos();
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Departamento cadastrado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _limparCampos() {
    _codigoController.clear();
    _descricaoController.clear();
    _unidadeVinculada = 'Matriz';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Setores / Departamentos',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Configure os departamentos da empresa',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),
        
        if (_departamentosCadastrados.isEmpty)
          _buildEmptyState()
        else
          Expanded(child: _buildDepartmentsList()),
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
              Icons.work_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum departamento cadastrado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentsList() {
    return ListView.builder(
      itemCount: _departamentosCadastrados.length,
      itemBuilder: (context, index) {
        final departamento = _departamentosCadastrados[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              Icons.work_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              departamento['descricao'],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Código: ${departamento['codigo']}'),
                Text('Unidade: ${departamento['unidade']}'),
              ],
            ),
            onTap: () {
              // TODO: Implementar edição
            },
          ),
        );
      },
    );
  }
}