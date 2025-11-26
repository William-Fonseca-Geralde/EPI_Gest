import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/data/services/organizational_structure/riscos_repository.dart';
import 'package:epi_gest_project/domain/models/riscos_model.dart';
import 'package:epi_gest_project/ui/widgets/base_drawer.dart';
import 'package:epi_gest_project/ui/widgets/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RiscosDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final Function(RiscosModel) onSave;
  final RiscosModel? riscoToEdit;
  final bool view;

  const RiscosDrawer({
    super.key,
    required this.onClose,
    required this.onSave,
    this.riscoToEdit,
    this.view = false,
  });

  @override
  State<RiscosDrawer> createState() => _RiscosDrawerState();
}

class _RiscosDrawerState extends State<RiscosDrawer> {
  final _formKey = GlobalKey<FormState>();
  final _nomeRiscoController = TextEditingController();
  final _codigoRiscoController = TextEditingController();

  bool get _isEditing => widget.riscoToEdit != null && !widget.view;
  bool get _isViewing => widget.view;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (_isEditing || _isViewing) _populateForm();
  }

  void _populateForm() {
    final risco = widget.riscoToEdit!;
    _nomeRiscoController.text = risco.nomeRiscos;
    _codigoRiscoController.text = risco.codigoRiscos;
  }

  @override
  void dispose() {
    _nomeRiscoController.dispose();
    _codigoRiscoController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final riscoModel = RiscosModel(
      id: widget.riscoToEdit?.id,
      codigoRiscos: _codigoRiscoController.text.trim(),
      nomeRiscos: _nomeRiscoController.text.trim(),
    );

    try {
      final repository = Provider.of<RiscosRepository>(context, listen: false);

      if (widget.riscoToEdit != null) {
        // Update
        await repository.update(widget.riscoToEdit!.id!, riscoModel.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Risco atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Create
        await repository.create(riscoModel);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Risco criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      widget.onSave(riscoModel);
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
      title = 'Visualizar Risco';
      subtitle = 'Informações completas do risco';
      icon = Icons.visibility_outlined;
    } else if (_isEditing) {
      title = 'Editar Risco';
      subtitle = 'Altere os dados do risco';
      icon = Icons.edit_outlined;
    } else {
      title = 'Adicionar Risco';
      subtitle = 'Preencha os dados do novo risco';
      icon = Icons.warning_outlined;
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
              controller: _codigoRiscoController,
              label: 'Codigo do Risco',
              hint: 'Ex: QUI01, FIS01, BIO03',
              enabled: isEnabled,
              icon: Icons.qr_code_outlined,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
            ),
            CustomTextField(
              controller: _nomeRiscoController,
              label: 'Descrição do Risco',
              hint: 'Ex: Químico, Físico, Biológico, Acidente',
              enabled: isEnabled,
              icon: Icons.warning_amber_outlined,
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
                                : "Adicionar Risco",
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
