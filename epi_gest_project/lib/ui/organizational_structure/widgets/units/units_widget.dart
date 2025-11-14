import 'package:epi_gest_project/domain/models/organizational/unit_model.dart';
import 'package:epi_gest_project/ui/organizational_structure/widgets/units/units_drawer.dart';
import 'package:flutter/material.dart';

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
  var index = 0;

  final List<Unit> _unidadesCadastradas = [
    Unit(id: '1', nome: 'Matriz São Paulo', cnpj: '12.345.678/0001-90', tipo: 'Matriz', responsavel: 'Carlos Silva', statusAtiva: true, endereco: 'Rua 14A, 2125, Jardim America'),
    Unit(id: '2', nome: 'Filial Rio de Janeiro', cnpj: '98.765.432/0001-10', tipo: 'Filial', responsavel: 'Ana Oliveira', statusAtiva: false, endereco: 'Rua 14A, 2125, Jardim America'),
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _cnpjController.dispose();
    _enderecoController.dispose();
    _responsavelController.dispose();
    super.dispose();
  }

  void showAddDrawer() {
    _showDrawer();
  }

  void _showDrawer({Unit? unit, bool viewOnly = false}) {
   showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Gerenciar Unidade',
      pageBuilder: (context, _, __) => UnitDrawer(
        unitToEdit: unit,
        view: viewOnly,
        onClose: () => Navigator.of(context).pop(),
        onSave: (savedUnit) {
          setState(() {
            index = _unidadesCadastradas.indexWhere((u) => u.id == savedUnit.id);
            if (index != -1) {
              _unidadesCadastradas[index] = savedUnit;
            } else {
              _unidadesCadastradas.add(savedUnit);
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unidade ${index != -1 ? 'atualizada' : 'cadastrada'} com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            leading: Icon(unidade.tipo == 'Matriz' ? Icons.business : Icons.business_center, color: Theme.of(context).colorScheme.primary),
            title: Text(unidade.nome, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('CNPJ: ${unidade.cnpj} | Responsável: ${unidade.responsavel}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  label: Text(unidade.statusAtiva ? 'Ativa' : 'Inativa'),
                  backgroundColor: unidade.statusAtiva ? Colors.green.shade100 : Colors.red.shade100,
                  labelStyle: TextStyle(color: unidade.statusAtiva ? Colors.green.shade800 : Colors.red.shade800),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.visibility_outlined),
                  tooltip: 'Visualizar',
                  onPressed: () => _showDrawer(unit: unidade, viewOnly: true),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar',
                  onPressed: () => _showDrawer(unit: unidade),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Excluir',
                  onPressed: () { /* TODO: Lógica de exclusão */ },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}