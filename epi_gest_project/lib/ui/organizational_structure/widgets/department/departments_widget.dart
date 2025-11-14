import 'package:epi_gest_project/domain/models/organizational/department_model.dart';
import 'package:flutter/material.dart';
import 'department_drawer.dart';

class DepartmentsWidget extends StatefulWidget {
  const DepartmentsWidget({super.key});

  @override
  State<DepartmentsWidget> createState() => DepartmentsWidgetState();
}

class DepartmentsWidgetState extends State<DepartmentsWidget> {
  final _codigoController = TextEditingController();
  final _descricaoController = TextEditingController();
  var index = 0;

  // LISTA DE DEPARTAMENTOS CADASTRADOS
  final List<Department> _departamentosCadastrados = [
    Department(id: 'PROD001', codigo: 'PROD001', descricao: 'Produção', unidade: 'Matriz'),
    Department(id: 'ADM001', codigo: 'ADM001', descricao: 'Administrativo', unidade: 'Matriz'),
  ];

  @override
  void dispose() {
    _codigoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void showAddDrawer() {
    _showDepartmentDrawer();
  }

  void _showDepartmentDrawer({Department? department, bool viewOnly = false}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Gerenciar Departamento',
      pageBuilder: (context, _, __) => DepartmentDrawer(
        departmentToEdit: department,
        view: viewOnly,
        onClose: () => Navigator.of(context).pop(),
        onSave: (savedDepartment) {
          setState(() {
            index = _departamentosCadastrados.indexWhere(
              (d) => d.id == savedDepartment.id,
            );
            if (index != -1) {
              _departamentosCadastrados[index] = savedDepartment;
            } else {
              _departamentosCadastrados.add(savedDepartment);
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Departamento ${index != -1 ? 'atualizado' : 'cadastrado'} com sucesso!',
              ),
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
            Icon(Icons.work_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Nenhum departamento cadastrado',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
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
              departamento.descricao,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Código: ${departamento.codigo} | Unidade: ${departamento.unidade}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined),
                  tooltip: 'Visualizar',
                  onPressed: () => _showDepartmentDrawer(
                    department: departamento,
                    viewOnly: true,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar',
                  onPressed: () =>
                      _showDepartmentDrawer(department: departamento),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Excluir',
                  onPressed: () {
                    // TODO: Adicionar lógica de exclusão com confirmação
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
