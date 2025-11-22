import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/data/services/employee_service.dart';
import 'package:epi_gest_project/data/services/funcionario_repository.dart';
import 'package:epi_gest_project/domain/models/employee/employee_model.dart';
import 'package:epi_gest_project/domain/models/funcionario_model.dart';
import 'package:epi_gest_project/ui/employees/widget/employee_form_sections.dart';
import 'package:epi_gest_project/ui/widgets/base_drawer.dart';
import 'package:epi_gest_project/ui/widgets/form_fields.dart';
import 'package:epi_gest_project/ui/widgets/image_picker_widget.dart';
import 'package:epi_gest_project/ui/widgets/info_section.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:provider/provider.dart';

class EmployeeDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final Function()? onSave;
  final FuncionarioModel? employeeToEdit;
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
  DateTime? _dataDesligamento;
  DateTime? _dataRetornoFerias;
  bool _statusAtivo = true;
  bool _statusFerias = false;
  bool get _isEditing => widget.employeeToEdit != null && !widget.view;
  bool get _isAdding => widget.employeeToEdit == null && !widget.view;
  bool get _isViewing => widget.view;

  // CONTROLLERS - APENAS OS NECESSÁRIOS
  late final Map<String, TextEditingController> _controllers;

  final Map<String, GlobalKey> _overlayKeys = {
    'turno': GlobalKey(),
    'vinculo': GlobalKey(),
  };
  final Map<String, OverlayEntry?> _overlays = {
    'turno': null,
    'vinculo': null,
  };

  bool _isLoading = true;
  String? _loadingError;
  List<String> _turnosSugeridos = [];
  final List<String> _locaisTrabalhoSugeridos = [];

  final Map<String, List<String>> _suggestions = {
    'funcionarios': [
      'João Silva',
      'Maria Santos',
      'Pedro Oliveira',
      'Ana Costa',
      'Carlos Souza',
    ],
  };

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controllers = {
      'id': TextEditingController(),
      'matricula': TextEditingController(),
      'nome': TextEditingController(),
      'telefone': TextEditingController(),
      'email': TextEditingController(),
      'lider': TextEditingController(),
      'gestor': TextEditingController(),
      'vinculo': TextEditingController(),
      'turno': TextEditingController(),
      'dataEntrada': TextEditingController(),
      'dataDesligamento': TextEditingController(),
      'motivoDesligamento': TextEditingController(),
      'newTurno': TextEditingController(),
      'newVinculo': TextEditingController(),
    };

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
      final results = await Future.wait([employeeService.getAllTurnos()]);

      if (!mounted) return;

      setState(() {
        _turnosSugeridos = (results[0])
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
    _controllers['id']!.text = employee.id!;
    _controllers['matricula']!.text = employee.matricula;
    _controllers['nome']!.text = employee.nomeFunc;
    _controllers['telefone']!.text = employee.telefone;
    _controllers['email']!.text = employee.email;
    _controllers['lider']!.text = employee.lider;
    _controllers['gestor']!.text = employee.gestor;
    _controllers['vinculo']!.text = employee.vinculo.nome;
    _controllers['turno']!.text = employee.turno.nome;
    _controllers['dataEntrada']!.text = DateFormat(
      'dd/MM/yyyy',
    ).format(employee.dataEntrada);
    _controllers['dataDesligamento']!.text = employee.dataDesligamento != null
        ? DateFormat('dd/MM/yyyy').format(employee.dataDesligamento!)
        : '';
    _controllers['motivoDesligamento']!.text =
        employee.motivoDesligamento ?? '';

    setState(() {
      _dataEntrada = employee.dataEntrada;
      _dataDesligamento = employee.dataDesligamento;
      _dataRetornoFerias = employee.dataRetornoFerias;
      _statusAtivo = employee.statusAtivo;
      _statusFerias = employee.statusFerias;
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

  void _showVinculoModal() {
    final theme = Theme.of(context);
    String nomeUnidade = '';
    String cnpj = '';
    String tipoUnidade = 'Matriz';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 500,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Adicionar Local de Trabalho',
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
                    const SizedBox(height: 20),

                    _buildModalTextField(
                      label: 'Nome da Unidade*',
                      hint: 'Ex: Matriz Araras, Filial São Paulo',
                      icon: Icons.business_outlined,
                      onChanged: (value) => nomeUnidade = value,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildModalTextField(
                            label: 'CNPJ*',
                            hint: 'Ex: 12.345.678/0001-90',
                            icon: Icons.numbers_outlined,
                            onChanged: (value) => cnpj = value,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: _buildModalDropdown(
                            label: 'Tipo de Unidade*',
                            value: tipoUnidade,
                            items: const ['Matriz', 'Filial'],
                            onChanged: (value) =>
                                setState(() => tipoUnidade = value!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              if (nomeUnidade.isNotEmpty && cnpj.isNotEmpty) {
                                final novoLocal = '$nomeUnidade - $tipoUnidade';
                                setState(() {
                                  if (!_locaisTrabalhoSugeridos.contains(
                                    novoLocal,
                                  )) {
                                    _locaisTrabalhoSugeridos.add(novoLocal);
                                  }
                                  _controllers['vinculo']!.text =
                                      novoLocal;
                                });
                                Navigator.pop(context);
                                _showSuccessSnackBar(
                                  'Local de trabalho adicionado com sucesso!',
                                );
                              }
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
        );
      },
    );
  }

  void _showTurnoTrabalhoModal() {
    final theme = Theme.of(context);

    TimeOfDay _entrada = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay _saida = const TimeOfDay(hour: 18, minute: 0);
    TimeOfDay _almocoInicio = const TimeOfDay(hour: 12, minute: 0);
    TimeOfDay _almocoFim = const TimeOfDay(hour: 13, minute: 0);
    String _nomeTurno = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
                          'Adicionar Turno de Trabalho',
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
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          spacing: 24,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 5),
                            _buildModalTextField(
                              label: 'Nome do Turno*',
                              hint: 'Ex: Turno Administrativo, Manhã, Tarde',
                              icon: Icons.work_outlined,
                              onChanged: (value) => _nomeTurno = value,
                            ),
                            InfoSection(
                              title: 'Horários da Jornada',
                              icon: Icons.schedule_outlined,
                              child: Column(
                                spacing: 16,
                                children: [
                                  CustomTimeField(
                                    label: 'Horário de Entrada',
                                    time: _entrada,
                                    onTap: () => _selectTimeModal(
                                      context,
                                      _entrada,
                                      (time) => setState(() => _entrada = time),
                                    ),
                                  ),
                                  CustomTimeField(
                                    label: 'Horário de Saída',
                                    time: _saida,
                                    onTap: () => _selectTimeModal(
                                      context,
                                      _saida,
                                      (time) => setState(() => _saida = time),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InfoSection(
                              title: 'Intervalo de Almoço',
                              icon: Icons.restaurant_outlined,
                              child: Column(
                                spacing: 16,
                                children: [
                                  CustomTimeField(
                                    label: 'Início do Almoço',
                                    time: _almocoInicio,
                                    onTap: () => _selectTimeModal(
                                      context,
                                      _almocoInicio,
                                      (time) =>
                                          setState(() => _almocoInicio = time),
                                    ),
                                  ),
                                  CustomTimeField(
                                    label: 'Fim do Almoço',
                                    time: _almocoFim,
                                    onTap: () => _selectTimeModal(
                                      context,
                                      _almocoFim,
                                      (time) =>
                                          setState(() => _almocoFim = time),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              if (_nomeTurno.isNotEmpty) {
                                final novoTurno = _nomeTurno;
                                setState(() {
                                  if (!_turnosSugeridos.contains(novoTurno)) {
                                    _turnosSugeridos.add(novoTurno);
                                  }
                                  _controllers['turno']!.text = novoTurno;
                                });
                                Navigator.pop(context);
                                _showSuccessSnackBar(
                                  'Turno de trabalho adicionado com sucesso!',
                                );
                              }
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
        );
      },
    );
  }

  Widget _buildModalTextField({
    required String label,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    final theme = Theme.of(context);

    return TextFormField(
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        hintText: hint,
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
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.8),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildModalDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items.map((String item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        prefixIcon: Icon(
          Icons.category_outlined,
          color: theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _selectTimeModal(
    BuildContext context,
    TimeOfDay initialTime,
    Function(TimeOfDay) onTimeSelected,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null && picked != initialTime) {
      onTimeSelected(picked);
    }
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
        if (type == 'turno') {
          _controllers['turno']!.text = newItem;
        } else if (type == 'vinculo') {
          _controllers['vinculo']!.text = newItem;
        }
      }
      controller.clear();
    });
    _overlays[type]?.remove();
    _overlays[type] = null;
    _showSuccessSnackBar('${_capitalize(type)} adicionado com sucesso!');
  }

  void _addNovoTurno() =>
      _addNewItem('turno', _turnosSugeridos, _controllers['newTurno']!);

  void _addNovoVinculo() => _addNewItem(
    'vinculo',
    _locaisTrabalhoSugeridos,
    _controllers['newVinculo']!,
  );

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dataEntrada == null) {
      _showErrorSnackBar('Selecione a data de entrada');
      return;
    }

    setState(() => _isSaving = true);
    final repository = Provider.of<FuncionarioRepository>(context, listen: false);

    try {
      final employee = FuncionarioModel(
        id: _isEditing ? widget.employeeToEdit!.id : null,
        matricula: _controllers['matricula']!.text.trim(),
        nomeFunc: _controllers['nome']!.text.trim(),
        dataEntrada: _dataEntrada!,
        telefone: _controllers['telefone']!.text.trim(),
        email: _controllers['email']!.text.trim(),
        turno: Turno(nome: _controllers['turno']!.text.trim()),
        vinculo: Vinculo(nome: _controllers['vinculo']!.text.trim()),
        lider: _controllers['lider']!.text.trim(),
        gestor: _controllers['gestor']!.text.trim(),
        statusAtivo: _statusAtivo,
        statusFerias: _statusFerias,
        dataRetornoFerias: _dataRetornoFerias,
        dataDesligamento: _dataDesligamento,
        motivoDesligamento: _controllers['motivoDesligamento']!.text.trim(),
      );

      if (_isEditing) {
        await repository.update(employee.id!, employee.toMap());
        _showSuccessSnackBar('Funcionário atualizado com sucesso!');
      } else {
        await repository.create(employee);
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
      if (mounted) setState(() => _isSaving = false);
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
      subtitle = 'Informações de ${widget.employeeToEdit?.nomeFunc ?? ""}';
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
        // COLUNA ESQUERDA - IMAGEM + HIERARQUIA + CONTATO
        Expanded(
          child: Column(
            spacing: 32,
            children: [
              // IMAGEM NO TOPO ESQUERDO (MANTÉM NO MESMO LUGAR)
              ImagePickerWidget(
                imageFile: _imageFile,
                imageUrl: _imagemPath,
                onImagePicked: _onImagePicked,
                onImageRemoved: _onImageRemoved,
                viewOnly: _isViewing,
              ),
              // HIERARQUIA ABAIXO DA IMAGEM
              InfoSection(
                title: 'Hierarquia',
                icon: Icons.people_outline,
                child: HierarchySection(
                  liderController: _controllers['lider']!,
                  gestorController: _controllers['gestor']!,
                  funcionariosSugeridos: _suggestions['funcionarios']!,
                  enabled: isEnabled,
                ),
              ),
              // CONTATO ABAIXO DA HIERARQUIA
              InfoSection(
                title: 'Contato',
                icon: Icons.contact_phone_outlined,
                child: ContactSection(
                  telefoneController: _controllers['telefone']!,
                  emailController: _controllers['email']!,
                  enabled: isEnabled,
                ),
              ),
            ],
          ),
        ),

        // COLUNA DIREITA - INFORMAÇÕES BÁSICAS + CONDIÇÕES DE TRABALHO + STATUS
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
                title: 'Condições de Trabalho',
                icon: Icons.settings_outlined,
                child: WorkConditionsSection(
                  enabled: isEnabled,
                  vinculoController: _controllers['vinculo']!,
                  turnoController: _controllers['turno']!,
                  locaisTrabalhoSugeridos: _locaisTrabalhoSugeridos,
                  turnosSugeridos: _turnosSugeridos,
                  vinculoButtonKey: _overlayKeys['vinculo']!,
                  turnoButtonKey: _overlayKeys['turno']!,
                  onAddVinculo: _showVinculoModal,
                  onAddTurno: _showTurnoTrabalhoModal,
                ),
              ),
              // MANTÉM STATUS NO MESMO LUGAR
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
          title: 'Contato',
          icon: Icons.contact_phone_outlined,
          child: ContactSection(
            enabled: isEnabled,
            telefoneController: _controllers['telefone']!,
            emailController: _controllers['email']!,
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
          title: 'Condições de Trabalho',
          icon: Icons.settings_outlined,
          child: WorkConditionsSection(
            enabled: isEnabled,
            vinculoController: _controllers['vinculo']!,
            turnoController: _controllers['turno']!,
            locaisTrabalhoSugeridos: _locaisTrabalhoSugeridos,
            turnosSugeridos: _turnosSugeridos,
            vinculoButtonKey: _overlayKeys['vinculo']!,
            turnoButtonKey: _overlayKeys['turno']!,
            onAddVinculo: _showVinculoModal,
            onAddTurno: _showTurnoTrabalhoModal,
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
        spacing: 12,
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                icon: Icon(Icons.close),
                onPressed: _isSaving ? null : _closeDrawer,
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                label: const Text('Cancelar'),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _isSaving || _isLoading ? null : _handleSave,
                icon: _isSaving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
