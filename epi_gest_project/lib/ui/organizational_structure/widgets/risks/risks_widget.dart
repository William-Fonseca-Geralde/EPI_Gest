import 'package:epi_gest_project/domain/models/organizational/risk_model.dart';
import 'package:epi_gest_project/ui/organizational_structure/widgets/risks/risks_drawer.dart';
import 'package:flutter/material.dart';

class RisksWidget extends StatefulWidget {
  const RisksWidget({super.key});

  @override
  State<RisksWidget> createState() => RisksWidgetState();
}

class RisksWidgetState extends State<RisksWidget> {
  final _codigoController = TextEditingController();
  final _descricaoController = TextEditingController();
  var index = 0;

  final List<Risk> _riscosCadastrados = [
    Risk(id: 'R001', codigo: 'R001', descricao: 'Ruído Contínuo'),
    Risk(id: 'R002', codigo: 'R002', descricao: 'Poeira Mineral'),
  ];

  @override
  void dispose() {
    _codigoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void showAddDrawer() {
    _showRiskDrawer();
  }

  void _showRiskDrawer({Risk? risk, bool viewOnly = false}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Gerenciar Cargo',
      pageBuilder: (context, _, __) => RisksDrawer(
        riskToEdit: risk,
        view: viewOnly,
        onClose: () => Navigator.of(context).pop(),
        onSave: (savedRisk) {
          setState(() {
            index = _riscosCadastrados.indexWhere((r) => r.id == savedRisk.id);
            if (index != -1) {
              _riscosCadastrados[index] = savedRisk;
            } else {
              _riscosCadastrados.add(savedRisk);
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
              Icons.warning_amber_outlined, color: Theme.of(context).colorScheme.primary
            ),
            title: Text(
              risco.descricao,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('Código: ${risco.codigo}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined),
                  tooltip: 'Visualizar',
                  onPressed: () => _showRiskDrawer(risk: risco, viewOnly: true),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar',
                  onPressed: () => _showRiskDrawer(risk: risco),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Excluir',
                  onPressed: () { /* TODO: Lógica de exclusão */ },
                ),
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