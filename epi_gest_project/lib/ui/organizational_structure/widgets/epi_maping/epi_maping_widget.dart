import 'package:epi_gest_project/domain/models/epi/epi_model.dart';
import 'package:epi_gest_project/domain/models/organizational/epi_mapping_model.dart';
import 'package:epi_gest_project/domain/models/organizational/risk_model.dart';
import 'package:epi_gest_project/domain/models/organizational/role_model.dart';
import 'package:flutter/material.dart';
import 'package:epi_gest_project/ui/organizational_structure/widgets/epi_maping/epi_mapping_drawer.dart';

class EpiMapingWidget extends StatefulWidget {
  const EpiMapingWidget({super.key});

  @override
  State<EpiMapingWidget> createState() => EpiMapingWidgetState();
}

class EpiMapingWidgetState extends State<EpiMapingWidget> {
  final List<EpiMapping> _mapeamentos = [];

  final List<Role> _availableRoles = []; // TODO: Carregar cargos do Appwrite
  final List<Risk> _availableRisks = []; // TODO: Carregar riscos do Appwrite
  final List<EpiModel> _availableEpis = []; // TODO: Carregar EPIs do Appwrite

  void showAddDrawer() {
    _showMapingDrawer();
  }

  void _showMapingDrawer({EpiMapping? mapping, bool viewOnly = false}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Gerenciar Mapeamento',
      pageBuilder: (context, _, __) => EpiMappingDrawer( // <-- 4. Chama o drawer
        mappingToEdit: mapping,
        view: viewOnly,
        onClose: () => Navigator.of(context).pop(),
        onSave: (mapSalvo) {
          setState(() {
            if (mapping != null) { // Editando
              final index = _mapeamentos.indexWhere((m) => m.id == mapSalvo.id);
              if (index != -1) _mapeamentos[index] = mapSalvo;
            } else { // Adicionando
              _mapeamentos.add(mapSalvo);
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mapeamento ${mapping != null ? 'atualizado' : 'cadastrado'} com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        },
        // 5. Passa as listas de dados para o drawer
        availableRoles: _availableRoles,
        availableRisks: _availableRisks,
        availableEpis: _availableEpis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_mapeamentos.isEmpty)
          _buildEmptyState()
        else
          Expanded(child: _buildMappingsList()),
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
              Icons.access_time_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum mapeamento cadastrado',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMappingsList() {
    return ListView.builder(
      itemCount: _mapeamentos.length,
      itemBuilder: (context, index) {
        final map = _mapeamentos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            // ...código do ListTile...
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined),
                  tooltip: 'Visualizar',
                  onPressed: () => _showMapingDrawer(mapping: map, viewOnly: true), // <-- 6. Ações da lista
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar',
                  onPressed: () => _showMapingDrawer(mapping: map), // <-- 6. Ações da lista
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
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