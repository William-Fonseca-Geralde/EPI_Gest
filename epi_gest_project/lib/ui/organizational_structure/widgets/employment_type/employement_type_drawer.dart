import 'package:epi_gest_project/domain/models/organizational/employement_type_model.dart';
import 'package:epi_gest_project/ui/widgets/base_drawer.dart';
import 'package:flutter/material.dart';

class EmploymentTypeDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final Function(EmploymentType) onSave;
  final EmploymentType? typeToEdit;
  final bool view;

  const EmploymentTypeDrawer({
    super.key,
    required this.onClose,
    required this.onSave,
    this.typeToEdit,
    this.view = false,
  });

  @override
  State<EmploymentTypeDrawer> createState() => _EmploymentTypeDrawerState();
}

class _EmploymentTypeDrawerState extends State<EmploymentTypeDrawer> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _descricaoController = TextEditingController();

  bool get _isEditing => widget.typeToEdit != null && !widget.view;
  bool get _isViewing => widget.view;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (_isEditing || _isViewing) {
      _populateForm();
    }
  }

  void _populateForm() {
    final type = widget.typeToEdit!;
    _codigoController.text = type.codigo;
    _descricaoController.text = type.descricao;
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final typeData = EmploymentType(
      id: widget.typeToEdit?.id ?? _codigoController.text,
      codigo: _codigoController.text,
      descricao: _descricaoController.text,
    );

    widget.onSave(typeData);
    widget.onClose();

    if (mounted) {
      setState(() => _isSaving = false);
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
      title = 'Visualizar Vínculo';
      icon = Icons.visibility_outlined;
    } else if (_isEditing) {
      title = 'Editar Vínculo';
      icon = Icons.edit_outlined;
    } else {
      title = 'Adicionar Vínculo';
      icon = Icons.link_outlined;
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
              decoration: const InputDecoration(
                labelText: 'Código do Vínculo*',
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
            ),
            TextFormField(
              controller: _descricaoController,
              enabled: isEnabled,
              decoration: const InputDecoration(
                labelText: 'Descrição do Vínculo*',
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
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
