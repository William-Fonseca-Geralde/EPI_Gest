import 'package:epi_gest_project/ui/inventory/widgets/widgets_epis/epis_form_sections.dart';
import 'package:epi_gest_project/ui/widgets/image_picker_widget.dart';
import 'package:epi_gest_project/ui/widgets/overlays.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:io';

// 1. Modelo de dados para o formulário de EPI
class EpiFormData {
  String? id;
  String? imagemPath;
  String codigo = '';
  String ca = '';
  DateTime? validadeCA;
  String nome = '';
  String categoria = '';
  String marca = '';
  String unidade = '';
  String fornecedor = '';
  String localizacao = '';
  int quantidade = 0;
  double valorUnitario = 0.0;
  int? estoqueMin;
  int? estoqueMax;
  int? periodicidadeTroca;
  bool statusAtivo = true;
  String observacoes = '';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagemPath': imagemPath,
      'codigo': codigo,
      'ca': ca,
      'validadeCA': validadeCA?.toIso8601String(),
      'nome': nome,
      'categoria': categoria,
      'marca': marca,
      'unidade': unidade,
      'fornecedor': fornecedor,
      'localizacao': localizacao,
      'quantidade': quantidade,
      'valorUnitario': valorUnitario,
      'estoqueMin': estoqueMin,
      'estoqueMax': estoqueMax,
      'periodicidadeTroca': periodicidadeTroca,
      'statusAtivo': statusAtivo,
      'observacoes': observacoes,
    };
  }
}

class AddEpiDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Map<String, dynamic>)? onSave;

  const AddEpiDrawer({super.key, required this.onClose, this.onSave});

  @override
  State<AddEpiDrawer> createState() => _AddEpiDrawerState();
}

