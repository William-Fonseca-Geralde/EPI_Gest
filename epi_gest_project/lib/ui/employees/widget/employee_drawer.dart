import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/data/services/funcionario_repository.dart';
import 'package:epi_gest_project/data/services/turno_repository.dart';
import 'package:epi_gest_project/data/services/vinculo_repository.dart';
import 'package:epi_gest_project/domain/models/employee/employee_model.dart';
import 'package:epi_gest_project/domain/models/funcionario_model.dart';
import 'package:epi_gest_project/domain/models/turno_model.dart';
import 'package:epi_gest_project/domain/models/vinculo_model.dart';
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

  late final Map<String, TextEditingController> _controllers;

  final Map<String, GlobalKey> _overlayKeys = {
    'turno': GlobalKey(),
    'vinculo': GlobalKey(),
  };

  List<TurnoModel> _turnosDisponiveis = [];
  List<VinculoModel> _vinculosDisponiveis = [];

  List<String> _turnosSugestoes = [];
  List<String> _vinculosSugestoes = [];

  TimeOfDay _tempEntrada = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _tempSaida = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _tempAlmocoInicio = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _tempAlmocoFim = const TimeOfDay(hour: 13, minute: 0);

  bool _isLoading = true;
  String? _loadingError;

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
      'newTurnoNome': TextEditingController(),
      'newVinculoNome': TextEditingController(),
      'newVinculoCodigo': TextEditingController(),
    };

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    try {
      final turnoRepo = Provider.of<TurnoRepository>(context, listen: false);
      final vinculoRepo = Provider.of<VinculoRepository>(
        context,
        listen: false,
      );

      final results = await Future.wait([
        turnoRepo.getAllTurnos(),
        vinculoRepo.getAllVinculos(),
      ]);

      if (!mounted) return;

      setState(() {
        _turnosDisponiveis = results[0] as List<TurnoModel>;
        _vinculosDisponiveis = results[1] as List<VinculoModel>;

        _turnosSugestoes = _turnosDisponiveis.map((t) => t.turno).toList();
        _vinculosSugestoes = _vinculosDisponiveis
            .map((v) => v.nomeVinculo)
            .toList();

        _isLoading = false;
        _loadingError = null;
      });

      if (!_isAdding) {
        _populateFormForEdit();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadingError = "Falha ao carregar dados: ${e.toString()}";
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
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _closeDrawer() async {
    widget.onClose();
  }

  void _showVinculoModal() {
    _controllers['newVinculoNome']!.clear();
    _controllers['newVinculoCodigo']!.clear();
    final theme = Theme.of(context);

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
                          'Adicionar Novo Vínculo',
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
                      controller: _controllers['newVinculoCodigo']!,
                      label: 'Código (Opcional)',
                      hint: 'Ex: V01',
                      icon: Icons.qr_code,
                    ),
                    CustomTextField(
                      controller: _controllers['newVinculoNome']!,
                      label: 'Nome do Vinculo',
                      hint: 'Ex: CLT, Estágio, PJ',
                      icon: Icons.assignment_ind_outlined,
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
                              _createVinculo(context);
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

  Future<void> _createVinculo(BuildContext dialogContext) async {
    final nome = _controllers['newVinculoNome']!.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Nome obrigatório")));
      return;
    }

    final repo = Provider.of<VinculoRepository>(context, listen: false);
    try {
      Navigator.pop(dialogContext); // Fecha modal
      setState(() => _isLoading = true); // Mostra loading no drawer

      final novoVinculo = VinculoModel(
        codigoVinculo: _controllers['newVinculoCodigo']!.text.trim(),
        nomeVinculo: nome,
      );

      final created = await repo.create(novoVinculo);

      setState(() {
        _vinculosDisponiveis.add(created);
        _vinculosSugestoes.add(created.nomeVinculo);
        _controllers['vinculo']!.text =
            created.nomeVinculo; // Seleciona automaticamente
        _isLoading = false;
      });
      _showSuccessSnackBar('Vínculo criado com sucesso!');
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar("Erro ao criar vínculo: $e");
    }
  }

  void _showTurnoTrabalhoModal() {
    _controllers['newTurnoNome']!.clear();
    final theme = Theme.of(context);

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
                          'Adicionar Novo Turno de Trabalho',
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
                            CustomTextField(
                              controller: _controllers['newTurnoNome']!,
                              label: 'Nome do Turno',
                              hint: 'Nome do Turno',
                              icon: Icons.work_outline,
                            ),
                            InfoSection(
                              title: 'Horários da Jornada',
                              icon: Icons.schedule_outlined,
                              child: Column(
                                spacing: 16,
                                children: [
                                  CustomTimeField(
                                    label: 'Horário de Entrada',
                                    time: _tempEntrada,
                                    onTap: () => _selectTimeModal(
                                      context,
                                      _tempEntrada,
                                      (time) => setState(() => _tempEntrada = time),
                                    ),
                                  ),
                                  CustomTimeField(
                                    label: 'Horário de Saída',
                                    time: _tempSaida,
                                    onTap: () => _selectTimeModal(
                                      context,
                                      _tempSaida,
                                      (time) => setState(() => _tempSaida = time),
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
                                    time: _tempAlmocoInicio,
                                    onTap: () => _selectTimeModal(
                                      context,
                                      _tempAlmocoInicio,
                                      (time) =>
                                          setState(() => _tempAlmocoInicio = time),
                                    ),
                                  ),
                                  CustomTimeField(
                                    label: 'Fim do Almoço',
                                    time: _tempAlmocoFim,
                                    onTap: () => _selectTimeModal(
                                      context,
                                      _tempAlmocoFim,
                                      (time) =>
                                          setState(() => _tempAlmocoFim = time),
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
                              _createTurno(context);
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

  Future<void> _createTurno(BuildContext dialogContext) async {
    final nome = _controllers['newTurnoNome']!.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Nome obrigatório")));
      return;
    }

    final repo = Provider.of<TurnoRepository>(context, listen: false);
    try {
      Navigator.pop(dialogContext);
      setState(() => _isLoading = true);

      final novoTurno = TurnoModel(
        turno: nome,
        horaEntrada: _tempEntrada.format(context),
        horaSaida: _tempSaida.format(context),
        inicioAlmoco: _tempAlmocoInicio.format(context),
        fimAlomoco: _tempAlmocoFim.format(context),
      );

      final created = await repo.create(novoTurno);

      setState(() {
        _turnosDisponiveis.add(created);
        _turnosSugestoes.add(created.turno);
        _controllers['turno']!.text =
            created.turno;
        _isLoading = false;
      });
      _showSuccessSnackBar('Turno criado com sucesso!');
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar("Erro ao criar turno: $e");
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
  void _selectDateRetornoFerias() =>
      _selectDate('dataRetornoFerias', (date) => _dataRetornoFerias = date);

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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dataEntrada == null) {
      _showErrorSnackBar('Selecione a data de entrada');
      return;
    }

    final selectedTurnoNome = _controllers['turno']!.text.trim();
    final selectedVinculoNome = _controllers['vinculo']!.text.trim();

    TurnoModel? turnoSelecionado;
    try {
      turnoSelecionado = _turnosDisponiveis.firstWhere(
        (t) => t.turno == selectedTurnoNome,
      );
    } catch (_) {
      _showErrorSnackBar('Turno inválido. Selecione ou crie um novo.');
      return;
    }

    VinculoModel? vinculoSelecionado;
    try {
      vinculoSelecionado = _vinculosDisponiveis.firstWhere(
        (v) => v.nomeVinculo == selectedVinculoNome,
      );
    } catch (_) {
      _showErrorSnackBar('Vínculo inválido. Selecione ou crie um novo.');
      return;
    }

    setState(() => _isSaving = true);
    final repository = Provider.of<FuncionarioRepository>(
      context,
      listen: false,
    );

    try {
      final employee = FuncionarioModel(
        id: _isEditing ? widget.employeeToEdit!.id : null,
        matricula: _controllers['matricula']!.text.trim(),
        nomeFunc: _controllers['nome']!.text.trim(),
        dataEntrada: _dataEntrada!,
        telefone: _controllers['telefone']!.text.trim(),
        email: _controllers['email']!.text.trim(),
        turno: Turno(id: turnoSelecionado.id, nome: turnoSelecionado.turno),
        vinculo: Vinculo(
          id: vinculoSelecionado.id,
          nome: vinculoSelecionado.nomeVinculo,
        ),
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
                title: 'Condições de Trabalho',
                icon: Icons.settings_outlined,
                child: WorkConditionsSection(
                  enabled: isEnabled,
                  vinculoController: _controllers['vinculo']!,
                  turnoController: _controllers['turno']!,
                  vinculosSugeridos: _vinculosSugestoes,
                  turnosSugeridos: _turnosSugestoes,
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
            vinculosSugeridos: _vinculosSugestoes,
            turnosSugeridos: _turnosSugestoes,
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
