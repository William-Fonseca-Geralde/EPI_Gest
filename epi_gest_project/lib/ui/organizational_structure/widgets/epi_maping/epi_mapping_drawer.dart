import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/data/services/cargo_repository.dart';
import 'package:epi_gest_project/data/services/categoria_repository.dart';
import 'package:epi_gest_project/data/services/mapeamento_epi_repository.dart';
import 'package:epi_gest_project/data/services/riscos_repository.dart';
import 'package:epi_gest_project/data/services/setor_repository.dart';
import 'package:epi_gest_project/domain/models/cargo_model.dart';
import 'package:epi_gest_project/domain/models/categoria_model.dart';
import 'package:epi_gest_project/domain/models/mapeamento_epi_model.dart';
import 'package:epi_gest_project/domain/models/riscos_model.dart';
import 'package:epi_gest_project/domain/models/setor_model.dart';
import 'package:epi_gest_project/ui/widgets/base_drawer.dart';
import 'package:epi_gest_project/ui/widgets/form_fields.dart';
import 'package:epi_gest_project/ui/widgets/info_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EpiMappingDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final Function(MapeamentoEpiModel)? onSave;
  final MapeamentoEpiModel? mappingToEdit;
  final bool view;

  final List<SetorModel> availableSectors;
  final List<CargoModel> availableRoles;
  final List<RiscosModel> availableRisks;
  final List<CategoriaModel> availableCategories;

  const EpiMappingDrawer({
    super.key,
    required this.onClose,
    this.onSave,
    this.mappingToEdit,
    this.view = false,
    required this.availableSectors,
    required this.availableRoles,
    required this.availableRisks,
    required this.availableCategories,
  });

  @override
  State<EpiMappingDrawer> createState() => _EpiMappingDrawerState();
}

