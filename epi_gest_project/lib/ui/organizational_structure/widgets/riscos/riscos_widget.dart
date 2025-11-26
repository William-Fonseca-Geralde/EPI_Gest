import 'package:epi_gest_project/data/services/organizational_structure/riscos_repository.dart';
import 'package:epi_gest_project/domain/models/riscos_model.dart';
import 'package:epi_gest_project/ui/organizational_structure/widgets/riscos/riscos_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RiscosWidget extends StatefulWidget {
  const RiscosWidget({super.key});

  @override
  State<RiscosWidget> createState() => RiscosWidgetState();
}

class RiscosWidgetState extends State<RiscosWidget> {
  List<RiscosModel> _riscos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = Provider.of<RiscosRepository>(context, listen: false);
      final result = await repository.getAllRiscos();
      
      if (mounted) {
        setState(() {
          _riscos = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Erro ao carregar riscos: $e';
        });
      }
    }
  }

  void showAddDrawer() {
    _showDrawer();
  }

  void _showDrawer({RiscosModel? risco, bool viewOnly = false}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Gerenciar Risco',
      pageBuilder: (context, _, __) => RiscosDrawer(
        riscoToEdit: risco,
        view: viewOnly,
        onClose: () => Navigator.of(context).pop(),
        onSave: (savedRisco) {
          _loadData();
        },
      ),
    );
  }

  Future<void> _deleteRisco(RiscosModel risco) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir a unidade "${risco.nomeRiscos}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final repository = Provider.of<RiscosRepository>(context, listen: false);
        await repository.delete(risco.id!);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Risco excluído com sucesso!'), backgroundColor: Colors.green),
        );
        _loadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 48),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: _loadData, icon: const Icon(Icons.refresh), label: const Text("Tentar Novamente"))
          ],
        ),
      );
    }

    if (_riscos.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildRiscosList()),
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
            const SizedBox(height: 8),
            Text(
              'Clique em "Novo Risco" para começar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiscosList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _riscos.length,
      itemBuilder: (context, index) {
        final risco = _riscos[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              Icons.warning_amber_outlined, 
              color: Theme.of(context).colorScheme.primary
            ),
            title: Text(
              risco.nomeRiscos,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('Codigo ${risco.codigoRiscos}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined),
                  tooltip: 'Visualizar',
                  onPressed: () => _showDrawer(risco: risco, viewOnly: true),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar',
                  onPressed: () => _showDrawer(risco: risco),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Excluir',
                  onPressed: () => _deleteRisco(risco),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}