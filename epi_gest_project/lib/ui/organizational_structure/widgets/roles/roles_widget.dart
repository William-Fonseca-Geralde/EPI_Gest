import 'package:epi_gest_project/domain/models/organizational/role_model.dart';
import 'package:epi_gest_project/ui/organizational_structure/widgets/roles/role_drawer.dart';
import 'package:flutter/material.dart';

class RolesWidget extends StatefulWidget {
  const RolesWidget({super.key});

  @override
  State<RolesWidget> createState() => RolesWidgetState();
}

class RolesWidgetState extends State<RolesWidget> {
  final _codigoController = TextEditingController();
  final _descricaoController = TextEditingController();
  var index = 0;

  final List<Role> _cargosCadastrados = [
    Role(id: 'CAR001', codigo: 'CAR001', descricao: 'Operador de Máquinas'),
    Role(id: 'CAR002', codigo: 'CAR002', descricao: 'Auxiliar de Produção'),
  ];

  @override
  void dispose() {
    _codigoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void showAddDrawer() {
    _showRoleDrawer();
  }

  void _showRoleDrawer({Role? role, bool viewOnly = false}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Gerenciar Cargo',
      pageBuilder: (context, _, __) => RoleDrawer(
        roleToEdit: role,
        view: viewOnly,
        onClose: () => Navigator.of(context).pop(),
        onSave: (savedRole) {
          setState(() {
            index = _cargosCadastrados.indexWhere((r) => r.id == savedRole.id);
            if (index != -1) {
              _cargosCadastrados[index] = savedRole;
            } else {
              _cargosCadastrados.add(savedRole);
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cargo ${index != -1 ? 'atualizado' : 'cadastrado'} com sucesso!'),
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
            leading: Icon(Icons.badge_outlined, color: Theme.of(context).colorScheme.primary),
            title: Text(cargo.descricao, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('Código: ${cargo.codigo}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined),
                  tooltip: 'Visualizar',
                  onPressed: () => _showRoleDrawer(role: cargo, viewOnly: true),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar',
                  onPressed: () => _showRoleDrawer(role: cargo),
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