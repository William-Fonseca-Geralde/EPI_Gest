import 'package:epi_gest_project/domain/models/organizational/unit_model.dart';
import 'package:epi_gest_project/ui/widgets/base_drawer.dart';
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
    if (_isEditing || _isViewing) {
      _populateForm();
    }
  }

  void _populateForm() {
    final unit = widget.unitToEdit!;
    _nomeController.text = unit.nome;
    _cnpjController.text = unit.cnpj;
    _enderecoController.text = unit.endereco;
    _responsavelController.text = unit.responsavel;
    _tipoUnidade = unit.tipo;
    _statusAtiva = unit.statusAtiva;
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
    await Future.delayed(const Duration(milliseconds: 500));

    final unitData = Unit(
      id: widget.unitToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nome: _nomeController.text,
      cnpj: _cnpjController.text,
      endereco: _enderecoController.text,
      tipo: _tipoUnidade,
      responsavel: _responsavelController.text,
      statusAtiva: _statusAtiva,
    );

    widget.onSave(unitData);
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
      title = 'Visualizar Unidade';
      icon = Icons.visibility_outlined;
    } else if (_isEditing) {
      title = 'Editar Unidade';
      icon = Icons.edit_outlined;
    } else {
      title = 'Adicionar Unidade';
      icon = Icons.add_business_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
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
              controller: _nomeController,
              enabled: isEnabled,
              decoration: const InputDecoration(labelText: 'Nome da Unidade*'),
              validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
            ),
            TextFormField(
              controller: _cnpjController,
              enabled: isEnabled,
              decoration: const InputDecoration(labelText: 'CNPJ*'),
              validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
            ),
            TextFormField(
              controller: _enderecoController,
              enabled: isEnabled,
              decoration: const InputDecoration(labelText: 'Endereço Completo*'),
              maxLines: 2,
              validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
            ),
            DropdownButtonFormField<String>(
              value: _tipoUnidade,
              items: ['Matriz', 'Filial'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: isEnabled ? (value) => setState(() => _tipoUnidade = value!) : null,
              decoration: const InputDecoration(labelText: 'Tipo de Unidade*'),
            ),
            TextFormField(
              controller: _responsavelController,
              enabled: isEnabled,
              decoration: const InputDecoration(labelText: 'Responsável Local*'),
              validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
            ),
            Row(
              children: [
                const Text('Status da Unidade:'),
                const SizedBox(width: 12),
                Switch(
                  value: _statusAtiva,
                  onChanged: isEnabled ? (value) => setState(() => _statusAtiva = value) : null,
                ),
                Text(
                  _statusAtiva ? 'Ativa' : 'Inativa',
                  style: TextStyle(color: _statusAtiva ? Colors.green : Colors.red, fontWeight: FontWeight.w500),
                ),
              ],
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
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(child: OutlinedButton(onPressed: _isSaving ? null : widget.onClose, child: const Text('Cancelar'))),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _handleSave,
              icon: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(_isEditing ? Icons.save : Icons.add),
              label: Text(_isSaving ? 'Salvando...' : (_isEditing ? 'Salvar Alterações' : 'Adicionar')),
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
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(child: OutlinedButton(onPressed: widget.onClose, child: const Text('Fechar'))),
        ],
      ),
    );
  }
}
