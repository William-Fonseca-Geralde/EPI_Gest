import 'package:epi_gest_project/data/services/organizational_structure/vinculo_repository.dart';
import 'package:epi_gest_project/domain/models/vinculo_model.dart';
import 'package:epi_gest_project/ui/organizational_structure/widgets/vinculo/vinculo_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VinculoWidget extends StatefulWidget {
  const VinculoWidget({super.key});

  @override
  State<VinculoWidget> createState() => VinculoWidgetState();
}

class VinculoWidgetState extends State<VinculoWidget> {
  List<VinculoModel> _vinculos = [];
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
      final repository = Provider.of<VinculoRepository>(context, listen: false);
      final result = await repository.getAllVinculos();

      if (mounted) {
        setState(() {
          _vinculos = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Erro ao carregar vinculos: $e';
        });
      }
    }
  }

  void showAddDrawer() {
    _showDrawer();
  }

  void _showDrawer({VinculoModel? vinculo, bool viewOnly = false}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Gerenciar Vínculo',
      pageBuilder: (context, _, __) => VinculoDrawer(
        vinculoToEdit: vinculo,
        view: viewOnly,
        onClose: () => Navigator.of(context).pop(),
        onSave: (vinculoSalvo) {
          _loadData();
        },
      ),
    );
  }

  Future<void> _deleteVinculo(VinculoModel vinculo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o vinculo "${vinculo.nomeVinculo}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
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
        final repository = Provider.of<VinculoRepository>(context, listen: false);
        await repository.delete(vinculo.id!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vinculo excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir: $e'),
            backgroundColor: Colors.red,
          ),
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
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text("Tentar Novamente"),
            ),
          ],
        ),
      );
    }

    if (_vinculos.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Expanded(child: _buildVinculosList())],
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
            const SizedBox(height: 8),
            Text(
              'Clique em "Novo Vinculo" para começar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVinculosList() {
    return ListView.builder(
      itemCount: _vinculos.length,
      itemBuilder: (context, index) {
        final vinculo = _vinculos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              Icons.assignment_ind_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              vinculo.nomeVinculo,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined),
                  tooltip: 'Visualizar',
                  onPressed: () => _showDrawer(vinculo: vinculo, viewOnly: true),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar',
                  onPressed: () => _showDrawer(vinculo: vinculo),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Excluir',
                  onPressed: () => _deleteVinculo(vinculo),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}