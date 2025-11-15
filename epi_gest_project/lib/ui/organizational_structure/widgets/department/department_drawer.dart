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
  final _descricaoController = TextEditingController();
  final _unidadeVinculada = TextEditingController();

  bool get _isEditing => widget.departmentToEdit != null && !widget.view;
  bool get _isAdding => widget.departmentToEdit == null && !widget.view;
  bool get _isViewing => widget.view;
  bool _isSaving = false;

  // Lista de unidades disponíveis
  final List<String> _unidadesDisponiveis = [
    'Matriz Araras',
    'Filial São Paulo', 
    'Filial Rio de Janeiro',
    'Filial Belo Horizonte',
    'Filial Curitiba',
    'Filial Porto Alegre',
    'Filial Brasília',
    'Filial Salvador',
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing || _isViewing) {
      _populateForm();
    }
  }

  void _populateForm() {
    final department = widget.departmentToEdit!;
    _descricaoController.text = department.descricao;
    _unidadeVinculada.text = department.unidade;
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _unidadeVinculada.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final departmentData = Department(
      id: widget.departmentToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      codigo: '', // Código removido
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

  // ------------------------------
  // HEADER - MANTIDO PADRÃO
  // ------------------------------

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
  // FORM - SEM CÓDIGO E COM AUTOCORRECT FUNCIONAL
  // ------------------------------

  Widget _buildForm(ThemeData theme) {
    final isEnabled = !_isViewing;

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo Descrição
            _buildCustomTextField(
              controller: _descricaoController,
              label: 'Descrição do Setor*',
              hint: 'Ex: Produção, Administrativo, RH, Financeiro',
              icon: Icons.work_outline,
              enabled: isEnabled,
              validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 20),

            // Campo Unidade Vinculada - CORRIGIDO
            _buildCustomDropdown(
              controller: _unidadeVinculada,
              label: 'Unidade Vinculada*',
              hint: 'Selecione a unidade',
              icon: Icons.workspaces_outlined,
              enabled: isEnabled,
              items: _unidadesDisponiveis,
              validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------
  // COMPONENTES DE FORMULÁRIO MODERNOS
  // ------------------------------

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool enabled,
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

  Widget _buildCustomDropdown({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool enabled,
    required List<String> items,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    String? selectedValue = controller.text.isEmpty ? null : controller.text;

    return DropdownButtonFormField<String>(
      value: selectedValue,
      items: items.map((String unidade) {
        return DropdownMenuItem(
          value: unidade,
          child: Text(unidade),
        );
      }).toList(),
      onChanged: enabled ? (String? newValue) {
        setState(() {
          selectedValue = newValue;
          controller.text = newValue ?? '';
        });
      } : null,
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
        suffixIcon: enabled ? const Icon(Icons.arrow_drop_down_outlined) : null,
      ),
      icon: enabled ? Icon(
        Icons.arrow_drop_down_outlined,
        color: theme.colorScheme.onSurfaceVariant,
      ) : null,
      borderRadius: BorderRadius.circular(12),
      validator: validator,
    );
  }

  // ------------------------------
  // FOOTER (EDITAR) - BOTÕES MODERNOS
  // ------------------------------

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
          // Botão Cancelar - Estilo moderno
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.close, size: 18),
                    const SizedBox(width: 8),
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
          
          // Botão Principal - Estilo moderno
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
                            _isEditing ? "Salvar Alterações" : "Adicionar Departamento",
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