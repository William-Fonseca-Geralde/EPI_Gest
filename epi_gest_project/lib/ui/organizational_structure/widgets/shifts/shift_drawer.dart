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
    _nomeController.text = shift.nome;
    _entrada = shift.entrada;
    _saida = shift.saida;
    _almocoInicio = shift.almocoInicio;
    _almocoFim = shift.almocoFim;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final shiftData = Shift(
    id: widget.shiftToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    codigo: '', // Campo vazio temporariamente
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
      widthFactor: 0.4,
      header: _buildHeader(theme),
      body: _buildForm(theme),
      footer: _isViewing ? _buildViewFooter(theme) : _buildEditFooter(theme),
    );
  }

  // ------------------------------
  // HEADER - PADRÃO MODERNO
  // ------------------------------

  Widget _buildHeader(ThemeData theme) {
    String title;
    String subtitle;
    IconData icon;

    if (_isViewing) {
      title = 'Visualizar Turno';
      subtitle = 'Informações completas do turno';
      icon = Icons.visibility_outlined;
    } else if (_isEditing) {
      title = 'Editar Turno';
      subtitle = 'Altere os dados do turno';
      icon = Icons.edit_outlined;
    } else {
      title = 'Adicionar Turno';
      subtitle = 'Preencha os dados do novo turno';
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onPrimaryContainer,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close),
            tooltip: 'Fechar',
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------
  // FORM - CAMPOS MODERNOS COM SCROLL
  // ------------------------------

  Widget _buildForm(ThemeData theme) {
    final isEnabled = !_isViewing;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo Nome (único campo de texto agora)
            _buildModernTextField(
              controller: _nomeController,
              label: 'Nome do Turno*',
              hint: 'Ex: Turno Administrativo, Turno Produção, Manhã, Tarde',
              enabled: isEnabled,
              icon: Icons.work_outline,
              validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 24),

            // Seção Horários da Jornada
            _buildSectionHeader(
              title: 'Horários da Jornada',
              icon: Icons.schedule_outlined,
              theme: theme,
            ),
            const SizedBox(height: 16),

            _buildModernTimePickerTile(
              label: 'Horário de Entrada',
              time: _entrada,
              enabled: isEnabled,
              onTap: () => _selectTime(context, _entrada, (time) => _entrada = time),
            ),
            const SizedBox(height: 16),

            _buildModernTimePickerTile(
              label: 'Horário de Saída',
              time: _saida,
              enabled: isEnabled,
              onTap: () => _selectTime(context, _saida, (time) => _saida = time),
            ),
            const SizedBox(height: 24),

            // Seção Intervalo de Almoço
            _buildSectionHeader(
              title: 'Intervalo de Almoço',
              icon: Icons.restaurant_outlined,
              theme: theme,
            ),
            const SizedBox(height: 16),

            _buildModernTimePickerTile(
              label: 'Início do Almoço',
              time: _almocoInicio,
              enabled: isEnabled,
              onTap: () => _selectTime(context, _almocoInicio, (time) => _almocoInicio = time),
            ),
            const SizedBox(height: 16),

            _buildModernTimePickerTile(
              label: 'Fim do Almoço',
              time: _almocoFim,
              enabled: isEnabled,
              onTap: () => _selectTime(context, _almocoFim, (time) => _almocoFim = time),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool enabled,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      enabled: enabled,
      style: TextStyle(
        color: enabled ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.6),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        enabled: enabled,
        filled: !enabled,
        fillColor: !enabled ? theme.colorScheme.surfaceVariant.withOpacity(0.3) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTimePickerTile({
    required String label,
    required TimeOfDay time,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.access_time_outlined,
            color: theme.colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            time.format(context),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        onTap: enabled ? onTap : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }


  Widget _buildEditFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                icon: Icon(Icons.close),
                onPressed: _isSaving ? null : widget.onClose,
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurface,
                  side: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.5),
                  ),
                  backgroundColor: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Cancelar",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _isSaving ? null : _handleSave,
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Salvando...",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isEditing ? Icons.save_outlined : Icons.add,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isEditing ? "Salvar Alterações" : "Adicionar Turno",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------
  // FOOTER (VIEW) - BOTÃO MODERNIZADO
  // ------------------------------

  Widget _buildViewFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: widget.onClose,
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.close, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Fechar",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}