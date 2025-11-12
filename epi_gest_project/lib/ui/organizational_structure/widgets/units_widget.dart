import 'package:flutter/material.dart';
import 'organizational_structure_drawer.dart';

class UnitsWidget extends StatefulWidget {
  const UnitsWidget({super.key});

  @override
  State<UnitsWidget> createState() => UnitsWidgetState();
}

class UnitsWidgetState extends State<UnitsWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _responsavelController = TextEditingController();
  
  String _tipoUnidade = 'Matriz';
  bool _statusAtiva = true;

  // LISTA DE UNIDADES CADASTRADAS (EXEMPLO)
  final List<Map<String, dynamic>> _unidadesCadastradas = [
    {
      'nome': 'Matriz São Paulo',
      'cnpj': '12.345.678/0001-90',
      'tipo': 'Matriz',
      'responsavel': 'Carlos Silva',
      'status': 'Ativa',
    },
    {
      'nome': 'Filial Rio de Janeiro',
      'cnpj': '98.765.432/0001-10',
      'tipo': 'Filial',
      'responsavel': 'Ana Oliveira',
      'status': 'Ativa',
    },
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _cnpjController.dispose();
    _enderecoController.dispose();
    _responsavelController.dispose();
    super.dispose();
  }

  // MÉTODO CHAMADO PELO BOTÃO DO HEADER
  void showAddDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Nova Unidade',
      pageBuilder: (context, _, __) => OrganizationalStructureDrawer(
        title: 'Nova Unidade',
        onClose: () => Navigator.of(context).pop(),
        onSave: _salvarUnidade,
        child: _buildUnitForm(),
      ),
    );
  }

  Widget _buildUnitForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seção: Informações da Unidade
          _buildSectionTitle('Informações da Unidade'),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _nomeController,
            decoration: const InputDecoration(
              labelText: 'Nome da Unidade*',
              hintText: 'Ex: Matriz São Paulo',
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
            controller: _cnpjController,
            decoration: const InputDecoration(
              labelText: 'CNPJ*',
              hintText: '00.000.000/0000-00',
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
            controller: _enderecoController,
            decoration: const InputDecoration(
              labelText: 'Endereço Completo*',
              hintText: 'Rua, número, bairro, cidade, estado',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _tipoUnidade,
            items: ['Matriz', 'Filial']
                .map((tipo) => DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _tipoUnidade = value!;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Tipo de Unidade*',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _responsavelController,
            decoration: const InputDecoration(
              labelText: 'Responsável Local*',
              hintText: 'Nome do responsável',
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
          
          Row(
            children: [
              const Text('Status da Unidade:'),
              const SizedBox(width: 12),
              Switch(
                value: _statusAtiva,
                onChanged: (value) {
                  setState(() {
                    _statusAtiva = value;
                  });
                },
              ),
              Text(
                _statusAtiva ? 'Ativa' : 'Inativa',
                style: TextStyle(
                  color: _statusAtiva ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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

  void _salvarUnidade() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implementar lógica de salvamento
      final novaUnidade = {
        'nome': _nomeController.text,
        'cnpj': _cnpjController.text,
        'endereco': _enderecoController.text,
        'tipo': _tipoUnidade,
        'responsavel': _responsavelController.text,
        'status': _statusAtiva ? 'Ativa' : 'Inativa',
      };
      
      // Adiciona na lista (simulação)
      setState(() {
        _unidadesCadastradas.add(novaUnidade);
      });
      
      // Limpar campos após salvar
      _limparCampos();
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unidade cadastrada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _limparCampos() {
    _nomeController.clear();
    _cnpjController.clear();
    _enderecoController.clear();
    _responsavelController.clear();
    _tipoUnidade = 'Matriz';
    _statusAtiva = true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TÍTULO E DESCRIÇÃO
        Text(
          'Unidades (Matriz / Filial)',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gerencie as unidades da empresa',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),
        
        // LISTA DE UNIDADES CADASTRADAS
        if (_unidadesCadastradas.isEmpty)
          _buildEmptyState()
        else
          Expanded(child: _buildUnitsList()),
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
              Icons.business_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma unidade cadastrada',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Clique em "Nova Unidade" para começar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitsList() {
    return ListView.builder(
      itemCount: _unidadesCadastradas.length,
      itemBuilder: (context, index) {
        final unidade = _unidadesCadastradas[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              unidade['tipo'] == 'Matriz' 
                  ? Icons.business 
                  : Icons.business_center,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              unidade['nome'],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CNPJ: ${unidade['cnpj']}'),
                Text('Responsável: ${unidade['responsavel']}'),
              ],
            ),
            trailing: Chip(
              label: Text(unidade['status']),
              backgroundColor: unidade['status'] == 'Ativa' 
                  ? Colors.green.shade100 
                  : Colors.red.shade100,
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