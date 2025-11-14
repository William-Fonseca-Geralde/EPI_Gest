import 'package:epi_gest_project/domain/models/epi/epi_model.dart';
import 'package:epi_gest_project/domain/models/organizational/epi_mapping_model.dart';
import 'package:epi_gest_project/domain/models/organizational/risk_model.dart';
import 'package:epi_gest_project/domain/models/organizational/role_model.dart';
import 'package:epi_gest_project/ui/widgets/base_drawer.dart';
import 'package:flutter/material.dart';

class EpiMappingDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final Function(EpiMapping) onSave;
  final EpiMapping? mappingToEdit;
  final bool view;

  final List<Role> availableRoles;
  final List<Risk> availableRisks;
  final List<EpiModel> availableEpis;

  const EpiMappingDrawer({
    super.key,
    required this.onClose,
    required this.onSave,
    this.mappingToEdit,
    this.view = false,
    required this.availableRoles,
    required this.availableRisks,
    required this.availableEpis,
  });

  @override
  State<EpiMappingDrawer> createState() => _EpiMappingDrawerState();
}

class _EpiMappingDrawerState extends State<EpiMappingDrawer> {
  final _formKey = GlobalKey<FormState>();

  Role? _selectedRole;
  List<MappedRisk> _mappedRisks = [];

  bool get _isEditing => widget.mappingToEdit != null && !widget.view;
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
    final mapping = widget.mappingToEdit!;
    _selectedRole = mapping.role;
    _mappedRisks = mapping.mappedRisks.map((mappedRisk) {
      return MappedRisk(
        risk: mappedRisk.risk,
        requiredEpis: List<EpiModel>.from(mappedRisk.requiredEpis),
      );
    }).toList();
  }

  void _addRisk() {
    final unmappedRisk = widget.availableRisks.firstWhere(
      (risk) => !_mappedRisks.any((mapped) => mapped.risk.id == risk.id),
      orElse: () => widget.availableRisks.first,
    );

    setState(() {
      _mappedRisks.add(MappedRisk(risk: unmappedRisk, requiredEpis: []));
    });
  }

  void _removeRisk(int index) {
    setState(() {
      _mappedRisks.removeAt(index);
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      // Mostra um erro se nenhum cargo foi selecionado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um cargo.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final mappingData = EpiMapping(
      id:
          widget.mappingToEdit?.id ??
          _selectedRole!.id, // Usa o ID do cargo como ID do mapeamento
      role: _selectedRole!,
      mappedRisks: _mappedRisks,
    );

    widget.onSave(mappingData);
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
      title = 'Visualizar Mapeamento';
      icon = Icons.visibility_outlined;
    } else if (_isEditing) {
      title = 'Editar Mapeamento';
      icon = Icons.edit_outlined;
    } else {
      title = 'Adicionar Mapeamento';
      icon = Icons.assignment_turned_in_outlined;
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
            // Seletor de Cargo/Função
            DropdownButtonFormField<Role>(
              initialValue: _selectedRole,
              items: widget.availableRoles
                  .map(
                    (role) => DropdownMenuItem(
                      value: role,
                      child: Text(role.descricao),
                    ),
                  )
                  .toList(),
              onChanged: (_isEditing || !isEnabled)
                  ? null
                  : (value) => setState(() => _selectedRole = value),
              decoration: InputDecoration(
                labelText: 'Cargo / Função*',
                filled:
                    (_isEditing ||
                    !isEnabled), // Fica cinza se estiver editando
              ),
              validator: (value) => value == null ? 'Selecione um cargo' : null,
            ),
            const SizedBox(height: 16),
            Text(
              'Riscos e EPIs Associados',
              style: theme.textTheme.titleMedium,
            ),
            const Divider(),

            if (_mappedRisks.isEmpty && isEnabled)
              Center(
                child: Text(
                  'Nenhum risco adicionado.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _mappedRisks.length,
              itemBuilder: (context, index) {
                return _buildRiskCard(index, isEnabled);
              },
            ),

            if (isEnabled)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar Risco'),
                  onPressed: _addRisk,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskCard(int index, bool isEnabled) {
    final mappedRisk = _mappedRisks[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seletor de Risco
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<Risk>(
                    initialValue: mappedRisk.risk,
                    items: widget.availableRisks
                        .map(
                          (risk) => DropdownMenuItem(
                            value: risk,
                            child: Text(risk.descricao),
                          ),
                        )
                        .toList(),
                    onChanged: isEnabled
                        ? (value) {
                            if (value != null) {
                              setState(() {
                                _mappedRisks[index].risk = value;
                              });
                            }
                          }
                        : null,
                    decoration: const InputDecoration(labelText: 'Risco'),
                  ),
                ),
                if (isEnabled)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _removeRisk(index),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'EPIs Necessários',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...mappedRisk.requiredEpis.map(
                  (epi) => Chip(
                    label: Text(epi.nome),
                    onDeleted: isEnabled
                        ? () {
                            setState(() {
                              _mappedRisks[index].requiredEpis.remove(epi);
                            });
                          }
                        : null,
                  ),
                ),
                if (isEnabled)
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 18),
                    label: const Text('Adicionar EPI'),
                    onPressed: () async {},
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
