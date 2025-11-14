import 'package:epi_gest_project/domain/models/organizational/department_model.dart';
import 'package:epi_gest_project/ui/widgets/base_drawer.dart';
import 'package:epi_gest_project/ui/widgets/form_fields.dart';
import 'package:flutter/material.dart';

class DepartmentDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Department) onSave;
  final Department? departmentToEdit;
  final bool view;

  const DepartmentDrawer({
    super.key,
    required this.onClose,
    required this.onSave,
    this.departmentToEdit,
    this.view = false,
  });

  @override
  State<DepartmentDrawer> createState() => _DepartmentDrawerState();
}

class _DepartmentDrawerState extends State<DepartmentDrawer> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _unidadeVinculada = TextEditingController();

  bool get _isEditing => widget.departmentToEdit != null && !widget.view;
  bool get _isAdding => widget.departmentToEdit == null && !widget.view;
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
    final department = widget.departmentToEdit!;
    _codigoController.text = department.codigo;
    _descricaoController.text = department.descricao;
    _unidadeVinculada.text = department.unidade;
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

    final departmentData = Department(
      id: widget.departmentToEdit?.id ?? _codigoController.text,
      codigo: _codigoController.text,
      descricao: _descricaoController.text,
      unidade: _unidadeVinculada.text,
    );

    widget.onSave(departmentData);
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
      widthFactor: 0.4,
    );
  }

  Widget _buildHeader(ThemeData theme) {
    String title;
    String subtitle;
    IconData icon;

    if (_isViewing) {
      title = 'Visualizar Departamento';
      subtitle =
          'Informações do Departamento de ${widget.departmentToEdit?.descricao ?? ""}';
      icon = Icons.visibility_outlined;
    } else if (_isEditing) {
      title = 'Editar Departamento';
      subtitle = 'Altere os dados do Departamento';
      icon = Icons.edit_outlined;
    } else {
      title = 'Adicionar Departamento';
      subtitle = 'Preencha os dados do novo Departamento';
      icon = Icons.add_business_outlined;
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
          ),
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
          spacing: 24,
          children: [
            CustomTextField(
              controller: _codigoController,
              label: 'Codigo do Setor',
              hint: 'Ex: PROD001',
              icon: Icons.qr_code_outlined,
            ),
            CustomTextField(
              controller: _descricaoController,
              label: 'Descrição do Setor',
              hint: 'Ex: Produção, Administrativo, RH',
              icon: Icons.work_outline,
            ),
            CustomAutocompleteField(
              controller: _unidadeVinculada,
              label: 'Unidade Vinculada',
              hint: '',
              icon: Icons.workspaces_outline,
              suggestions: ['Matriz', 'Filial SP', 'Filial RJ', 'Filial MG'],
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
