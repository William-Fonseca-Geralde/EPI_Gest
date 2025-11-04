import 'package:epi_gest_project/domain/models/employee/employee_form_data.dart';
import 'package:epi_gest_project/ui/employees/widget/widgets_employee/employee_form_sections.dart';
import 'package:epi_gest_project/ui/employees/widget/widgets_employee/image_picker_widget.dart';
import 'package:epi_gest_project/ui/employees/widget/widgets_employee/overlays.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';


class AddEmployeeDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Map<String, dynamic>)? onSave;

  const AddEmployeeDrawer({
    super.key,
    required this.onClose,
    this.onSave,
  });

  @override
  State<AddEmployeeDrawer> createState() => _AddEmployeeDrawerState();
}

class _AddEmployeeDrawerState extends State<AddEmployeeDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  late EmployeeFormData _formData;

  // Controllers
  final Map<String, TextEditingController> _controllers = {};

  // GlobalKeys para overlays
  final Map<String, GlobalKey> _overlayKeys = {
    'setor': GlobalKey(),
    'funcao': GlobalKey(),
    'vinculo': GlobalKey(),
    'turno': GlobalKey(),
    'epis': GlobalKey(),
    'riscos': GlobalKey(),
  };

  // Overlays
  final Map<String, OverlayEntry?> _overlays = {
    'setor': null,
    'funcao': null,
    'vinculo': null,
    'turno': null,
    'epis': null,
    'riscos': null,
  };

  // Listas de sugestões
  final Map<String, List<String>> _suggestions = {
    'setores': [
      'Produção',
      'Qualidade',
      'Manutenção',
      'Logística',
      'Administrativo',
      'Recursos Humanos',
      'Financeiro',
      'Comercial',
    ],
    'funcoes': [
      'Operador de Máquinas',
      'Inspetor de Qualidade',
      'Técnico de Manutenção',
      'Auxiliar de Produção',
      'Supervisor',
      'Gerente',
      'Analista',
      'Assistente',
    ],
    'vinculos': [
      'CLT',
      'PJ',
      'Terceiro',
      'Estágio',
      'Temporário',
      'Autônomo',
    ],
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
    'turnos': [
      'Matutino (06:00-14:00)',
      'Vespertino (14:00-22:00)',
      'Noturno (22:00-06:00)',
      'Administrativo (08:00-17:00)',
      'Escala 12x36',
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
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _formData = EmployeeFormData();
    _initializeControllers();
    _initializeAnimation();
  }

  void _initializeControllers() {
    final fields = [
      'id',
      'matricula',
      'nome',
      'cpf',
      'rg',
      'setor',
      'funcao',
      'vinculo',
      'dataEntrada',
      'dataNascimento',
      'telefone',
      'email',
      'lider',
      'gestor',
      'localTrabalho',
      'turno',
      'dataDesligamento',
      'motivoDesligamento',
      'novoSetor',
      'novaFuncao',
      'novoVinculo',
      'novoTurno',
    ];

    for (final field in fields) {
      _controllers[field] = TextEditingController();
    }
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _removeAllOverlays();
    _animationController.dispose();
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
    await _animationController.reverse();
    widget.onClose();
  }

  // ==================== MÉTODOS DE SELEÇÃO DE DATA ====================

  Future<void> _selectDate(
    String field,
    Function(DateTime) onDateSelected,
  ) async {
    try {
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
    } catch (e) {
      debugPrint('Erro ao selecionar data: $e');
    }
  }

  void _selectDateEntrada() => _selectDate('dataEntrada', (date) {
        _formData.dataEntrada = date;
      });

  void _selectDateNascimento() => _selectDate('dataNascimento', (date) {
        _formData.dataNascimento = date;
      });

  void _selectDateDesligamento() => _selectDate('dataDesligamento', (date) {
        _formData.dataDesligamento = date;
      });

  Future<void> _selectDateRetornoFerias() async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _formData.dataRetornoFerias ??
            DateTime.now().add(const Duration(days: 30)),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );

      if (picked != null) {
        setState(() {
          _formData.dataRetornoFerias = picked;
        });
      }
    } catch (e) {
      debugPrint('Erro ao selecionar data de retorno: $e');
    }
  }

  // ==================== MÉTODOS DE IMAGEM ====================

  void _onImagePicked(File image) {
    setState(() {
      _imageFile = image;
      _formData.imagemPath = image.path;
    });
  }

  void _onImageRemoved() {
    setState(() {
      _imageFile = null;
      _formData.imagemPath = null;
    });

    _showSuccessSnackBar('Imagem removida');
  }

  // ==================== MÉTODOS DE OVERLAY ====================

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
        controller: _controllers['novo${_capitalize(type)}']!,
        position: position,
        buttonSize: size,
        onAdd: onAdd,
        onCancel: () {
          _overlays[type]?.remove();
          _overlays[type] = null;
          _controllers['novo${_capitalize(type)}']!.clear();
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
        selectedItems: selectedItems,
        onChanged: (updatedList) {
          setState(() {
            selectedItems.clear();
            selectedItems.addAll(updatedList);
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

  // ==================== MÉTODOS DE ADIÇÃO ====================

  void _addNewItem(String type, String listKey, TextEditingController controller) {
    if (controller.text.trim().isEmpty) return;

    setState(() {
      final newItem = controller.text.trim();
      if (!_suggestions[listKey]!.contains(newItem)) {
        _suggestions[listKey]!.add(newItem);
        _controllers[type]!.text = newItem;
      }
      controller.clear();
    });

    _overlays[type]?.remove();
    _overlays[type] = null;

    _showSuccessSnackBar('${_capitalize(type)} adicionado com sucesso!');
  }

  void _addNovoSetor() => _addNewItem('setor', 'setores', _controllers['novoSetor']!);
  void _addNovaFuncao() => _addNewItem('funcao', 'funcoes', _controllers['novaFuncao']!);
  void _addNovoVinculo() => _addNewItem('vinculo', 'vinculos', _controllers['novoVinculo']!);
  void _addNovoTurno() => _addNewItem('turno', 'turnos', _controllers['novoTurno']!);

  // ==================== MÉTODOS DE SALVAMENTO ====================

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    if (_formData.dataEntrada == null) {
      _showErrorSnackBar('Selecione a data de entrada');
      return;
    }

    setState(() => _isSaving = true);

    // Atualiza os dados do formulário
    _updateFormData();

    // Simula salvamento
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        widget.onSave?.call(_formData.toMap());
        _showSuccessSnackBar('Funcionário adicionado com sucesso!');
        _closeDrawer();
      }
    });
  }

  void _updateFormData() {
    _formData
      ..id = _controllers['id']!.text
      ..matricula = _controllers['matricula']!.text
      ..nome = _controllers['nome']!.text
      ..cpf = _controllers['cpf']!.text
      ..rg = _controllers['rg']!.text
      ..setor = _controllers['setor']!.text
      ..funcao = _controllers['funcao']!.text
      ..vinculo = _controllers['vinculo']!.text
      ..telefone = _controllers['telefone']!.text
      ..email = _controllers['email']!.text
      ..lider = _controllers['lider']!.text
      ..gestor = _controllers['gestor']!.text
      ..localTrabalho = _controllers['localTrabalho']!.text
      ..turno = _controllers['turno']!.text
      ..motivoDesligamento = _controllers['motivoDesligamento']!.text;
  }

  // ==================== MÉTODOS AUXILIARES ====================

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

  // ==================== BUILD METHODS ====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        GestureDetector(
          onTap: _closeDrawer,
          child: Container(color: Colors.black.withValues(alpha: 0.5)),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: SlideTransition(
            position: _slideAnimation,
            child: Material(
              elevation: 16,
              child: Container(
                width: size.width > 600 ? size.width * 0.6 : size.width * 0.9,
                height: size.height,
                color: theme.colorScheme.surface,
                child: Column(
                  children: [
                    _buildHeader(theme),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildForm(theme),
                      ),
                    ),
                    _buildFooter(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
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
              Icons.person_add,
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
                  'Adicionar Funcionário',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Preencha os dados do novo funcionário',
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              ImagePickerWidget(
                imageFile: _imageFile,
                onImagePicked: () async {
                  // Lógica de seleção de imagem
                },
                onImageRemoved: _onImageRemoved,
              ),
              const SizedBox(height: 32),
              _buildSection(
                theme,
                'Documentos Pessoais',
                Icons.assignment_outlined,
                DocumentsSection(
                  cpfController: _controllers['cpf']!,
                  rgController: _controllers['rg']!,
                  dataNascimentoController: _controllers['dataNascimento']!,
                  onSelectDateNascimento: _selectDateNascimento,
                ),
              ),
              const SizedBox(height: 32),
              _buildSection(
                theme,
                'Contato',
                Icons.contact_phone_outlined,
                ContactSection(
                  telefoneController: _controllers['telefone']!,
                  emailController: _controllers['email']!,
                ),
              ),
              const SizedBox(height: 32),
              _buildSection(
                theme,
                'Hierarquia',
                Icons.people_outline,
                HierarchySection(
                  liderController: _controllers['lider']!,
                  gestorController: _controllers['gestor']!,
                  funcionariosSugeridos: _suggestions['funcionarios']!,
                ),
              ),
              if (!_formData.statusAtivo) ...[
                const SizedBox(height: 32),
                _buildSection(
                  theme,
                  'Desligamento',
                  Icons.logout_outlined,
                  TerminationSection(
                    dataDesligamentoController:
                        _controllers['dataDesligamento']!,
                    motivoDesligamentoController:
                        _controllers['motivoDesligamento']!,
                    onSelectDateDesligamento: _selectDateDesligamento,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              _buildSection(
                theme,
                'Informações Básicas',
                Icons.info_outlined,
                BasicInfoSection(
                  idController: _controllers['id']!,
                  matriculaController: _controllers['matricula']!,
                  nomeController: _controllers['nome']!,
                  dataEntradaController: _controllers['dataEntrada']!,
                  onSelectDateEntrada: _selectDateEntrada,
                ),
              ),
              const SizedBox(height: 32),
              _buildSection(
                theme,
                'Cargo e Setor',
                Icons.work_outline,
                JobSection(
                  setorController: _controllers['setor']!,
                  funcaoController: _controllers['funcao']!,
                  vinculoController: _controllers['vinculo']!,
                  setoresSugeridos: _suggestions['setores']!,
                  funcoesSugeridas: _suggestions['funcoes']!,
                  vinculosSugeridos: _suggestions['vinculos']!,
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
              const SizedBox(height: 32),
              _buildSection(
                theme,
                'Condições de Trabalho',
                Icons.settings_outlined,
                WorkConditionsSection(
                  localTrabalhoController: _controllers['localTrabalho']!,
                  turnoController: _controllers['turno']!,
                  locaisTrabalhoSugeridos: _suggestions['locaisTrabalho']!,
                  turnosSugeridos: _suggestions['turnos']!,
                  episSelecionados: _formData.epis,
                  riscosSelecionados: _formData.riscos,
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
                    _formData.epis,
                  ),
                  onSelectRiscos: () => _showMultiSelectOverlay(
                    'riscos',
                    'Selecionar Riscos Associados',
                    Icons.warning_outlined,
                    _suggestions['riscos']!,
                    _formData.riscos,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildSection(
                theme,
                'Status',
                Icons.info_outlined,
                StatusSection(
                  statusAtivo: _formData.statusAtivo,
                  statusFerias: _formData.statusFerias,
                  dataRetornoFerias: _formData.dataRetornoFerias,
                  onStatusAtivoChanged: (value) {
                    setState(() => _formData.statusAtivo = value);
                  },
                  onStatusFeriasChanged: (value) {
                    setState(() => _formData.statusFerias = value);
                  },
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
    return Column(
      children: [
        ImagePickerWidget(
          imageFile: _imageFile,
          onImagePicked: () async {
            // Lógica de seleção
          },
          onImageRemoved: _onImageRemoved,
        ),
        const SizedBox(height: 32),
        _buildSection(
          theme,
          'Informações Básicas',
          Icons.info_outlined,
          BasicInfoSection(
            idController: _controllers['id']!,
            matriculaController: _controllers['matricula']!,
            nomeController: _controllers['nome']!,
            dataEntradaController: _controllers['dataEntrada']!,
            onSelectDateEntrada: _selectDateEntrada,
          ),
        ),
        // ... Adicione as outras seções aqui
      ],
    );
  }

  Widget _buildSection(
    ThemeData theme,
    String title,
    IconData icon,
    Widget child,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
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
              label: Text(_isSaving ? 'Salvando...' : 'Adicionar Funcionário'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