class _EpiMappingDrawerState extends State<EpiMappingDrawer> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _codigoController = TextEditingController();
  final _nomeController = TextEditingController();
  final _setorController = TextEditingController();
  final _cargoController = TextEditingController();

  List<String> _selectedRiskNames = [];
  List<String> _selectedCategoryNames = [];

  // Keys para botões de adicionar
  final GlobalKey _setorButtonKey = GlobalKey();
  final _nomeSetorController = TextEditingController();
  final _codigoSetorController = TextEditingController();

  final GlobalKey _cargoButtonKey = GlobalKey();
  final _nomeCargoController = TextEditingController();
  final _codigoCargoController = TextEditingController();

  final GlobalKey _riskButtonKey = GlobalKey();
  final GlobalKey _catButtonKey = GlobalKey();
  final GlobalKey _riskKey = GlobalKey();
  final GlobalKey _catKey = GlobalKey();

  late List<SetorModel> _setores = [];
  late List<CargoModel> _cargos = [];
  List<RiscosModel> _riscos = [];
  List<CategoriaModel> _categorias = [];

  List<String> _setoresSugestoes = [];
  List<String> _cargosSugestoes = [];
  
  List<String> _selectedRiskIds = [];
  List<String> _selectedCategoryIds = [];

  bool _statusAtivo = true;
  bool _isSaving = false;

  bool get _isEditing => widget.mappingToEdit != null && !widget.view;
  bool get _isViewing => widget.view;
  bool get _isEnabled => !_isViewing;

  @override
  void initState() {
    super.initState();
    _setores = List.from(widget.availableSectors);
    _cargos = List.from(widget.availableRoles);
    _riscos = List.from(widget.availableRisks);
    _categorias = List.from(widget.availableCategories);

    if (widget.mappingToEdit != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final map = widget.mappingToEdit!;
    _codigoController.text = map.codigoMapeamento;
    _nomeController.text = map.nomeMapeamento;
    _statusAtivo = map.status;

    _setorController.text = map.setor.nomeSetor;
    _cargoController.text = map.cargo.nomeCargo;

    _selectedRiskIds = map.riscos.map((r) => r.nomeRiscos).toList();
    _selectedCategoryIds = map.listCategoriasEpis
        .map((c) => c.nomeCategoria)
        .toList();
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nomeController.dispose();
    _setorController.dispose();
    _cargoController.dispose();
    super.dispose();
  }

  void _showAddSetorDialog() {
    _nomeSetorController.clear();
    _codigoSetorController.clear();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 20,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Adicionar Novo Setor',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  CustomTextField(
                    controller: _codigoSetorController,
                    label: 'Código do Setor',
                    hint: 'Ex: ADM',
                    icon: Icons.workspaces_outlined,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
                  ),
                  CustomTextField(
                    controller: _nomeSetorController,
                    label: 'Nome do Cargo',
                    hint: 'Ex: Administrativo',
                    icon: Icons.work_outline,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
                  ),
                  Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            _createSetor(context);
                          },
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Adicionar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _createSetor(BuildContext dialogContext) async {
    final nome = _nomeSetorController.text.trim();
    final codigo = _codigoSetorController.text.trim();

    final repo = Provider.of<SetorRepository>(context, listen: false);
    try {
      Navigator.pop(dialogContext);

      final novoSetor = SetorModel(codigoSetor: codigo, nomeSetor: nome);

      final created = await repo.create(novoSetor);

      setState(() {
        _setores.add(created);
        _setoresSugestoes.add(created.nomeSetor);
        _nomeSetorController.text = created.nomeSetor;
      });
      _showSuccessSnackBar('Setor criado com sucesso!');
    } catch (e) {
      _showErrorSnackBar("Erro ao criar setor: $e");
    }
  }

  void _showAddCargoDialog() {
    _nomeCargoController.clear();
    _codigoCargoController.clear();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 20,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Adicionar Novo Cargo',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  CustomTextField(
                    controller: _codigoCargoController,
                    label: 'Código do Cargo',
                    hint: 'Ex: ANL01, GER02, ASSIS01, OP03',
                    icon: Icons.qr_code_outlined,
                  ),
                  CustomTextField(
                    controller: _nomeCargoController,
                    label: 'Descrição do Cargo',
                    hint: 'Ex: Analista, Gerente, Assistente, Operador',
                    icon: Icons.work_outline,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
                  ),
                  Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            _createCargo(context);
                          },
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Adicionar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _createCargo(BuildContext dialogContext) async {
    final nome = _nomeCargoController.text.trim();
    final codigo = _codigoCargoController.text.trim();

    final repo = Provider.of<CargoRepository>(context, listen: false);
    try {
      Navigator.pop(dialogContext);

      final novoCargo = CargoModel(codigoCargo: codigo, nomeCargo: nome);

      final created = await repo.create(novoCargo);

      setState(() {
        _cargos.add(created);
        _cargosSugestoes.add(created.nomeCargo);
        _nomeCargoController.text = created.nomeCargo;
      });
      _showSuccessSnackBar('Cargo criado com sucesso!');
    } catch (e) {
      _showErrorSnackBar("Erro ao criar cargo: $e");
    }
  }

  void _showAddRiscoDialog() {
    final nomeController = TextEditingController();
    final codigoController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adicionar Novo Risco'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codigoController,
              decoration: const InputDecoration(labelText: 'Código', hintText: 'Ex: QUI-01'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome do Risco', hintText: 'Ex: Químico'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              if (nomeController.text.isNotEmpty && codigoController.text.isNotEmpty) {
                try {
                  final repo = Provider.of<RiscosRepository>(context, listen: false);
                  final novo = RiscosModel(
                    codigoRiscos: codigoController.text.trim(),
                    nomeRiscos: nomeController.text.trim(),
                  );
                  final created = await repo.create(novo);
                  
                  setState(() {
                    _riscos.add(created);
                    _selectedRiskNames.add(created.nomeRiscos); // Já seleciona o novo
                  });
                  Navigator.pop(ctx);
                  _showSuccessSnackBar('Risco criado com sucesso!');
                } catch (e) {
                  _showErrorSnackBar('Erro ao criar risco: $e');
                }
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  // --- Adicionar Categoria ---
  void _showAddCategoriaDialog() {
    final nomeController = TextEditingController();
    final codigoController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adicionar Nova Categoria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codigoController,
              decoration: const InputDecoration(labelText: 'Código', hintText: 'Ex: CAT-LUV'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome da Categoria', hintText: 'Ex: Proteção de Mãos'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              if (nomeController.text.isNotEmpty && codigoController.text.isNotEmpty) {
                try {
                  final repo = Provider.of<CategoriaRepository>(context, listen: false);
                  final novo = CategoriaModel(
                    codigoCategoria: codigoController.text.trim(),
                    nomeCategoria: nomeController.text.trim(),
                  );
                  final created = await repo.create(novo);
                  
                  setState(() {
                    _categorias.add(created);
                    _selectedCategoryNames.add(created.nomeCategoria); // Já seleciona
                  });
                  Navigator.pop(ctx);
                  _showSuccessSnackBar('Categoria criada com sucesso!');
                } catch (e) {
                  _showErrorSnackBar('Erro ao criar categoria: $e');
                }
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final setorObj = _setores
        .where(
          (s) =>
              s.nomeSetor.toLowerCase() ==
              _setorController.text.trim().toLowerCase(),
        )
        .firstOrNull;

    final cargoObj = _cargos
        .where(
          (c) =>
              c.nomeCargo.toLowerCase() ==
              _cargoController.text.trim().toLowerCase(),
        )
        .firstOrNull;

    if (setorObj == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Setor inválido. Selecione da lista ou crie um novo.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (cargoObj == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cargo inválido. Selecione da lista ou crie um novo.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = Provider.of<MapeamentoEpiRepository>(context, listen: false);

      final riscosObj = widget.availableRisks
          .where((r) => _selectedRiskIds.contains(r.nomeRiscos))
          .toList();

      final categoriasObj = widget.availableCategories
          .where((c) => _selectedCategoryIds.contains(c.nomeCategoria))
          .toList();

      final newMapping = MapeamentoEpiModel(
        id: widget.mappingToEdit?.id,
        codigoMapeamento: _codigoController.text.trim(),
        nomeMapeamento: _nomeController.text.trim(),
        cargo: cargoObj,
        setor: setorObj,
        riscos: riscosObj,
        listCategoriasEpis: categoriasObj,
        status: _statusAtivo,
      );

      if (widget.mappingToEdit != null) {
        await repo.update(newMapping.id!, newMapping.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mapeamento atualizado!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await repo.create(newMapping);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mapeamento criado!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      if (widget.onSave != null) widget.onSave!(newMapping);
      widget.onClose();
    } on AppwriteException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.message}'),
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

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseDrawer(
      onClose: widget.onClose,
      widthFactor: 0.5,
      header: _buildHeader(theme),
      body: _buildBody(theme),
      footer: _isViewing ? _buildViewFooter(theme) : _buildEditFooter(theme),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    String title = _isViewing
        ? 'Visualizar Mapeamento'
        : _isEditing
        ? 'Editar Mapeamento'
        : 'Novo Mapeamento';

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
              Icons.assignment_turned_in_outlined,
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
                  'Defina os EPIs necessários por função',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close)),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          spacing: 24,
          children: [
            InfoSection(
              title: 'Identificação',
              icon: Icons.info_outline,
              child: Column(
                spacing: 16,
                children: [
                  Row(
                    spacing: 16,
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _codigoController,
                          label: 'Código do Mapeamento',
                          hint: 'Ex: MAP-001',
                          icon: Icons.qr_code,
                          enabled: _isEnabled,
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Obrigatório' : null,
                        ),
                      ),
                      Expanded(
                        child: CustomTextField(
                          controller: _nomeController,
                          label: 'Nome do Mapeamento',
                          hint: 'Ex: Mapeamento Produção Químico',
                          icon: Icons.map,
                          enabled: _isEnabled,
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Obrigatório' : null,
                        ),
                      ),
                    ],
                  ),
                  CustomSwitchField(
                    value: _statusAtivo,
                    onChanged: (val) => setState(() => _statusAtivo = val),
                    label: 'Status do Mapeamento',
                    activeText: 'Ativo',
                    inactiveText: 'Inativo',
                    icon: Icons.toggle_on,
                    enabled: _isEnabled,
                  ),
                ],
              ),
            ),

            InfoSection(
              title: 'Vínculo Organizacional',
              icon: Icons.business,
              child: Column(
                spacing: 16,
                children: [
                  CustomAutocompleteField(
                    controller: _setorController,
                    label: 'Setor / Departamento',
                    hint: 'Selecione ou adicione um setor',
                    icon: Icons.work_outline,
                    suggestions: _setores.map((s) => s.nomeSetor).toList(),
                    showAddButton: _isEnabled,
                    enabled: _isEnabled,
                    addButtonKey: _setorButtonKey,
                    onAddPressed: _showAddSetorDialog,
                  ),

                  CustomAutocompleteField(
                    controller: _cargoController,
                    label: 'Cargo / Função',
                    hint: 'Selecione ou adicione um cargo',
                    icon: Icons.badge_outlined,
                    suggestions: _cargos.map((c) => c.nomeCargo).toList(),
                    showAddButton: _isEnabled,
                    enabled: _isEnabled,
                    addButtonKey: _cargoButtonKey,
                    onAddPressed: _showAddCargoDialog,
                  ),
                ],
              ),
            ),
            InfoSection(
              title: 'Riscos e EPIs',
              icon: Icons.warning_amber_rounded,
              child: Column(
                spacing: 16,
                children: [
                  CustomMultiSelectField(
                    label: 'Riscos Ocupacionais',
                    hint: 'Selecione os riscos',
                    icon: Icons.warning_outlined,
                    selectedItems: _selectedRiskIds,
                    buttonKey: _riskKey,
                    enabled: _isEnabled,
                    showAddButton: _isEnabled,
                    addButtonKey: _riskButtonKey,
                    onAddPressed: _showAddRiscoDialog,
                    onTap: () {
                      _showMultiSelectDialog(
                        title: 'Selecione os Riscos',
                        items: widget.availableRisks
                            .map((r) => r.nomeRiscos)
                            .toList(),
                        selected: _selectedRiskIds,
                        onConfirm: (list) =>
                            setState(() => _selectedRiskIds = list),
                      );
                    },
                  ),
                  CustomMultiSelectField(
                    label: 'Categorias de EPI Necessárias',
                    hint: 'Selecione as categorias',
                    icon: Icons.category_outlined,
                    selectedItems: _selectedCategoryIds,
                    buttonKey: _catKey,
                    enabled: _isEnabled,
                    showAddButton: _isEnabled,
                    addButtonKey: _catButtonKey,
                    onAddPressed: _showAddCategoriaDialog,
                    onTap: () {
                      _showMultiSelectDialog(
                        title: 'Selecione as Categorias',
                        items: widget.availableCategories
                            .map((c) => c.nomeCategoria)
                            .toList(),
                        selected: _selectedCategoryIds,
                        onConfirm: (list) =>
                            setState(() => _selectedCategoryIds = list),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMultiSelectDialog({
    required String title,
    required List<String> items,
    required List<String> selected,
    required Function(List<String>) onConfirm,
  }) {
    List<String> tempSelected = List.from(selected);
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: 400,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return CheckboxListTile(
                      title: Text(item),
                      value: tempSelected.contains(item),
                      onChanged: (val) {
                        setStateDialog(() {
                          if (val == true)
                            tempSelected.add(item);
                          else
                            tempSelected.remove(item);
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    onConfirm(tempSelected);
                    Navigator.pop(context);
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
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
          ),
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
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _handleSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                _isSaving
                    ? 'Salvando...'
                    : (_isEditing ? 'Salvar Alterações' : 'Salvar Mapeamento'),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
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
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: widget.onClose,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Fechar'),
        ),
      ),
    );
  }
}
