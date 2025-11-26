import 'package:epi_gest_project/data/services/organizational_structure/cargo_repository.dart';
import 'package:epi_gest_project/domain/models/cargo_model.dart';
import 'package:epi_gest_project/ui/organizational_structure/widgets/cargo/cargo_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CargoWidget extends StatefulWidget {
  const CargoWidget({super.key});

  @override
  State<CargoWidget> createState() => CargoWidgetState();
}

class CargoWidgetState extends State<CargoWidget> {
  List<CargoModel> _cargos = [];
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
      final repository = Provider.of<CargoRepository>(context, listen: false);
      final result = await repository.getAllCargos();
      
      if (mounted) {
        setState(() {
          _cargos = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Erro ao carregar cargos: $e';
        });
      }
    }
  }

  void showAddDrawer() {
    _showDrawer();
  }

  void _showDrawer({CargoModel? cargo, bool viewOnly = false}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Gerenciar Cargos',
      pageBuilder: (context, _, __) => CargoDrawer(
        cargoToEdit: cargo,
        view: viewOnly,
        onClose: () => Navigator.of(context).pop(),
        onSave: (savedRole) {
          _loadData();
        },
      ),
    );
  }

  Future<void> _deleteCargo(CargoModel cargo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir o cargo "${cargo.nomeCargo}"?'),
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
        final repository = Provider.of<CargoRepository>(context, listen: false);
        await repository.delete(cargo.id!);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cargo excluído com sucesso!'), backgroundColor: Colors.green),
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

    if (_cargos.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildCargosList()),
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
            const SizedBox(height: 8),
            Text(
              'Clique em "Novo Cargo" para começar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCargosList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cargos.length,
      itemBuilder: (context, index) {
        final cargo = _cargos[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(Icons.badge_outlined, color: Theme.of(context).colorScheme.primary),
            title: Text(cargo.nomeCargo, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('Código: ${cargo.codigoCargo}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined),
                  tooltip: 'Visualizar',
                  onPressed: () => _showDrawer(cargo: cargo, viewOnly: true),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar',
                  onPressed: () => _showDrawer(cargo: cargo),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Excluir',
                  onPressed: () => _deleteCargo(cargo),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}