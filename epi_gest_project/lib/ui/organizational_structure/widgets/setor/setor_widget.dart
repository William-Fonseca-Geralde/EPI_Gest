import 'package:epi_gest_project/data/services/organizational_structure/setor_repository.dart';
import 'package:epi_gest_project/domain/models/setor_model.dart';
import 'package:epi_gest_project/ui/widgets/builds_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'setor_drawer.dart';

class SetorWidget extends StatefulWidget {
  const SetorWidget({super.key});

  @override
  State<SetorWidget> createState() => SetorWidgetState();
}

class SetorWidgetState extends State<SetorWidget> {
  List<SetorModel> _setores = [];
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
      final repository = Provider.of<SetorRepository>(context, listen: false);
      final result = await repository.getAllSetores();

      if (mounted) {
        setState(() {
          _setores = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Erro ao carregar setores: $e';
        });
      }
    }
  }

  void showAddDrawer() {
    _showDrawer();
  }

  void _showDrawer({SetorModel? setor, bool viewOnly = false}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Gerenciar Departamento',
      pageBuilder: (context, _, __) => SetorDrawer(
        setorToEdit: setor,
        view: viewOnly,
        onClose: () => Navigator.of(context).pop(),
        onSave: (savedSetor) {
          _loadData();
        },
      ),
    );
  }

  Future<void> _deleteSetor(SetorModel setor) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o setor "${setor.nomeSetor}"?',
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
        final repository = Provider.of<SetorRepository>(context, listen: false);
        await repository.delete(setor.id!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Setor excluído com sucesso!'),
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
      return Column(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [CircularProgressIndicator(), Text('Carregando dados...')],
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            Text(_error!),
            FilledButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text("Tentar Novamente"),
            ),
          ],
        ),
      );
    }

    if (_setores.isEmpty) {
      return BuildEmpty(
        title: 'Nenhum setor cadastrado',
        subtitle: 'Clique em "Novo Setor" para começar',
        icon: Icons.work_outline,
        titleDrawer: "Novo Setor",
        drawer: _showDrawer,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Expanded(child: _buildSetoresList())],
    );
  }

  Widget _buildSetoresList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _setores.length,
      itemBuilder: (context, index) {
        final setor = _setores[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              Icons.work_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              setor.nomeSetor,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('Unidade: ${setor.codigoSetor}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined),
                  tooltip: 'Visualizar',
                  onPressed: () => _showDrawer(setor: setor, viewOnly: true),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar',
                  onPressed: () => _showDrawer(setor: setor),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Excluir',
                  onPressed: () {
                    _deleteSetor(setor);
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
