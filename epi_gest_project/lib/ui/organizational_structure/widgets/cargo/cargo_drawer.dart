import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/data/services/organizational_structure/cargo_repository.dart';
import 'package:epi_gest_project/domain/models/cargo_model.dart';
import 'package:epi_gest_project/ui/widgets/base_drawer.dart';
import 'package:epi_gest_project/ui/widgets/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CargoDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final Function(CargoModel) onSave;
  final CargoModel? cargoToEdit;
  final bool view;

  const CargoDrawer({
    super.key,
    required this.onClose,
    required this.onSave,
    this.cargoToEdit,
    this.view = false,
  });

  @override
  State<CargoDrawer> createState() => _CargoDrawerState();
}

class _CargoDrawerState extends State<CargoDrawer> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCargoController = TextEditingController();
  final _codigoCargoController = TextEditingController();

  bool get _isEditing => widget.cargoToEdit != null && !widget.view;
  bool get _isViewing => widget.view;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (_isEditing || _isViewing) _populateForm();
  }

  void _populateForm() {
    final cargo = widget.cargoToEdit!;
    _nomeCargoController.text = cargo.nomeCargo;
    _codigoCargoController.text = cargo.codigoCargo;
  }

  @override
  void dispose() {
    _nomeCargoController.dispose();
    _codigoCargoController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final cargoModel = CargoModel(
      id: widget.cargoToEdit?.id,
      codigoCargo: _codigoCargoController.text.trim(),
      nomeCargo: _nomeCargoController.text.trim(),
    );

    try {
      final repository = Provider.of<CargoRepository>(context, listen: false);
      
      if (widget.cargoToEdit != null) {
        await repository.update(widget.cargoToEdit!.id!, cargoModel.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cargo atualizado com sucesso!'), backgroundColor: Colors.green),
        );
      } else {
        await repository.create(cargoModel);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cargo criado com sucesso!'), backgroundColor: Colors.green),
        );
      }

      widget.onSave(cargoModel);
      widget.onClose();
      
    } on AppwriteException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: ${e.message}'), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: $e'), backgroundColor: Colors.red),
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
      title = 'Visualizar Cargo';
      subtitle = 'Informações completas do cargo';
      icon = Icons.visibility_outlined;
    } else if (_isEditing) {
      title = 'Editar Cargo';
      subtitle = 'Altere os dados do cargo';
      icon = Icons.edit_outlined;
    } else {
      title = 'Adicionar Cargo/Função';
      subtitle = 'Preencha os dados do novo cargo';
      icon = Icons.add_card_outlined;
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
              controller: _codigoCargoController,
              label: 'Código do Cargo',
              hint: 'Ex: ANL01, GER02, ASSIS01, OP03',
              enabled: isEnabled,
              icon: Icons.qr_code_outlined,
              validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
            ),
            CustomTextField(
              controller: _nomeCargoController,
              label: 'Descrição do Cargo',
              hint: 'Ex: Analista, Gerente, Assistente, Operador',
              enabled: isEnabled,
              icon: Icons.work_outline,
              validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
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
                            _isEditing ? "Salvar Alterações" : "Adicionar Cargo",
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