class _AddEpiDrawerState extends State<AddEpiDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  late EpiFormData _formData;

  // 2. Gerenciamento centralizado de controllers, keys e overlays
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, GlobalKey> _overlayKeys = {
    'categoria': GlobalKey(),
    'marca': GlobalKey(),
    'unidade': GlobalKey(),
    'fornecedor': GlobalKey(),
    'localizacao': GlobalKey(),
  };
  final Map<String, OverlayEntry?> _overlays = {
    'categoria': null,
    'marca': null,
    'unidade': null,
    'fornecedor': null,
    'localizacao': null,
  };

  // Listas de sugestões
  final Map<String, List<String>> _suggestions = {
    'categorias': [
      'Proteção Respiratória',
      'Proteção para Cabeça',
      'Proteção para Mãos',
      'Proteção para Pés',
      'Proteção Auditiva',
      'Proteção Visual',
      'Proteção contra Quedas',
      'Vestimentas de Proteção',
    ],
    'marcas': [
      '3M',
      'SafetyPro',
      'DuPont',
      'Honeywell',
      'MSA',
      'JSP',
      'Delta Plus',
    ],
    'unidades': [
      'Unidade',
      'Caixa',
      'Pacote',
      'Par',
      'Jogo',
      'Kit',
      'Litro',
      'Metro',
    ],
    'fornecedores': [
      'EPI Tech Ltda',
      'Segurança Total',
      'ProteMax Equipamentos',
      'SafeWork Brasil',
      'Equipamentos Industriais SA',
    ],
    'localizacoes': [
      'Almoxarifado A',
      'Almoxarifado B',
      'Estoque Central',
      'Setor Produção',
      'Setor Manutenção',
      'Depósito 1',
      'Depósito 2',
    ],
  };

  bool _isSaving = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _formData = EpiFormData();
    _initializeControllers();
    _initializeAnimation();
    _controllers['valorUnitario']!.addListener(_formatValor);
  }

  void _initializeControllers() {
    final fields = [
      'codigo',
      'ca',
      'validadeCA',
      'nome',
      'categoria',
      'marca',
      'unidade',
      'fornecedor',
      'localizacao',
      'quantidade',
      'valorUnitario',
      'estoqueMin',
      'estoqueMax',
      'periodicidadeTroca',
      'observacoes',
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
    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
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

  // ==================== MÉTODOS DE FORMATAÇÃO E SELEÇÃO ====================

  void _formatValor() {
    String text = _controllers['valorUnitario']!.text.replaceAll(
      RegExp(r'[^\d]'),
      '',
    );
    if (text.isEmpty) return;

    double value = double.parse(text) / 100;
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    String formatted = formatter.format(value);

    if (formatted != _controllers['valorUnitario']!.text) {
      _controllers['valorUnitario']!.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _selectDate() async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(const Duration(days: 365)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 3650)),
      );

      if (picked != null) {
        setState(() {
          _formData.validadeCA = picked;
          _controllers['validadeCA']!.text = DateFormat(
            'dd/MM/yyyy',
          ).format(picked);
        });
      }
    } catch (e) {
      debugPrint('Erro ao selecionar data: $e');
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

  // ==================== MODAIS PARA CADASTRO RÁPIDO ====================

  void _showCategoriaModal() {
    final theme = Theme.of(context);
    String nomeCategoria = '';

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
                    // HEADER DO MODAL
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Adicionar Categoria',
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

                    // CAMPO NOME DA CATEGORIA
                    _buildModalTextField(
                      label: 'Nome da Categoria*',
                      hint: 'Ex: Proteção Respiratória, Proteção para Mãos',
                      icon: Icons.category_outlined,
                      onChanged: (value) => nomeCategoria = value,
                    ),
                    const SizedBox(height: 24),

                    // BOTÕES DO MODAL
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
                              if (nomeCategoria.isNotEmpty) {
                                setState(() {
                                  if (!_suggestions['categorias']!.contains(nomeCategoria)) {
                                    _suggestions['categorias']!.add(nomeCategoria);
                                  }
                                  _controllers['categoria']!.text = nomeCategoria;
                                });
                                Navigator.pop(context);
                                _showSuccessSnackBar('Categoria adicionada com sucesso!');
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

  void _showMarcaModal() {
    final theme = Theme.of(context);
    String nomeMarca = '';
    bool statusAtiva = true;

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
                    // HEADER DO MODAL
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Adicionar Marca',
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

                    // CAMPO NOME DA MARCA
                    _buildModalTextField(
                      label: 'Nome da Marca*',
                      hint: 'Ex: 3M, SafetyPro, DuPont',
                      icon: Icons.branding_watermark_outlined,
                      onChanged: (value) => nomeMarca = value,
                    ),
                    const SizedBox(height: 16),

                    // SWITCH STATUS - PADRÃO IDÊNTICO
                    _buildModalSwitch(
                      value: statusAtiva,
                      onChanged: (value) => setState(() => statusAtiva = value),
                      label: 'Status da Marca',
                      activeText: 'Ativa',
                      inactiveText: 'Inativa',
                      theme: theme,
                    ),
                    const SizedBox(height: 24),

                    // BOTÕES DO MODAL
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
                              if (nomeMarca.isNotEmpty) {
                                setState(() {
                                  if (!_suggestions['marcas']!.contains(nomeMarca)) {
                                    _suggestions['marcas']!.add(nomeMarca);
                                  }
                                  _controllers['marca']!.text = nomeMarca;
                                });
                                Navigator.pop(context);
                                _showSuccessSnackBar('Marca adicionada com sucesso!');
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

  void _showUnidadeModal() {
    final theme = Theme.of(context);
    String nomeUnidade = '';

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
                    // HEADER DO MODAL
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Adicionar Unidade',
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

                    // CAMPO NOME DA UNIDADE
                    _buildModalTextField(
                      label: 'Nome da Unidade*',
                      hint: 'Ex: Unidade, Caixa, Par, Quilograma',
                      icon: Icons.straighten_outlined,
                      onChanged: (value) => nomeUnidade = value,
                    ),
                    const SizedBox(height: 24),

                    // BOTÕES DO MODAL
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
                              if (nomeUnidade.isNotEmpty) {
                                setState(() {
                                  if (!_suggestions['unidades']!.contains(nomeUnidade)) {
                                    _suggestions['unidades']!.add(nomeUnidade);
                                  }
                                  _controllers['unidade']!.text = nomeUnidade;
                                });
                                Navigator.pop(context);
                                _showSuccessSnackBar('Unidade adicionada com sucesso!');
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

  void _showFornecedorModal() {
    final theme = Theme.of(context);
    String razaoSocial = '';
    String cnpj = '';
    bool statusAtivo = true;

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
                    // HEADER DO MODAL
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Adicionar Fornecedor',
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

                    // CAMPO RAZÃO SOCIAL
                    _buildModalTextField(
                      label: 'Razão Social*',
                      hint: 'Ex: Empresa XYZ Ltda',
                      icon: Icons.business_outlined,
                      onChanged: (value) => razaoSocial = value,
                    ),
                    const SizedBox(height: 16),

                    // CAMPO CNPJ
                    _buildModalTextField(
                      label: 'CNPJ*',
                      hint: 'Ex: 12.345.678/0001-90',
                      icon: Icons.badge_outlined,
                      onChanged: (value) => cnpj = value,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(14),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // SWITCH STATUS - PADRÃO IDÊNTICO
                    _buildModalSwitch(
                      value: statusAtivo,
                      onChanged: (value) => setState(() => statusAtivo = value),
                      label: 'Status do Fornecedor',
                      activeText: 'Ativo',
                      inactiveText: 'Inativo',
                      theme: theme,
                    ),
                    const SizedBox(height: 24),

                    // BOTÕES DO MODAL
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
                              if (razaoSocial.isNotEmpty && cnpj.isNotEmpty) {
                                setState(() {
                                  if (!_suggestions['fornecedores']!.contains(razaoSocial)) {
                                    _suggestions['fornecedores']!.add(razaoSocial);
                                  }
                                  _controllers['fornecedor']!.text = razaoSocial;
                                });
                                Navigator.pop(context);
                                _showSuccessSnackBar('Fornecedor adicionado com sucesso!');
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

  void _showLocalizacaoModal() {
    final theme = Theme.of(context);
    String nomeUnidade = '';
    String endereco = '';
    String produtoCodigo = '';
    String produtoDescricao = '';

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
                height: 600,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // HEADER DO MODAL
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Adicionar Localização',
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

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // DROPDOWN UNIDADE
                            _buildModalDropdown(
                              label: 'Unidade Vinculada*',
                              value: nomeUnidade.isEmpty ? null : nomeUnidade,
                              items: _suggestions['unidades']!,
                              onChanged: (value) => setState(() => nomeUnidade = value!),
                              theme: theme,
                            ),
                            const SizedBox(height: 16),

                            // CAMPO ENDEREÇO
                            _buildModalTextField(
                              label: 'Endereço*',
                              hint: 'Ex: Rua A, 123 - Setor B, Prateleira 4',
                              icon: Icons.location_on_outlined,
                              maxLines: 2,
                              onChanged: (value) => endereco = value,
                            ),
                            const SizedBox(height: 16),

                            // CAMPO CÓDIGO DO PRODUTO
                            _buildModalTextField(
                              label: 'Código do Produto*',
                              hint: 'Ex: EPI001, EPI002',
                              icon: Icons.qr_code_outlined,
                              onChanged: (value) => produtoCodigo = value,
                            ),
                            const SizedBox(height: 16),

                            // CAMPO DESCRIÇÃO DO PRODUTO
                            _buildModalTextField(
                              label: 'Descrição do Produto*',
                              hint: 'Ex: Luva de Proteção Nitrílica',
                              icon: Icons.description_outlined,
                              onChanged: (value) => produtoDescricao = value,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // BOTÕES DO MODAL
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
                              if (nomeUnidade.isNotEmpty && endereco.isNotEmpty && 
                                  produtoCodigo.isNotEmpty && produtoDescricao.isNotEmpty) {
                                final novaLocalizacao = '$nomeUnidade - $endereco';
                                setState(() {
                                  if (!_suggestions['localizacoes']!.contains(novaLocalizacao)) {
                                    _suggestions['localizacoes']!.add(novaLocalizacao);
                                  }
                                  _controllers['localizacao']!.text = novaLocalizacao;
                                });
                                Navigator.pop(context);
                                _showSuccessSnackBar('Localização adicionada com sucesso!');
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

  // ==================== COMPONENTES DOS MODAIS ====================

  Widget _buildModalTextField({
    required String label,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);

    return TextFormField(
      onChanged: onChanged,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
        ),
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
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines > 1 ? 16 : 12,
        ),
      ),
    );
  }

  Widget _buildModalDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required ThemeData theme,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        prefixIcon: Icon(
          Icons.category_outlined,
          color: theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildModalSwitch({
    required bool value,
    required Function(bool) onChanged,
    required String label,
    required String activeText,
    required String inactiveText,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.toggle_on_outlined,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: MaterialStateProperty.all(theme.colorScheme.onPrimary),
            trackColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return theme.colorScheme.primary;
              }
              return theme.colorScheme.surfaceVariant;
            }),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: value 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value ? activeText : inactiveText,
              style: TextStyle(
                color: value ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MÉTODOS DE SALVAMENTO ====================

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Por favor, corrija os erros no formulário.');
      return;
    }

    setState(() => _isSaving = true);
    _updateFormData();

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        widget.onSave?.call(_formData.toMap());
        _showSuccessSnackBar('EPI adicionado com sucesso!');
        _closeDrawer();
      }
    });
  }

  void _updateFormData() {
    String valorText = _controllers['valorUnitario']!.text
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();

    _formData
      ..codigo = _controllers['codigo']!.text
      ..ca = _controllers['ca']!.text
      ..nome = _controllers['nome']!.text
      ..categoria = _controllers['categoria']!.text
      ..marca = _controllers['marca']!.text
      ..unidade = _controllers['unidade']!.text
      ..fornecedor = _controllers['fornecedor']!.text
      ..localizacao = _controllers['localizacao']!.text
      ..quantidade = int.tryParse(_controllers['quantidade']!.text) ?? 0
      ..valorUnitario = double.tryParse(valorText) ?? 0.0
      ..estoqueMin = int.tryParse(_controllers['estoqueMin']!.text)
      ..estoqueMax = int.tryParse(_controllers['estoqueMax']!.text)
      ..periodicidadeTroca = int.tryParse(
        _controllers['periodicidadeTroca']!.text,
      )
      ..observacoes = _controllers['observacoes']!.text;
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
                      child: SingleChildScrollView(child: _buildForm(theme)),
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
              Icons.add_box,
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
                  'Adicionar EPI',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Preencha os dados do novo equipamento',
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
                onImagePicked: _onImagePicked,
                onImageRemoved: _onImageRemoved,
              ),
              const SizedBox(height: 32),
              _buildSection(
                theme,
                'Informações Básicas',
                Icons.info_outline,
                BasicInfoSection(
                  codigoController: _controllers['codigo']!,
                  caController: _controllers['ca']!,
                  validadeController: _controllers['validadeCA']!,
                  nomeController: _controllers['nome']!,
                  onSelectDate: _selectDate,
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                theme,
                'Detalhes Adicionais',
                Icons.more_horiz_outlined,
                DetailsSection(
                  periodicidadeController: _controllers['periodicidadeTroca']!,
                  observacoesController: _controllers['observacoes']!,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              _buildSection(
                theme,
                'Categoria e Fornecedor',
                Icons.business_center_outlined,
                CategorySupplierSection(
                  categoriaController: _controllers['categoria']!,
                  marcaController: _controllers['marca']!,
                  fornecedorController: _controllers['fornecedor']!,
                  localizacaoController: _controllers['localizacao']!,
                  categoriasSugeridas: _suggestions['categorias']!,
                  marcasSugeridas: _suggestions['marcas']!,
                  fornecedoresSugeridos: _suggestions['fornecedores']!,
                  localizacoesSugeridas: _suggestions['localizacoes']!,
                  categoriaButtonKey: _overlayKeys['categoria']!,
                  marcaButtonKey: _overlayKeys['marca']!,
                  fornecedorButtonKey: _overlayKeys['fornecedor']!,
                  localizacaoButtonKey: _overlayKeys['localizacao']!,
                  onAddCategoria: _showCategoriaModal,
                  onAddMarca: _showMarcaModal,
                  onAddFornecedor: _showFornecedorModal,
                  onAddLocalizacao: _showLocalizacaoModal,
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                theme,
                'Estoque e Valores',
                Icons.inventory_outlined,
                StockSection(
                  quantidadeController: _controllers['quantidade']!,
                  valorController: _controllers['valorUnitario']!,
                  estoqueMinController: _controllers['estoqueMin']!,
                  estoqueMaxController: _controllers['estoqueMax']!,
                  unidadeController: _controllers['unidade']!,
                  unidadesSugeridas: _suggestions['unidades']!,
                  unidadeButtonKey: _overlayKeys['unidade']!,
                  onAddUnidade: _showUnidadeModal,
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                theme,
                'Status',
                Icons.toggle_on_outlined,
                StatusSection(
                  statusAtivo: _formData.statusAtivo,
                  onStatusChanged: (value) =>
                      setState(() => _formData.statusAtivo = value),
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
          onImagePicked: _onImagePicked,
          onImageRemoved: _onImageRemoved,
        ),
        const SizedBox(height: 32),
        _buildSection(
          theme,
          'Informações Básicas',
          Icons.info_outline,
          BasicInfoSection(
            codigoController: _controllers['codigo']!,
            caController: _controllers['ca']!,
            validadeController: _controllers['validadeCA']!,
            nomeController: _controllers['nome']!,
            onSelectDate: _selectDate,
          ),
        ),
        const SizedBox(height: 24),
        _buildSection(
          theme,
          'Categoria e Fornecedor',
          Icons.business_center_outlined,
          CategorySupplierSection(
            categoriaController: _controllers['categoria']!,
            marcaController: _controllers['marca']!,
            fornecedorController: _controllers['fornecedor']!,
            localizacaoController: _controllers['localizacao']!,
            categoriasSugeridas: _suggestions['categorias']!,
            marcasSugeridas: _suggestions['marcas']!,
            fornecedoresSugeridos: _suggestions['fornecedores']!,
            localizacoesSugeridas: _suggestions['localizacoes']!,
            categoriaButtonKey: _overlayKeys['categoria']!,
            marcaButtonKey: _overlayKeys['marca']!,
            fornecedorButtonKey: _overlayKeys['fornecedor']!,
            localizacaoButtonKey: _overlayKeys['localizacao']!,
            onAddCategoria: _showCategoriaModal,
            onAddMarca: _showMarcaModal,
            onAddFornecedor: _showFornecedorModal,
            onAddLocalizacao: _showLocalizacaoModal,
          ),
        ),
        const SizedBox(height: 24),
        _buildSection(
          theme,
          'Estoque e Valores',
          Icons.inventory_outlined,
          StockSection(
            quantidadeController: _controllers['quantidade']!,
            valorController: _controllers['valorUnitario']!,
            estoqueMinController: _controllers['estoqueMin']!,
            estoqueMaxController: _controllers['estoqueMax']!,
            unidadeController: _controllers['unidade']!,
            unidadesSugeridas: _suggestions['unidades']!,
            unidadeButtonKey: _overlayKeys['unidade']!,
            onAddUnidade: _showUnidadeModal,
          ),
        ),
        const SizedBox(height: 24),
        _buildSection(
          theme,
          'Detalhes Adicionais',
          Icons.more_horiz_outlined,
          DetailsSection(
            periodicidadeController: _controllers['periodicidadeTroca']!,
            observacoesController: _controllers['observacoes']!,
          ),
        ),
        const SizedBox(height: 24),
        _buildSection(
          theme,
          'Status',
          Icons.toggle_on_outlined,
          StatusSection(
            statusAtivo: _formData.statusAtivo,
            onStatusChanged: (value) =>
                setState(() => _formData.statusAtivo = value),
          ),
        ),
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
        border: Border.all(color: theme.colorScheme.outlineVariant),
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
          top: BorderSide(color: theme.colorScheme.outlineVariant),
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
              label: Text(_isSaving ? 'Salvando...' : 'Adicionar EPI'),
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