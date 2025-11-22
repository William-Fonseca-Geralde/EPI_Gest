import 'package:epi_gest_project/domain/models/epi/epi_model.dart';
import 'package:epi_gest_project/ui/widgets/base_drawer.dart';
import 'package:flutter/material.dart';

class EpiMappingDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? mappingToEdit;
  final bool view;
  
  // ADICIONADO: Parâmetros necessários
  final List<Map<String, dynamic>> availableSectors;
  final List<Map<String, dynamic>> availableRoles;
  final List<Map<String, dynamic>> availableRisks;
  final List<String> availableCategories;
  final List<EpiModel> availableEpis;

  const EpiMappingDrawer({
    super.key,
    required this.onClose,
    required this.onSave,
    this.mappingToEdit,
    this.view = false,
    required this.availableSectors,
    required this.availableRoles,
    required this.availableRisks,
    required this.availableCategories,
    required this.availableEpis,
  });

  @override
  State<EpiMappingDrawer> createState() => _EpiMappingDrawerState();
}

class _EpiMappingDrawerState extends State<EpiMappingDrawer> {
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic>? _selectedSector;
  Map<String, dynamic>? _selectedRole;
  List<Map<String, dynamic>> _selectedRisks = [];
  List<String> _selectedCategories = [];

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
    _selectedSector = mapping['sector'];
    _selectedRole = mapping['role'];
    _selectedRisks = mapping['risks'] ?? [];
    _selectedCategories = mapping['categories'] ?? [];
  }

  void _toggleRisk(Map<String, dynamic> risk) {
    setState(() {
      if (_selectedRisks.contains(risk)) {
        _selectedRisks.remove(risk);
      } else {
        _selectedRisks.add(risk);
      }
    });
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSector == null || _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um setor e um cargo.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final mappingData = {
      'id': widget.mappingToEdit?['id'] ?? 'map-${DateTime.now().millisecondsSinceEpoch}',
      'sector': _selectedSector!,
      'role': _selectedRole!,
      'risks': _selectedRisks,
      'categories': _selectedCategories,
    };

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seletor de Setor
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedSector,
                items: widget.availableSectors
                    .map(
                      (sector) => DropdownMenuItem(
                        value: sector,
                        child: Text(sector['descricao']),
                      ),
                    )
                    .toList(),
                onChanged: isEnabled
                    ? (value) => setState(() => _selectedSector = value)
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Setor*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null ? 'Selecione um setor' : null,
              ),
              const SizedBox(height: 16),

              // Seletor de Cargo/Função
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedRole,
                items: widget.availableRoles
                    .map(
                      (role) => DropdownMenuItem(
                        value: role,
                        child: Text(role['descricao']),
                      ),
                    )
                    .toList(),
                onChanged: isEnabled
                    ? (value) => setState(() => _selectedRole = value)
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Cargo / Função*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null ? 'Selecione um cargo' : null,
              ),
              const SizedBox(height: 24),

              // Riscos (Checkboxes)
              Text(
                'Riscos Associados',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecione os riscos associados a este mapeamento:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: widget.availableRisks.map((risk) {
                    final isSelected = _selectedRisks.contains(risk);
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: isEnabled
                          ? (value) => _toggleRisk(risk)
                          : null,
                      title: Text(risk['descricao']),
                      secondary: Icon(
                        Icons.warning_amber_outlined,
                        color: isSelected 
                            ? theme.colorScheme.primary 
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Categorias/Famílias de EPIs (Checkboxes)
              Text(
                'Categorias de EPIs',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecione as categorias de EPIs necessárias:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: widget.availableCategories.map((category) {
                    final isSelected = _selectedCategories.contains(category);
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: isEnabled
                          ? (value) => _toggleCategory(category)
                          : null,
                      title: Text(category),
                      secondary: Icon(
                        Icons.category_outlined,
                        color: isSelected 
                            ? theme.colorScheme.primary 
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Resumo da seleção
              if (_selectedRisks.isNotEmpty || _selectedCategories.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resumo do Mapeamento',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_selectedSector != null) 
                          Text('Setor: ${_selectedSector!['descricao']}'),
                        if (_selectedRole != null)
                          Text('Cargo: ${_selectedRole!['descricao']}'),
                        if (_selectedRisks.isNotEmpty) 
                          Text('Riscos selecionados: ${_selectedRisks.length}'),
                        if (_selectedCategories.isNotEmpty) 
                          Text('Categorias selecionadas: ${_selectedCategories.length}'),
                      ],
                    ),
                  ),
                ),
            ],
          ),
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