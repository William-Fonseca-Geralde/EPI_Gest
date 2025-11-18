import 'package:epi_gest_project/domain/models/organizational/unit_model.dart';
import 'package:epi_gest_project/ui/widgets/base_drawer.dart';
import 'package:epi_gest_project/ui/widgets/form_fields.dart';
import 'package:flutter/material.dart';

class UnitDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Unit) onSave;
  final Unit? unitToEdit;
  final bool view;

  const UnitDrawer({
    super.key,
    required this.onClose,
    required this.onSave,
    this.unitToEdit,
    this.view = false,
  });

  @override
  State<UnitDrawer> createState() => _UnitDrawerState();
}

class _UnitDrawerState extends State<UnitDrawer> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _responsavelController = TextEditingController();

  String _tipoUnidade = 'Matriz';
  bool _statusAtiva = true;

  bool get _isEditing => widget.unitToEdit != null && !widget.view;
  bool get _isViewing => widget.view;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (_isEditing || _isViewing) _populateForm();
  }

  void _populateForm() {
    final u = widget.unitToEdit!;
    _nomeController.text = u.nome;
    _cnpjController.text = u.cnpj;
    _enderecoController.text = u.endereco;
    _responsavelController.text = u.responsavel;
    _tipoUnidade = u.tipo;
    _statusAtiva = u.statusAtiva;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cnpjController.dispose();
    _enderecoController.dispose();
    _responsavelController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final unit = Unit(
      id: widget.unitToEdit?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      nome: _nomeController.text,
      cnpj: _cnpjController.text,
      endereco: _enderecoController.text,
      tipo: _tipoUnidade,
      responsavel: _responsavelController.text,
      statusAtiva: _statusAtiva,
    );

    widget.onSave(unit);
    widget.onClose();

    if (mounted) setState(() => _isSaving = false);
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
  // HEADER
  // ------------------------------

  Widget _buildHeader(ThemeData theme) {
    String title;
    String subtitle;
    IconData icon;

    if (_isViewing) {
      title = "Visualizar Unidade";
      subtitle = "Informações completas da unidade";
      icon = Icons.visibility_outlined;
    } else if (_isEditing) {
      title = "Editar Unidade";
      subtitle = "Altere os dados da unidade";
      icon = Icons.edit_outlined;
    } else {
      title = "Adicionar Unidade";
      subtitle = "Preencha os dados da nova unidade";
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
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close),
            tooltip: "Fechar",
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )
        ],
      ),
    );
  }

  // ------------------------------
  // FORM - CAMPOS MODERNIZADOS
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
            CustomTextField(
              controller: _nomeController,
              label: 'Nome da Unidade*',
              hint: '',
              enabled: isEnabled,
              validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              icon: Icons.business_outlined,
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: _cnpjController,
              label: 'CNPJ*',
              hint: '',
              enabled: isEnabled,
              validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: _enderecoController,
              label: 'Endereço Completo*',
              hint: '',
              enabled: isEnabled,
              maxLines: 2,
              validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 20),

            _buildModernDropdown(
              value: _tipoUnidade,
              items: const [
                DropdownMenuItem(value: 'Matriz', child: Text('Matriz')),
                DropdownMenuItem(value: 'Filial', child: Text('Filial')),
              ],
              onChanged: isEnabled ? (v) => setState(() => _tipoUnidade = v!) : null,
              label: 'Tipo de Unidade*',
              icon: Icons.category_outlined,
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: _responsavelController,
              label: 'Responsável Local*',
              hint: '',
              enabled: isEnabled,
              validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              icon: Icons.person_outlined,
            ),
            const SizedBox(height: 20),

            _buildModernSwitch(
              value: _statusAtiva,
              onChanged: isEnabled ? (v) => setState(() => _statusAtiva = v) : null,
              label: 'Status da Unidade',
              activeText: 'Ativa',
              inactiveText: 'Inativa',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernDropdown({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?)? onChanged,
    required String label,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      style: TextStyle(
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        prefixIcon: Icon(
          icon,
          color: theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      icon: Icon(
        Icons.arrow_drop_down_outlined,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      borderRadius: BorderRadius.circular(12),
    );
  }

  Widget _buildModernSwitch({
    required bool value,
    required void Function(bool)? onChanged,
    required String label,
    required String activeText,
    required String inactiveText,
  }) {
    final theme = Theme.of(context);

    return Container(
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
            Icons.toggle_on_outlined,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: MaterialStateProperty.all(theme.colorScheme.onPrimary),
            trackColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return theme.colorScheme.primary;
              }
              return theme.colorScheme.surfaceVariant;
            }),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: value 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value ? activeText : inactiveText,
              style: TextStyle(
                color: value ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
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
          // Botão Cancelar
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
          
          // Botão Principal
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
                            _isEditing ? "Salvar Alterações" : "Adicionar Unidade",
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
  // FOOTER (VIEW)
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