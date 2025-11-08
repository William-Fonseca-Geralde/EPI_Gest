import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/data/services/employee_service.dart';
import 'package:epi_gest_project/domain/models/employee/employee_model.dart';
import 'package:epi_gest_project/ui/employees/widget/employee_form_sections.dart';
import 'package:epi_gest_project/ui/widgets/base_drawer.dart';
import 'package:epi_gest_project/ui/widgets/image_picker_widget.dart';
import 'package:epi_gest_project/ui/widgets/info_section.dart';
import 'package:epi_gest_project/ui/widgets/overlays.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:provider/provider.dart';

class EmployeeDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final Function()? onSave;
  final Employee? employeeToEdit;
  final bool view;

  const EmployeeDrawer({
    super.key,
    required this.onClose,
    this.onSave,
    this.employeeToEdit,
    this.view = false,
  });

  @override
  State<EmployeeDrawer> createState() => _EmployeeDrawerState();
}

class _EmployeeDrawerState extends State<EmployeeDrawer>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  File? _imageFile;
  String? _imagemPath;
  DateTime? _dataEntrada;
  DateTime? _dataNascimento;
  DateTime? _dataDesligamento;
  DateTime? _dataRetornoFerias;
  bool _statusAtivo = true;
  bool _statusFerias = false;
  final List<String> _epis = [];
  final List<String> _riscos = [];

  bool get _isEditing => widget.employeeToEdit != null && !widget.view;
  bool get _isAdding => widget.employeeToEdit == null && !widget.view;
  bool get _isViewing => widget.view;

  final Map<String, TextEditingController> _controllers = {
    'matricula': TextEditingController(),
    'nome': TextEditingController(),
    'cpf': TextEditingController(),
    'rg': TextEditingController(),
    'setor': TextEditingController(),
    'funcao': TextEditingController(),
    'vinculo': TextEditingController(),
    'dataEntrada': TextEditingController(),
    'dataNascimento': TextEditingController(),
    'telefone': TextEditingController(),
    'email': TextEditingController(),
    'lider': TextEditingController(),
    'gestor': TextEditingController(),
    'localTrabalho': TextEditingController(),
    'turno': TextEditingController(),
    'dataDesligamento': TextEditingController(),
    'motivoDesligamento': TextEditingController(),
    'newSetor': TextEditingController(),
    'newFuncao': TextEditingController(),
    'newVinculo': TextEditingController(),
    'newTurno': TextEditingController(),
  };

  final Map<String, GlobalKey> _overlayKeys = {
    'setor': GlobalKey(),
    'funcao': GlobalKey(),
    'vinculo': GlobalKey(),
    'turno': GlobalKey(),
    'epis': GlobalKey(),
    'riscos': GlobalKey(),
  };
  final Map<String, OverlayEntry?> _overlays = {
    'setor': null,
    'funcao': null,
    'vinculo': null,
    'turno': null,
    'epis': null,
    'riscos': null,
  };

  bool _isLoading = true;
  String? _loadingError;
  List<String> _setoresSugeridos = [];
  List<String> _funcoesSugeridas = [];
  List<String> _vinculosSugeridos = [];
  List<String> _turnosSugeridos = [];

  final Map<String, List<String>> _suggestions = {
    'epis': [
      'Capacete',
      'Óculos de Proteção',
      'Protetor Auricular',
      'Luvas',
      'Botas de Segurança',
      'Cinto de Segurança',
      'Máscara',
      'Avental',
      'Protetor Facial',
    ],
    'funcionarios': [
      'João Silva',
      'Maria Santos',
      'Pedro Oliveira',
      'Ana Costa',
      'Carlos Souza',
    ],
    'locaisTrabalho': [
      'Empresa Principal Matriz',
      'Filial São Paulo',
      'Filial Rio de Janeiro',
      'Filial Belo Horizonte',
    ],
    'riscos': [
      'Risco Físico',
      'Risco Químico',
      'Risco Biológico',
      'Risco Ergonômico',
      'Risco de Acidente',
      'Ruído Excessivo',
      'Calor Intenso',
      'Produtos Químicos',
    ],
  };
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData().then((_) {
      if (!_isAdding) {
        _populateFormForEdit();
      }
    });
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    final employeeService = Provider.of<EmployeeService>(
      context,
      listen: false,
    );
    try {
      final results = await Future.wait([
        employeeService.getAllSetores(),
        employeeService.getAllCargos(),
        employeeService.getAllVinculo(),
        employeeService.getAllTurnos(),
      ]);

      if (!mounted) return;

      setState(() {
        _setoresSugeridos = (results[0] as List<Setor>)
            .map((s) => s.nome)
            .toList();
        _funcoesSugeridas = (results[1] as List<Cargo>)
            .map((c) => c.nome)
            .toList();
        _vinculosSugeridos = (results[2] as List<Vinculo>)
            .map((v) => v.nome)
            .toList();
        _turnosSugeridos = (results[3] as List<Turno>)
            .map((t) => t.nome)
            .toList();
        _isLoading = false;
        _loadingError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadingError = "Falha ao carregar dados iniciais: ${e.toString()}";
      });
    }
  }

  void _populateFormForEdit() {
    final employee = widget.employeeToEdit!;
    _controllers['matricula']!.text = employee.matricula;
    _controllers['nome']!.text = employee.nome;
    _controllers['cpf']!.text = employee.cpf ?? '';
    _controllers['rg']!.text = employee.rg ?? '';
    _controllers['setor']!.text = employee.setor ?? '';
    _controllers['funcao']!.text = employee.cargo ?? '';
    _controllers['vinculo']!.text = employee.vinculo ?? '';
    _controllers['dataEntrada']!.text = DateFormat(
      'dd/MM/yyyy',
    ).format(employee.dataEntrada);
    _controllers['dataNascimento']!.text = employee.dataNascimento != null
        ? DateFormat('dd/MM/yyyy').format(employee.dataNascimento!)
        : '';
    _controllers['telefone']!.text = employee.telefone ?? '';
    _controllers['email']!.text = employee.email ?? '';
    _controllers['lider']!.text = employee.lider ?? '';
    _controllers['gestor']!.text = employee.gestor ?? '';
    _controllers['localTrabalho']!.text = employee.localTrabalho ?? '';
    _controllers['turno']!.text = employee.turno ?? '';
    _controllers['dataDesligamento']!.text = employee.dataDesligamento != null
        ? DateFormat('dd/MM/yyyy').format(employee.dataDesligamento!)
        : '';
    _controllers['motivoDesligamento']!.text =
        employee.motivoDesligamento ?? '';

    setState(() {
      _dataEntrada = employee.dataEntrada;
      _dataNascimento = employee.dataNascimento;
      _dataDesligamento = employee.dataDesligamento;
      _dataRetornoFerias = employee.dataRetornoFerias;
      _statusAtivo = employee.statusAtivo;
      _statusFerias = employee.statusFerias;
      _epis.addAll(employee.epis);
      _riscos.addAll(employee.riscos);
      _imagemPath = employee.imagemPath;
    });
  }

  @override
  void dispose() {
    _removeAllOverlays();
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _removeAllOverlays() {
    _overlays.forEach((key, overlay) {
      overlay?.remove();
      _overlays[key] = null;
    });
  }

  Future<void> _closeDrawer() async {
    _removeAllOverlays();
    widget.onClose();
  }

  Future<void> _selectDate(
    String field,
    Function(DateTime) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        onDateSelected(picked);
        _controllers[field]!.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _selectDateEntrada() =>
      _selectDate('dataEntrada', (date) => _dataEntrada = date);
  void _selectDateNascimento() =>
      _selectDate('dataNascimento', (date) => _dataNascimento = date);
  void _selectDateDesligamento() =>
      _selectDate('dataDesligamento', (date) => _dataDesligamento = date);

  Future<void> _selectDateRetornoFerias() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _dataRetornoFerias ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dataRetornoFerias = picked);
    }
  }

  void _onImagePicked(File image) {
    setState(() {
      _imageFile = image;
      _imagemPath = image.path;
    });
  }

  void _onImageRemoved() {
    setState(() {
      _imageFile = null;
      _imagemPath = null;
    });
    _showSuccessSnackBar('Imagem removida');
  }

  void _showAddOverlay(String type, String title, VoidCallback onAdd) {
    if (_overlays[type] != null) {
      _overlays[type]!.remove();
      _overlays[type] = null;
      return;
    }
    final RenderBox renderBox =
        _overlayKeys[type]!.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    _overlays[type] = OverlayEntry(
      builder: (context) => AddItemOverlay(
        theme: Theme.of(context),
        title: title,
        controller: _controllers['new${_capitalize(type)}']!,
        position: position,
        buttonSize: size,
        onAdd: onAdd,
        onCancel: () {
          _overlays[type]?.remove();
          _overlays[type] = null;
          _controllers['new${_capitalize(type)}']!.clear();
        },
      ),
    );
    Overlay.of(context).insert(_overlays[type]!);
  }

  void _showMultiSelectOverlay(
    String type,
    String title,
    IconData icon,
    List<String> items,
    List<String> selectedItems,
  ) {
    if (_overlays[type] != null) {
      _overlays[type]!.remove();
      _overlays[type] = null;
      return;
    }
    final RenderBox renderBox =
        _overlayKeys[type]!.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    _overlays[type] = OverlayEntry(
      builder: (context) => MultiSelectOverlay(
        theme: Theme.of(context),
        title: title,
        icon: icon,
        position: position,
        buttonSize: size,
        items: items,
        selectedItems: List.from(selectedItems),
        onChanged: (updatedList) {
          setState(() {
            if (type == 'epis') {
              _epis.clear();
              _epis.addAll(updatedList);
            } else if (type == 'riscos') {
              _riscos.clear();
              _riscos.addAll(updatedList);
            }
          });
        },
        onCancel: () {
          _overlays[type]?.remove();
          _overlays[type] = null;
        },
        onConfirm: () {
          _overlays[type]?.remove();
          _overlays[type] = null;
          setState(() {});
        },
      ),
    );
    Overlay.of(context).insert(_overlays[type]!);
  }

  void _addNewItem(
    String type,
    List<String> suggestionList,
    TextEditingController controller,
  ) {
    if (controller.text.trim().isEmpty) return;
    setState(() {
      final newItem = controller.text.trim();
      if (!suggestionList.contains(newItem)) {
        suggestionList.add(newItem);
        _controllers[type]!.text = newItem;
      }
      controller.clear();
    });
    _overlays[type]?.remove();
    _overlays[type] = null;
    _showSuccessSnackBar('${_capitalize(type)} adicionado com sucesso!');
  }

  void _addNovoSetor() =>
      _addNewItem('setor', _setoresSugeridos, _controllers['newSetor']!);
  void _addNovaFuncao() =>
      _addNewItem('funcao', _funcoesSugeridas, _controllers['newFuncao']!);
  void _addNovoVinculo() =>
      _addNewItem('vinculo', _vinculosSugeridos, _controllers['newVinculo']!);
  void _addNovoTurno() =>
      _addNewItem('turno', _turnosSugeridos, _controllers['newTurno']!);

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dataEntrada == null) {
      _showErrorSnackBar('Selecione a data de entrada');
      return;
    }

    setState(() => _isSaving = true);
    final employeeService = Provider.of<EmployeeService>(
      context,
      listen: false,
    );

    try {
      final employee = Employee(
        matricula: _controllers['matricula']!.text.trim(),
        nome: _controllers['nome']!.text.trim(),
        dataEntrada: _dataEntrada!,
        cpf: _controllers['cpf']!.text.trim(),
        rg: _controllers['rg']!.text.trim(),
        dataNascimento: _dataNascimento,
        telefone: _controllers['telefone']!.text.trim(),
        email: _controllers['email']!.text.trim(),
        setor: _controllers['setor']!.text.trim(),
        cargo: _controllers['funcao']!.text.trim(),
        vinculo: _controllers['vinculo']!.text.trim(),
        lider: _controllers['lider']!.text.trim(),
        gestor: _controllers['gestor']!.text.trim(),
        localTrabalho: _controllers['localTrabalho']!.text.trim(),
        turno: _controllers['turno']!.text.trim(),
        epis: _epis,
        riscos: _riscos,
        statusAtivo: _statusAtivo,
        statusFerias: _statusFerias,
        dataRetornoFerias: _dataRetornoFerias,
        dataDesligamento: _dataDesligamento,
        motivoDesligamento: _controllers['motivoDesligamento']!.text.trim(),
      );

      if (_isEditing) {
        await employeeService.updateEmployee(employee.id!, employee.toJson());
        _showSuccessSnackBar('Funcionário atualizado com sucesso!');
      } else {
        await employeeService.createEmployee(employee);
        _showSuccessSnackBar('Funcionário adicionado com sucesso!');
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
      widget.onSave?.call();
    } on AppwriteException catch (e) {
      _showErrorSnackBar('Erro do Appwrite: ${e.message ?? "Ocorreu um erro"}');
    } catch (e) {
      _showErrorSnackBar('Erro inesperado: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BaseDrawer(
      onClose: widget.onClose,
      header: _buildHeader(theme),
      body: _buildBody(theme),
      footer: _isViewing ? _buildViewFooter(theme) : _buildEditFooter(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Carregando dados...'),
        ],
      );
    }

    if (_loadingError != null) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Ocorreu um Erro',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _loadingError!,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _loadingError = null;
                });
                _loadInitialData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(child: _buildForm(theme));
  }

  Widget _buildHeader(ThemeData theme) {
    String title;
    String subtitle;
    IconData icon;

    if (_isViewing) {
      title = 'Visualizar Funcionário';
      subtitle = 'Informações de ${widget.employeeToEdit?.nome ?? ""}';
      icon = Icons.visibility_outlined;
    } else if (_isEditing) {
      title = 'Editar Funcionário';
      subtitle = 'Altere os dados do funcionário';
      icon = Icons.person_search_outlined;
    } else {
      title = 'Adicionar Funcionário';
      subtitle = 'Preencha os dados do novo funcionário';
      icon = Icons.person_add_alt_1_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
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
            onPressed: _closeDrawer,
            icon: const Icon(Icons.close),
            tooltip: 'Fechar',
          ),
        ],
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useTwoColumns = constraints.maxWidth > 700;
            return useTwoColumns
                ? _buildTwoColumnLayout(theme)
                : _buildSingleColumnLayout(theme);
          },
        ),
      ),
    );
  }

  Widget _buildTwoColumnLayout(ThemeData theme) {
    final bool isEnabled = !_isViewing;
    
    return Row(
      spacing: 24,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            spacing: 32,
            children: [
              ImagePickerWidget(
                imageFile: _imageFile,
                imageUrl: _imagemPath,
                onImagePicked: _onImagePicked,
                onImageRemoved: _onImageRemoved,
                viewOnly: _isViewing,
              ),
              InfoSection(
                title: 'Documentos Pessoais',
                icon: Icons.assignment_outlined,
                child:  DocumentsSection(
                  cpfController: _controllers['cpf']!,
                  rgController: _controllers['rg']!,
                  dataNascimentoController: _controllers['dataNascimento']!,
                  onSelectDateNascimento: _selectDateNascimento,
                  enabled: isEnabled,
                ),
              ),
              InfoSection(
                title: 'Contato',
                icon: Icons.contact_phone_outlined,
                child: ContactSection(
                  telefoneController: _controllers['telefone']!,
                  emailController: _controllers['email']!,
                  enabled: isEnabled,
                ),
              ),
              InfoSection(
                title: 'Hierarquia',
                icon:  Icons.people_outline,
                child: HierarchySection(
                  liderController: _controllers['lider']!,
                  gestorController: _controllers['gestor']!,
                  funcionariosSugeridos: _suggestions['funcionarios']!,
                  enabled: isEnabled,
                ),
              ),
              if (!_statusAtivo) ...[
                InfoSection(
                  title: 'Desligamento',
                  icon: Icons.logout_outlined,
                  child: TerminationSection(
                    dataDesligamentoController:
                        _controllers['dataDesligamento']!,
                    motivoDesligamentoController:
                        _controllers['motivoDesligamento']!,
                    onSelectDateDesligamento: _selectDateDesligamento,
                    enabled: isEnabled,
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: Column(
            spacing: 32,
            children: [
              InfoSection(
                title: 'Informações Básicas',
                icon: Icons.info_outlined,
                child: BasicInfoSection(
                  matriculaController: _controllers['matricula']!,
                  nomeController: _controllers['nome']!,
                  dataEntradaController: _controllers['dataEntrada']!,
                  onSelectDateEntrada: _selectDateEntrada,
                  enabled: isEnabled,
                ),
              ),
              InfoSection(
                title: 'Cargo e Setor',
                icon: Icons.work_outline,
                child: JobSection(
                  enabled: isEnabled,
                  setorController: _controllers['setor']!,
                  funcaoController: _controllers['funcao']!,
                  vinculoController: _controllers['vinculo']!,
                  setoresSugeridos: _setoresSugeridos,
                  funcoesSugeridas: _funcoesSugeridas,
                  vinculosSugeridos: _vinculosSugeridos,
                  setorButtonKey: _overlayKeys['setor']!,
                  funcaoButtonKey: _overlayKeys['funcao']!,
                  vinculoButtonKey: _overlayKeys['vinculo']!,
                  onAddSetor: () => _showAddOverlay(
                    'setor',
                    'Adicionar Novo Setor',
                    _addNovoSetor,
                  ),
                  onAddFuncao: () => _showAddOverlay(
                    'funcao',
                    'Adicionar Nova Função',
                    _addNovaFuncao,
                  ),
                  onAddVinculo: () => _showAddOverlay(
                    'vinculo',
                    'Adicionar Novo Tipo de Vínculo',
                    _addNovoVinculo,
                  ),
                ),
              ),
              InfoSection(
                title: 'Condições de Trabalho',
                icon: Icons.settings_outlined,
                child: WorkConditionsSection(
                  enabled: isEnabled,
                  localTrabalhoController: _controllers['localTrabalho']!,
                  turnoController: _controllers['turno']!,
                  locaisTrabalhoSugeridos: _suggestions['locaisTrabalho']!,
                  turnosSugeridos: _turnosSugeridos,
                  episSelecionados: _epis,
                  riscosSelecionados: _riscos,
                  turnoButtonKey: _overlayKeys['turno']!,
                  episButtonKey: _overlayKeys['epis']!,
                  riscosButtonKey: _overlayKeys['riscos']!,
                  onAddTurno: () => _showAddOverlay(
                    'turno',
                    'Adicionar Novo Turno',
                    _addNovoTurno,
                  ),
                  onSelectEpis: () => _showMultiSelectOverlay(
                    'epis',
                    'Selecionar EPIs Necessários',
                    Icons.security_outlined,
                    _suggestions['epis']!,
                    _epis,
                  ),
                  onSelectRiscos: () => _showMultiSelectOverlay(
                    'riscos',
                    'Selecionar Riscos Associados',
                    Icons.warning_outlined,
                    _suggestions['riscos']!,
                    _riscos,
                  ),
                ),
              ),
              InfoSection(
                title: 'Status',
                icon: Icons.info_outlined,
                child: StatusSection(
                  enabled: isEnabled,
                  statusAtivo: _statusAtivo,
                  statusFerias: _statusFerias,
                  dataRetornoFerias: _dataRetornoFerias,
                  onStatusAtivoChanged: (value) =>
                      setState(() => _statusAtivo = value),
                  onStatusFeriasChanged: (value) =>
                      setState(() => _statusFerias = value),
                  onSelectDateRetornoFerias: _selectDateRetornoFerias,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleColumnLayout(ThemeData theme) {
    final bool isEnabled = !_isViewing;
    
    return Column(
      spacing: 32,
      children: [
        ImagePickerWidget(
          imageFile: _imageFile,
          imageUrl: _imagemPath,
          onImagePicked: _onImagePicked,
          onImageRemoved: _onImageRemoved,
          viewOnly: _isViewing,
        ),
        InfoSection(
          title: 'Informações Básicas',
          icon: Icons.info_outlined,
          child: BasicInfoSection(
            enabled: isEnabled,
            matriculaController: _controllers['matricula']!,
            nomeController: _controllers['nome']!,
            dataEntradaController: _controllers['dataEntrada']!,
            onSelectDateEntrada: _selectDateEntrada,
          ),
        ),
        InfoSection(
          title: 'Documentos Pessoais',
          icon: Icons.assignment_outlined,
          child: DocumentsSection(
            enabled: isEnabled,
            cpfController: _controllers['cpf']!,
            rgController: _controllers['rg']!,
            dataNascimentoController: _controllers['dataNascimento']!,
            onSelectDateNascimento: _selectDateNascimento,
          ),
        ),
        InfoSection(
          title: 'Cargo e Setor',
          icon: Icons.work_outline,
          child: JobSection(
            enabled: isEnabled,
            setorController: _controllers['setor']!,
            funcaoController: _controllers['funcao']!,
            vinculoController: _controllers['vinculo']!,
            // MODIFICADO: Passando as listas carregadas do Appwrite
            setoresSugeridos: _setoresSugeridos,
            funcoesSugeridas: _funcoesSugeridas,
            vinculosSugeridos: _vinculosSugeridos,
            setorButtonKey: _overlayKeys['setor']!,
            funcaoButtonKey: _overlayKeys['funcao']!,
            vinculoButtonKey: _overlayKeys['vinculo']!,
            onAddSetor: () =>
                _showAddOverlay('setor', 'Adicionar Novo Setor', _addNovoSetor),
            onAddFuncao: () => _showAddOverlay(
              'funcao',
              'Adicionar Nova Função',
              _addNovaFuncao,
            ),
            onAddVinculo: () => _showAddOverlay(
              'vinculo',
              'Adicionar Novo Tipo de Vínculo',
              _addNovoVinculo,
            ),
          ),
        ),
        InfoSection(
          title: 'Contato',
          icon: Icons.contact_phone_outlined,
          child: ContactSection(
            enabled: isEnabled,
            telefoneController: _controllers['telefone']!,
            emailController: _controllers['email']!,
          ),
        ),
        InfoSection(
          title: 'Condições de Trabalho',
          icon: Icons.settings_outlined,
          child: WorkConditionsSection(
            enabled: isEnabled,
            localTrabalhoController: _controllers['localTrabalho']!,
            turnoController: _controllers['turno']!,
            locaisTrabalhoSugeridos: _suggestions['locaisTrabalho']!,
            // MODIFICADO: Passando a lista carregada do Appwrite
            turnosSugeridos: _turnosSugeridos,
            episSelecionados: _epis,
            riscosSelecionados: _riscos,
            turnoButtonKey: _overlayKeys['turno']!,
            episButtonKey: _overlayKeys['epis']!,
            riscosButtonKey: _overlayKeys['riscos']!,
            onAddTurno: () =>
                _showAddOverlay('turno', 'Adicionar Novo Turno', _addNovoTurno),
            onSelectEpis: () => _showMultiSelectOverlay(
              'epis',
              'Selecionar EPIs Necessários',
              Icons.security_outlined,
              _suggestions['epis']!,
              _epis,
            ),
            onSelectRiscos: () => _showMultiSelectOverlay(
              'riscos',
              'Selecionar Riscos Associados',
              Icons.warning_outlined,
              _suggestions['riscos']!,
              _riscos,
            ),
          ),
        ),
        InfoSection(
          title: 'Hierarquia',
          icon: Icons.people_outline,
          child: HierarchySection(
            enabled: isEnabled,
            liderController: _controllers['lider']!,
            gestorController: _controllers['gestor']!,
            funcionariosSugeridos: _suggestions['funcionarios']!,
          ),
        ),
        InfoSection(
          title: 'Status',
          icon: Icons.info_outlined,
          child: StatusSection(
            enabled: isEnabled,
            statusAtivo: _statusAtivo,
            statusFerias: _statusFerias,
            dataRetornoFerias: _dataRetornoFerias,
            onStatusAtivoChanged: (value) =>
                setState(() => _statusAtivo = value),
            onStatusFeriasChanged: (value) =>
                setState(() => _statusFerias = value),
            onSelectDateRetornoFerias: _selectDateRetornoFerias,
          ),
        ),
        if (!_statusAtivo) ...[
          InfoSection(
            title: 'Desligamento',
            icon: Icons.logout_outlined,
            child: TerminationSection(
              enabled: isEnabled,
              dataDesligamentoController: _controllers['dataDesligamento']!,
              motivoDesligamentoController: _controllers['motivoDesligamento']!,
              onSelectDateDesligamento: _selectDateDesligamento,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEditFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSaving ? null : _closeDrawer,
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
              onPressed: _isSaving || _isLoading ? null : _handleSave,
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
                    : (_isEditing
                          ? 'Salvar Alterações'
                          : 'Adicionar Funcionário'),
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
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _closeDrawer,
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
