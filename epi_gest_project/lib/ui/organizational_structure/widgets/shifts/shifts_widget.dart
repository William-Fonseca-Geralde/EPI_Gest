import 'package:epi_gest_project/domain/models/organizational/shifts_model.dart';
import 'package:epi_gest_project/ui/organizational_structure/widgets/shifts/shift_drawer.dart';
import 'package:flutter/material.dart';

class ShiftsWidget extends StatefulWidget {
  const ShiftsWidget({super.key});

  @override
  State<ShiftsWidget> createState() => ShiftsWidgetState();
}

class ShiftsWidgetState extends State<ShiftsWidget> {
  final _formKey = GlobalKey<FormState>();

  final List<Shift> _turnosCadastrados = [
    Shift(
      id: '1',
      codigo: '', // Campo vazio temporariamente
      nome: 'Manhã',
      entrada: const TimeOfDay(hour: 6, minute: 0),
      saida: const TimeOfDay(hour: 14, minute: 0),
      almocoInicio: const TimeOfDay(hour: 12, minute: 0),
      almocoFim: const TimeOfDay(hour: 13, minute: 0),
    ),
    Shift(
      id: '2',
      codigo: '', // Campo vazio temporariamente
      nome: 'Tarde',
      entrada: const TimeOfDay(hour: 14, minute: 0),
      saida: const TimeOfDay(hour: 22, minute: 0),
      almocoInicio: const TimeOfDay(hour: 18, minute: 0),
      almocoFim: const TimeOfDay(hour: 19, minute: 0),
    ),
];

  void showAddDrawer() {
    _showShiftDrawer();
  }

  void _showShiftDrawer({Shift? turno, bool viewOnly = false}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Gerenciar Turno',
      pageBuilder: (context, _, __) => ShiftDrawer(
        shiftToEdit: turno,
        view: viewOnly,
        onClose: () => Navigator.of(context).pop(),
        onSave: (turnoSalvo) {
          setState(() {
            if (turno != null) { // Editando
              final index = _turnosCadastrados.indexWhere((t) => t.id == turnoSalvo.id);
              if (index != -1) _turnosCadastrados[index] = turnoSalvo;
            } else { // Adicionando
              _turnosCadastrados.add(turnoSalvo);
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Turno ${turno != null ? 'atualizado' : 'cadastrado'} com sucesso!'),
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
        if (_turnosCadastrados.isEmpty)
          _buildEmptyState()
        else
          Expanded(child: _buildShiftsList()),
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
              'Nenhum turno cadastrado',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftsList() {
    return ListView.builder(
      itemCount: _turnosCadastrados.length,
      itemBuilder: (context, index) {
        final turno = _turnosCadastrados[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              Icons.access_time_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              turno.nome,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${turno.entrada.format(context)} - ${turno.saida.format(context)}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined),
                  tooltip: 'Visualizar',
                  onPressed: () => _showShiftDrawer(turno: turno, viewOnly: true),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar',
                  onPressed: () => _showShiftDrawer(turno: turno),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Excluir',
                  onPressed: () => _showDeleteConfirmation(turno),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(Shift turno) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text(
              'Tem certeza que deseja excluir o turno "${turno.nome}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _deleteTurno(turno);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Excluir',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteTurno(Shift turno) {
    setState(() {
      _turnosCadastrados.removeWhere((t) => t.id == turno.id);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Turno "${turno.nome}" excluído com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}