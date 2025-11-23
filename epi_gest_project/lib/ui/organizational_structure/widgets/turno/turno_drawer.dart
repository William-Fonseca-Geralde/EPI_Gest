import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/data/services/turno_repository.dart';
import 'package:epi_gest_project/domain/models/turno_model.dart';
import 'package:epi_gest_project/ui/widgets/base_drawer.dart';
import 'package:epi_gest_project/ui/widgets/form_fields.dart';
import 'package:epi_gest_project/ui/widgets/info_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TurnoDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final Function(TurnoModel) onSave;
  final TurnoModel? turnoToEdit;
  final bool view;

  const TurnoDrawer({
    super.key,
    required this.onClose,
    required this.onSave,
    this.turnoToEdit,
    this.view = false,
  });

  @override
  State<TurnoDrawer> createState() => _TurnoDrawerState();
}

class _TurnoDrawerState extends State<TurnoDrawer> {
  final _formKey = GlobalKey<FormState>();
  final _turnoController = TextEditingController();

  // Estado para os horários
  final _entradaController = TextEditingController();
  final _saidaController = TextEditingController();
  final _almocoInicioController = TextEditingController();
  final _almocoFimController = TextEditingController();

  bool get _isEditing => widget.turnoToEdit != null && !widget.view;
  bool get _isAdding => widget.turnoToEdit == null && !widget.view;
  bool get _isViewing => widget.view;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (_isEditing || _isViewing) _populateForm();
    if (_isAdding) _populateTime();
  }

  void _populateTime() {
    _entradaController.text = "08:00";
    _saidaController.text = "18:00";
    _almocoInicioController.text = "12:00";
    _almocoFimController.text = "13:00";
  }

  void _populateForm() {
    final turno = widget.turnoToEdit!;
    _turnoController.text = turno.turno;
    _entradaController.text = turno.horaEntrada;
    _saidaController.text = turno.horaSaida;
    _almocoInicioController.text = turno.inicioAlmoco;
    _almocoFimController.text = turno.fimAlomoco;
  }

  @override
  void dispose() {
    _turnoController.dispose();
    _entradaController.dispose();
    _saidaController.dispose();
    _almocoInicioController.dispose();
    _almocoFimController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final turnoModel = TurnoModel(
      id: widget.turnoToEdit?.id,
      turno: _turnoController.text.trim(),
      horaEntrada: _entradaController.text.trim(),
      horaSaida: _saidaController.text.trim(),
      inicioAlmoco: _almocoInicioController.text.trim(),
      fimAlomoco: _almocoFimController.text.trim(),
    );

    try {
      final repository = Provider.of<TurnoRepository>(context, listen: false);

      if (widget.turnoToEdit != null) {
        await repository.update(widget.turnoToEdit!.id!, turnoModel.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Turno atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await repository.create(turnoModel);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Turno criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      widget.onSave(turnoModel);
      widget.onClose();
    } on AppwriteException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _selectTimeModal(
    BuildContext context,
    String initialTime,
    Function(TimeOfDay) onTimeSelected,
  ) async {
    final time = initialTime.split(":");
    final correctedTime = TimeOfDay(hour: int.parse(time[0]), minute: int.parse(time[1]));
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: correctedTime,
    );
    if (picked != null && picked != correctedTime) {
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

  Widget _buildForm(ThemeData theme) {
    final isEnabled = !_isViewing;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            CustomTextField(
              controller: _turnoController,
              label: 'Nome do Turno',
              hint: 'Ex: Turno Administrativo, Turno Produção, Manhã, Tarde',
              enabled: isEnabled,
              icon: Icons.work_outline,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
            ),
            InfoSection(
              title: 'Horários da Jornada',
              icon: Icons.schedule_outlined,
              child: Column(
                spacing: 20,
                children: [
                  CustomTimeField(
                    label: 'Horário de Entrada',
                    time: _entradaController.text,
                    enabled: isEnabled,
                    onTap: () => _selectTimeModal(
                      context,
                      _entradaController.text,
                      (time) => _entradaController.text = time.format(context),
                    ),
                  ),
                  CustomTimeField(
                    label: 'Horário de Saída',
                    time: _saidaController.text,
                    enabled: isEnabled,
                    onTap: () => _selectTimeModal(
                      context,
                      _saidaController.text,
                      (time) => _saidaController.text = time.format(context),
                    ),
                  ),
                ],
              ),
            ),
            InfoSection(
              title: 'Intervalo de Almoço',
              icon: Icons.restaurant_outlined,
              child: Column(
                spacing: 20,
                children: [
                  CustomTimeField(
                    label: 'Início do Almoço',
                    time: _almocoInicioController.text,
                    enabled: isEnabled,
                    onTap: () => _selectTimeModal(
                      context,
                      _almocoInicioController.text,
                      (time) => _almocoInicioController.text = time.format(context),
                    ),
                  ),
                  CustomTimeField(
                    label: 'Fim do Almoço',
                    time: _almocoFimController.text,
                    enabled: isEnabled,
                    onTap: () => _selectTimeModal(
                      context,
                      _almocoFimController.text,
                      (time) => _almocoFimController.text = time.format(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                            style: TextStyle(fontWeight: FontWeight.w600),
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
                            _isEditing
                                ? "Salvar Alterações"
                                : "Adicionar Turno",
                            style: const TextStyle(fontWeight: FontWeight.w600),
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
