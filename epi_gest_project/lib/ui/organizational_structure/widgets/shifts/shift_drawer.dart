import 'package:epi_gest_project/domain/models/organizational/shifts_model.dart';
import 'package:epi_gest_project/ui/widgets/base_drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShiftDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Shift) onSave;
  final Shift? shiftToEdit;
  final bool view;

  const ShiftDrawer({
    super.key,
    required this.onClose,
    required this.onSave,
    this.shiftToEdit,
    this.view = false,
  });

  @override
  State<ShiftDrawer> createState() => _ShiftDrawerState();
}

class _ShiftDrawerState extends State<ShiftDrawer> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _nomeController = TextEditingController();

  // Estado para os horários
  late TimeOfDay _entrada;
  late TimeOfDay _saida;
  late TimeOfDay _almocoInicio;
  late TimeOfDay _almocoFim;

  bool get _isEditing => widget.shiftToEdit != null && !widget.view;
  bool get _isViewing => widget.view;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (_isEditing || _isViewing) {
      _populateForm();
    } else {
      // Valores padrão para um novo turno
      _entrada = const TimeOfDay(hour: 8, minute: 0);
      _saida = const TimeOfDay(hour: 18, minute: 0);
      _almocoInicio = const TimeOfDay(hour: 12, minute: 0);
      _almocoFim = const TimeOfDay(hour: 13, minute: 0);
    }
  }

  void _populateForm() {
    final shift = widget.shiftToEdit!;
    _codigoController.text = shift.codigo;
    _nomeController.text = shift.nome;
    _entrada = shift.entrada;
    _saida = shift.saida;
    _almocoInicio = shift.almocoInicio;
    _almocoFim = shift.almocoFim;
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final shiftData = Shift(
      id: widget.shiftToEdit?.id ?? _codigoController.text,
      codigo: _codigoController.text,
      nome: _nomeController.text,
      entrada: _entrada,
      saida: _saida,
      almocoInicio: _almocoInicio,
      almocoFim: _almocoFim,
    );

    widget.onSave(shiftData);
    widget.onClose();

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  // Função auxiliar para mostrar o seletor de tempo
  Future<void> _selectTime(
    BuildContext context,
    TimeOfDay initialTime,
    Function(TimeOfDay) onTimeSelected,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null && picked != initialTime) {
      setState(() {
        onTimeSelected(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BaseDrawer(
      onClose: widget.onClose,
      header: _buildHeader(theme),
      body: _buildForm(theme),
      footer: _isViewing ? _buildViewFooter(theme) : _buildEditFooter(theme),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    String title;
    IconData icon;

    if (_isViewing) {
      title = 'Visualizar Turno';
      icon = Icons.visibility_outlined;
    } else if (_isEditing) {
      title = 'Editar Turno';
      icon = Icons.edit_outlined;
    } else {
      title = 'Adicionar Turno';
      icon = Icons.assignment_ind_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
          IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close)),
        ],
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    final isEnabled = !_isViewing;
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            TextFormField(
              controller: _codigoController,
              enabled: isEnabled,
              decoration: const InputDecoration(labelText: 'Código do Turno*'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
            ),
            TextFormField(
              controller: _nomeController,
              enabled: isEnabled,
              decoration: const InputDecoration(
                labelText: 'Nome do Turno* (Ex: Turno Administrativo)',
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            Text('Horários da Jornada', style: theme.textTheme.titleMedium),
            const Divider(),
            _buildTimePickerTile(
              label: 'Entrada',
              time: _entrada,
              onTap: isEnabled
                  ? () => _selectTime(
                      context,
                      _entrada,
                      (time) => _entrada = time,
                    )
                  : null,
            ),
            _buildTimePickerTile(
              label: 'Saída',
              time: _saida,
              onTap: isEnabled
                  ? () => _selectTime(context, _saida, (time) => _saida = time)
                  : null,
            ),
            const SizedBox(height: 16),
            Text('Intervalo de Almoço', style: theme.textTheme.titleMedium),
            const Divider(),
            _buildTimePickerTile(
              label: 'Início do Almoço',
              time: _almocoInicio,
              onTap: isEnabled
                  ? () => _selectTime(
                      context,
                      _almocoInicio,
                      (time) => _almocoInicio = time,
                    )
                  : null,
            ),
            _buildTimePickerTile(
              label: 'Fim do Almoço',
              time: _almocoFim,
              onTap: isEnabled
                  ? () => _selectTime(
                      context,
                      _almocoFim,
                      (time) => _almocoFim = time,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para os campos de horário
  Widget _buildTimePickerTile({
    required String label,
    required TimeOfDay time,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.access_time_outlined),
      title: Text(label),
      trailing: Text(
        time.format(context),
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildEditFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSaving ? null : widget.onClose,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _handleSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(_isEditing ? Icons.save : Icons.add),
              label: Text(
                _isSaving
                    ? 'Salvando...'
                    : (_isEditing ? 'Salvar Alterações' : 'Adicionar'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onClose,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Fechar'),
            ),
          ),
        ],
      ),
    );
  }
}
