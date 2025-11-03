import 'package:epi_gest_project/domain/models/epi/epi_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class EditEpiDrawer extends StatefulWidget {
  final EpiModel epi;
  final VoidCallback onClose;
  final Function(Map<String, dynamic>)? onSave;

  const EditEpiDrawer({
    super.key,
    required this.epi,
    required this.onClose,
    this.onSave,
  });

  @override
  State<EditEpiDrawer> createState() => _EditEpiDrawerState();
}

class _EditEpiDrawerState extends State<EditEpiDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();

  // Controllers dos campos
  late TextEditingController _nomeController;
  late TextEditingController _caController;
  late TextEditingController _categoriaController;
  late TextEditingController _quantidadeController;
  late TextEditingController _valorController;
  late TextEditingController _validadeController;
  late TextEditingController _fornecedorController;

  // Controllers para adicionar nova categoria/fornecedor
  final _novaCategoriaController = TextEditingController();
  final _novoFornecedorController = TextEditingController();

  // GlobalKeys para posicionar os overlays
  final GlobalKey _categoriaButtonKey = GlobalKey();
  final GlobalKey _fornecedorButtonKey = GlobalKey();

  DateTime? _selectedDate;
  bool _isSaving = false;

  // Overlays
  OverlayEntry? _categoriaOverlay;
  OverlayEntry? _fornecedorOverlay;

  // Imagem do EPI
  File? _imageFile;

  // Listas (podem vir do controller futuramente)
  final List<String> _categoriasSugeridas = [
    'Proteção Respiratória',
    'Proteção para Cabeça',
    'Proteção para Mãos',
    'Proteção para Pés',
    'Proteção Auditiva',
    'Proteção Visual',
    'Proteção contra Quedas',
    'Vestimentas de Proteção',
  ];

  final List<String> _fornecedoresSugeridos = [
    'EPI Tech Ltda',
    'Segurança Total',
    'ProteMax Equipamentos',
    'SafeWork Brasil',
    'Equipamentos Industriais SA',
  ];

  @override
  void initState() {
    super.initState();

    // Inicializa controllers com os valores do EPI
    _nomeController = TextEditingController(text: widget.epi.nome);
    _caController = TextEditingController(text: widget.epi.ca);
    _categoriaController = TextEditingController(text: widget.epi.categoria);
    _quantidadeController = TextEditingController(
      text: widget.epi.quantidadeEstoque.toString(),
    );
    _fornecedorController = TextEditingController(text: widget.epi.fornecedor);
    _validadeController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(widget.epi.dataValidade),
    );
    _selectedDate = widget.epi.dataValidade;

    // Formata o valor inicial
    _valorController = TextEditingController();
    _formatInitialValor();

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

    // Adiciona listener para formatar valor em tempo real
    _valorController.addListener(_formatValor);
  }

  void _formatInitialValor() {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    _valorController.text = formatter.format(widget.epi.valorUnitario);
  }

  @override
  void dispose() {
    _removeOverlays();
    _animationController.dispose();
    _nomeController.dispose();
    _caController.dispose();
    _categoriaController.dispose();
    _quantidadeController.dispose();
    _valorController.removeListener(_formatValor);
    _valorController.dispose();
    _validadeController.dispose();
    _fornecedorController.dispose();
    _novaCategoriaController.dispose();
    _novoFornecedorController.dispose();
    super.dispose();
  }

  void _removeOverlays() {
    _categoriaOverlay?.remove();
    _categoriaOverlay = null;
    _fornecedorOverlay?.remove();
    _fornecedorOverlay = null;
  }

  void _formatValor() {
    String text = _valorController.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.isEmpty) return;

    double value = double.parse(text) / 100;
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    String formatted = formatter.format(value);

    if (formatted != _valorController.text) {
      _valorController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _closeDrawer() async {
    _removeOverlays();
    await _animationController.reverse();
    widget.onClose();
  }

  Future<void> _selectDate() async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate:
            _selectedDate ?? DateTime.now().add(const Duration(days: 365)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 3650)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme,
            ),
            child: child!,
          );
        },
      );

      if (picked != null && picked != _selectedDate) {
        setState(() {
          _selectedDate = picked;
          _validadeController.text = DateFormat('dd/MM/yyyy').format(picked);
        });
      }
    } catch (e) {
      debugPrint('Erro ao selecionar data: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _imageFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      debugPrint('Erro ao selecionar imagem: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Text('Erro ao selecionar imagem: $e'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Imagem removida'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddCategoriaOverlay() {
    if (_categoriaOverlay != null) {
      _categoriaOverlay!.remove();
      _categoriaOverlay = null;
      return;
    }

    final RenderBox renderBox =
        _categoriaButtonKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _categoriaOverlay = OverlayEntry(
      builder: (context) => _buildAddOverlayDropdown(
        theme: Theme.of(context),
        title: 'Adicionar Nova Categoria',
        controller: _novaCategoriaController,
        position: position,
        buttonSize: size,
        onAdd: _addNovaCategoria,
        onCancel: () {
          _categoriaOverlay?.remove();
          _categoriaOverlay = null;
          _novaCategoriaController.clear();
        },
      ),
    );

    Overlay.of(context).insert(_categoriaOverlay!);
  }

  void _showAddFornecedorOverlay() {
    if (_fornecedorOverlay != null) {
      _fornecedorOverlay!.remove();
      _fornecedorOverlay = null;
      return;
    }

    final RenderBox renderBox =
        _fornecedorButtonKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _fornecedorOverlay = OverlayEntry(
      builder: (context) => _buildAddOverlayDropdown(
        theme: Theme.of(context),
        title: 'Adicionar Novo Fornecedor',
        controller: _novoFornecedorController,
        position: position,
        buttonSize: size,
        onAdd: _addNovoFornecedor,
        onCancel: () {
          _fornecedorOverlay?.remove();
          _fornecedorOverlay = null;
          _novoFornecedorController.clear();
        },
      ),
    );

    Overlay.of(context).insert(_fornecedorOverlay!);
  }

  void _addNovaCategoria() {
    if (_novaCategoriaController.text.trim().isNotEmpty) {
      setState(() {
        final novaCategoria = _novaCategoriaController.text.trim();
        if (!_categoriasSugeridas.contains(novaCategoria)) {
          _categoriasSugeridas.add(novaCategoria);
          _categoriaController.text = novaCategoria;
        }
        _novaCategoriaController.clear();
      });

      _categoriaOverlay?.remove();
      _categoriaOverlay = null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Categoria adicionada com sucesso!'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _addNovoFornecedor() {
    if (_novoFornecedorController.text.trim().isNotEmpty) {
      setState(() {
        final novoFornecedor = _novoFornecedorController.text.trim();
        if (!_fornecedoresSugeridos.contains(novoFornecedor)) {
          _fornecedoresSugeridos.add(novoFornecedor);
          _fornecedorController.text = novoFornecedor;
        }
        _novoFornecedorController.clear();
      });

      _fornecedorOverlay?.remove();
      _fornecedorOverlay = null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Fornecedor adicionado com sucesso!'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      // Extrai o valor numérico do campo formatado
      String valorText = _valorController.text
          .replaceAll('R\$', '')
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .trim();
      double valorNumerico = double.tryParse(valorText) ?? 0.0;

      // Dados do formulário
      final data = {
        'id': widget.epi.id,
        'nome': _nomeController.text,
        'ca': _caController.text,
        'categoria': _categoriaController.text,
        'quantidade': int.tryParse(_quantidadeController.text) ?? 0,
        'valor': valorNumerico,
        'validade': _selectedDate?.toIso8601String(),
        'fornecedor': _fornecedorController.text,
        'descricao': widget.epi.descricao,
        'imagePath': _imageFile?.path,
      };

      // Simula salvamento
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('EPI atualizado com sucesso!'),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _closeDrawer();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Overlay escuro
        GestureDetector(
          onTap: _closeDrawer,
          child: Container(color: Colors.black.withValues(alpha: 0.5)),
        ),

        // Painel lateral
        Align(
          alignment: Alignment.centerRight,
          child: SlideTransition(
            position: _slideAnimation,
            child: Material(
              elevation: 16,
              child: Container(
                width: size.width > 600 ? size.width * 0.45 : size.width * 0.85,
                height: size.height,
                color: theme.colorScheme.surface,
                child: Column(
                  children: [
                    // Cabeçalho
                    _buildHeader(theme),

                    // Formulário
                    Expanded(child: _buildForm(theme)),

                    // Rodapé com botões
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

  Widget _buildAddOverlayDropdown({
    required ThemeData theme,
    required String title,
    required TextEditingController controller,
    required Offset position,
    required Size buttonSize,
    required VoidCallback onAdd,
    required VoidCallback onCancel,
  }) {
    // Obtém o tamanho da tela
    final screenSize = MediaQuery.of(context).size;
    const dropdownWidth = 450.0;
    const dropdownMaxHeight = 200.0;

    // Calcula a posição X (horizontal)
    double left = position.dx;
    double? right;

    // Se o dropdown ultrapassar a borda direita, alinha pela direita
    if (left + dropdownWidth > screenSize.width) {
      right = screenSize.width - (position.dx + buttonSize.width);
      left = screenSize.width - right - dropdownWidth;
    }

    // Calcula a posição Y (vertical)
    double top = position.dy + buttonSize.height + 16;
    double? bottom;

    // Se o dropdown ultrapassar a borda inferior, mostra acima do botão
    if (top + dropdownMaxHeight > screenSize.height) {
      bottom = screenSize.height - position.dy + 16;
      top = position.dy - dropdownMaxHeight - 16;
    }

    return Stack(
      children: [
        // Fundo transparente para fechar ao clicar fora
        Positioned.fill(
          child: GestureDetector(
            onTap: onCancel,
            child: Container(color: Colors.transparent),
          ),
        ),
        // Dropdown posicionado
        Positioned(
          left: left,
          right: right,
          top: bottom == null ? top : null,
          bottom: bottom,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: dropdownWidth,
              constraints: const BoxConstraints(maxHeight: dropdownMaxHeight),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: onCancel,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Botões
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Digite o nome',
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          onSubmitted: (_) {
                            if (controller.text.trim().isNotEmpty) {
                              onAdd();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: () {
                          if (controller.text.trim().isNotEmpty) {
                            onAdd();
                          }
                        },
                        icon: const Icon(Icons.check),
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
              Icons.edit,
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
                  'Editar EPI',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Atualize os dados do equipamento',
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
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Seção: Informações Básicas
          _buildSectionTitle('Informações Básicas', Icons.info_outline),
          const SizedBox(height: 16),

          // Imagem, CA, Validade e Nome
          Row(
            children: [
              // Container da Imagem
              _buildImagePicker(theme),

              const SizedBox(width: 16),

              // CA, Validade e Nome
              Expanded(
                child: Column(
                  spacing: 16,
                  children: [
                    // Primeira linha: CA e Validade
                    Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _caController,
                            label: 'CA',
                            hint: 'Ex: 12345',
                            icon: Icons.verified_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Obrigatório';
                              }
                              return null;
                            },
                          ),
                        ),
                        Expanded(
                          child: _buildDateField(
                            controller: _validadeController,
                            label: 'Validade',
                            hint: 'dd/mm/aaaa',
                            icon: Icons.calendar_today_outlined,
                            onTap: _selectDate,
                          ),
                        ),
                      ],
                    ),
                    // Segunda linha: Nome do EPI
                    _buildTextField(
                      controller: _nomeController,
                      label: 'Nome do EPI',
                      hint: 'Ex: Capacete de Segurança',
                      icon: Icons.label_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }
                        return null;
                      },
                    ),
                    // Categoria com botão de adicionar
                    _buildAutocompleteFieldWithAdd(
                      controller: _categoriaController,
                      label: 'Categoria',
                      hint: 'Selecione ou digite uma categoria',
                      icon: Icons.category_outlined,
                      suggestions: _categoriasSugeridas,
                      buttonKey: _categoriaButtonKey,
                      onToggleAdd: _showAddCategoriaOverlay,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Seção: Fornecedor
          _buildSectionTitle('Fornecedor', Icons.business_outlined),
          const SizedBox(height: 16),

          // Fornecedor com botão de adicionar
          _buildAutocompleteFieldWithAdd(
            controller: _fornecedorController,
            label: 'Fornecedor',
            hint: 'Selecione ou digite um fornecedor',
            icon: Icons.store_outlined,
            suggestions: _fornecedoresSugeridos,
            buttonKey: _fornecedorButtonKey,
            onToggleAdd: _showAddFornecedorOverlay,
          ),

          const SizedBox(height: 32),

          // Seção: Estoque e Valores
          _buildSectionTitle('Estoque e Valores', Icons.inventory_outlined),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _quantidadeController,
                  label: 'Quantidade',
                  hint: '0',
                  icon: Icons.numbers,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Obrigatório';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Número inválido';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _valorController,
                  label: 'Valor Unitário',
                  hint: 'R\$ 0,00',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Obrigatório';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildImagePicker(ThemeData theme) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: _imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _imageFile!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Alterar\nImagem',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (_imageFile != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: _pickImage,
                icon: const Icon(Icons.edit, size: 18),
                tooltip: 'Alterar imagem',
                iconSize: 18,
                padding: const EdgeInsets.all(8),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: _removeImage,
                icon: const Icon(Icons.delete, size: 18),
                tooltip: 'Remover imagem',
                iconSize: 18,
                padding: const EdgeInsets.all(8),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.errorContainer,
                  foregroundColor: theme.colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(icon: const Icon(Icons.event), onPressed: onTap),
      ),
      readOnly: true,
      onTap: onTap,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Obrigatório';
        }
        return null;
      },
    );
  }

  Widget _buildAutocompleteFieldWithAdd({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required List<String> suggestions,
    required GlobalKey buttonKey,
    required VoidCallback onToggleAdd,
  }) {
    return Row(
      children: [
        Expanded(
          child: Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return suggestions;
              }
              return suggestions.where((String option) {
                return option.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    );
              });
            },
            onSelected: (String selection) {
              controller.text = selection;
            },
            fieldViewBuilder: (
              BuildContext context,
              TextEditingController fieldController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted,
            ) {
              fieldController.text = controller.text;
              fieldController.addListener(() {
                controller.text = fieldController.text;
              });

              return TextFormField(
                controller: fieldController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: label,
                  hintText: hint,
                  prefixIcon: Icon(icon),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          key: buttonKey,
          onPressed: onToggleAdd,
          icon: const Icon(Icons.add),
          tooltip: 'Adicionar novo',
        ),
      ],
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
              label: Text(_isSaving ? 'Salvando...' : 'Salvar Alterações'),
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
