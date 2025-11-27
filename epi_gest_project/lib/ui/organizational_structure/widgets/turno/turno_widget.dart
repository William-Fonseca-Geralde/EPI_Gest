import 'package:epi_gest_project/data/services/organizational_structure/turno_repository.dart';
import 'package:epi_gest_project/domain/models/organizational_structure/turno_model.dart';
import 'package:epi_gest_project/ui/organizational_structure/widgets/turno/turno_drawer.dart';
import 'package:epi_gest_project/ui/widgets/builds_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TurnoWidget extends StatefulWidget {
  const TurnoWidget({super.key});

  @override
  State<TurnoWidget> createState() => TurnoWidgetState();
}

class TurnoWidgetState extends State<TurnoWidget> {
  List<TurnoModel> _turnos = [];
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
      final repository = Provider.of<TurnoRepository>(context, listen: false);
      final result = await repository.getAllTurnos();

      if (mounted) {
        setState(() {
          _turnos = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Erro ao carregar turnos: $e';
        });
      }
    }
  }

  void showAddDrawer() {
    _showDrawer();
  }

  void _showDrawer({TurnoModel? turno, bool viewOnly = false}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Gerenciar Turno',
      pageBuilder: (context, _, __) => TurnoDrawer(
        turnoToEdit: turno,
        view: viewOnly,
        onClose: () => Navigator.of(context).pop(),
        onSave: (turnoSalvo) {
          _loadData();
        },
      ),
    );
  }

  Future<void> _deleteTurno(TurnoModel turno) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o turno "${turno.turno}"?',
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
        final repository = Provider.of<TurnoRepository>(context, listen: false);
        await repository.delete(turno.id!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Turno excluído com sucesso!'),
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
      return Column(
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
      );
    }

    if (_turnos.isEmpty) {
      return BuildEmpty(
        title: 'Nenhum turno cadastrado',
        subtitle: 'Clique em "Novo Turno" para começar',
        icon: Icons.access_time_outlined,
        titleDrawer: "Novo Turno",
        drawer: _showDrawer,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Expanded(child: _buildTurnosList())],
    );
  }

  Widget _buildTurnosList() {
    return ListView.builder(
      itemCount: _turnos.length,
      itemBuilder: (context, index) {
        final turno = _turnos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              Icons.access_time_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              turno.turno,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${turno.horaEntrada} - ${turno.horaSaida}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined),
                  tooltip: 'Visualizar',
                  onPressed: () => _showDrawer(turno: turno, viewOnly: true),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar',
                  onPressed: () => _showDrawer(turno: turno),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Excluir',
                  onPressed: () => _deleteTurno(turno),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
