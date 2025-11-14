import 'package:epi_gest_project/domain/models/organizational/employement_type_model.dart';
import 'package:epi_gest_project/ui/organizational_structure/widgets/employment_type/employement_type_drawer.dart';
import 'package:flutter/material.dart';

class EmploymentTypesWidget extends StatefulWidget {
  const EmploymentTypesWidget({super.key});

  @override
  State<EmploymentTypesWidget> createState() => EmploymentTypesWidgetState();
}

class EmploymentTypesWidgetState extends State<EmploymentTypesWidget> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  String _descricaoVinculo = 'CLT';

  final List<EmploymentType> _vinculosCadastrados = [
    EmploymentType(id: 'VIN001', codigo: 'VIN001', descricao: 'CLT'),
    EmploymentType(id: 'VIN002', codigo: 'VIN002', descricao: 'PJ')
  ];

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  void showAddDrawer() {
    _showEmployementTypeDrawer();
  }

  void _showEmployementTypeDrawer({EmploymentType? tipo, bool viewOnly = false}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Gerenciar Vínculo',
      pageBuilder: (context, _, __) => EmploymentTypeDrawer( // <-- 4. Chama o drawer
        typeToEdit: tipo,
        view: viewOnly,
        onClose: () => Navigator.of(context).pop(),
        onSave: (tipoSalvo) {
          setState(() {
            if (tipo != null) { // Editando
              final index = _vinculosCadastrados.indexWhere((t) => t.id == tipoSalvo.id);
              if (index != -1) _vinculosCadastrados[index] = tipoSalvo;
            } else { // Adicionando
              _vinculosCadastrados.add(tipoSalvo);
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vínculo ${tipo != null ? 'atualizado' : 'cadastrado'} com sucesso!'),
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
              vinculo.descricao,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('Código: ${vinculo.codigo}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined),
                  tooltip: 'Visualizar',
                  onPressed: () => _showEmployementTypeDrawer(tipo: vinculo, viewOnly: true),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar',
                  onPressed: () => _showEmployementTypeDrawer(tipo: vinculo),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Excluir',
                  onPressed: () { /* TODO */ },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}