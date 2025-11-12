import 'package:flutter/material.dart';
import 'organizational_structure_drawer.dart';

class RolesWidget extends StatefulWidget {
  const RolesWidget({super.key});

  @override
  State<RolesWidget> createState() => RolesWidgetState();
}

class RolesWidgetState extends State<RolesWidget> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _episController = TextEditingController();

  // LISTA DE CARGOS CADASTRADOS
  final List<Map<String, dynamic>> _cargosCadastrados = [
    {
      'codigo': 'CAR001',
      'descricao': 'Operador de Máquinas',
      'epis': 'Capacete, Luva, Óculos, Botina',
    },
    {
      'codigo': 'CAR002',
      'descricao': 'Auxiliar de Produção',
      'epis': 'Luva, Óculos, Botina',
    },
  ];

  @override
  void dispose() {
    _codigoController.dispose();
    _descricaoController.dispose();
    _episController.dispose();
    super.dispose();
  }

  void showAddDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Novo Cargo',
      pageBuilder: (context, _, __) => OrganizationalStructureDrawer(
        title: 'Novo Cargo/Função',
        onClose: () => Navigator.of(context).pop(),
        onSave: _salvarCargo,
        child: _buildRoleForm(),
      ),
    );
  }

  Widget _buildRoleForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Informações do Cargo'),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _codigoController,
            decoration: const InputDecoration(
              labelText: 'Código Cargo/Função*',
              hintText: 'Ex: CAR001',
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
              labelText: 'Descrição do Cargo*',
              hintText: 'Ex: Operador de Máquinas, Auxiliar de Produção',
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
            controller: _episController,
            decoration: const InputDecoration(
              labelText: 'EPIs Padrão Atribuídos',
              hintText: 'Ex: Capacete, Luva, Óculos, Botina',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
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

  void _salvarCargo() {
    if (_formKey.currentState!.validate()) {
      final novoCargo = {
        'codigo': _codigoController.text,
        'descricao': _descricaoController.text,
        'epis': _episController.text,
      };
      
      setState(() {
        _cargosCadastrados.add(novoCargo);
      });
      
      _limparCampos();
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cargo cadastrado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _limparCampos() {
    _codigoController.clear();
    _descricaoController.clear();
    _episController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cargos / Funções',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Defina os cargos e funções dos colaboradores',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),
        
        if (_cargosCadastrados.isEmpty)
          _buildEmptyState()
        else
          Expanded(child: _buildRolesList()),
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
              Icons.badge_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum cargo cadastrado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRolesList() {
    return ListView.builder(
      itemCount: _cargosCadastrados.length,
      itemBuilder: (context, index) {
        final cargo = _cargosCadastrados[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              Icons.badge_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              cargo['descricao'],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Código: ${cargo['codigo']}'),
                if (cargo['epis'].isNotEmpty)
                  Text('EPIs: ${cargo['epis']}'),
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