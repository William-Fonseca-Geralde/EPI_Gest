import 'package:epi_gest_project/ui/utils/input_formatters.dart';
import 'package:epi_gest_project/ui/widgets/base_drawer.dart';
import 'package:epi_gest_project/ui/widgets/form_fields.dart';
import 'package:epi_gest_project/ui/widgets/info_section.dart';
import 'package:epi_gest_project/ui/widgets/search_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NewEntryDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onSave;

  const NewEntryDrawer({
    super.key,
    required this.onClose,
    required this.onSave,
  });

  @override
  State<NewEntryDrawer> createState() => _NewEntryDrawerState();
}

class _NewEntryDrawerState extends State<NewEntryDrawer> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _notaFiscalController = TextEditingController();
  final TextEditingController _dataEntregaController = TextEditingController();
  final TextEditingController _fornecedorCodigoController =
      TextEditingController();
  final TextEditingController _fornecedorDescricaoController =
      TextEditingController();

  final TextEditingController _produtoCodigoController =
      TextEditingController();
  final TextEditingController _produtoDescricaoController =
      TextEditingController();
  final TextEditingController _aplicacaoController = TextEditingController();
  final TextEditingController _caController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _valorUnitarioController =
      TextEditingController();

  // Lista de produtos
  final List<Map<String, dynamic>> _produtos = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _dataEntregaController.text = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.now());
  }

  @override
  void dispose() {
    _notaFiscalController.dispose();
    _dataEntregaController.dispose();
    _fornecedorCodigoController.dispose();
    _fornecedorDescricaoController.dispose();
    _produtoCodigoController.dispose();
    _produtoDescricaoController.dispose();
    _aplicacaoController.dispose();
    _caController.dispose();
    _quantidadeController.dispose();
    _valorUnitarioController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dataEntregaController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _searchSupplier() async {
    final List<Map<String, dynamic>> suppliers = [
      {
        'codigo': '001',
        'descricao': 'Fornecedor A Ltda',
        'cnpj': '12.345.678/0001-90',
      },
      {
        'codigo': '002',
        'descricao': 'Fornecedor B S/A',
        'cnpj': '98.765.432/0001-10',
      },
      {
        'codigo': '003',
        'descricao': 'Fornecedor C ME',
        'cnpj': '52.854.996/0001-14',
      },
      {
        'codigo': '004',
        'descricao': 'Fornecedor D EPP',
        'cnpj': '73.889.521/0001/00',
      },
    ];

    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SearchSelectionDialog<Map<String, dynamic>>(
        title: 'Selecionar Fornecedor',
        searchHint: 'Buscar por nome, código ou CNPJ...',
        items: suppliers,
        // Lógica de filtro personalizada
        searchFilter: (item, query) {
          return item['descricao'].toString().toLowerCase().contains(query) ||
              item['codigo'].toString().toLowerCase().contains(query) ||
              item['cnpj'].toString().toLowerCase().contains(query);
        },
        // Como desenhar cada item
        itemBuilder: (context, item, onSelect) {
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.business, size: 20)),
            title: Text(item['descricao']),
            subtitle: Text('Cód: ${item['codigo']} • CNPJ: ${item['cnpj']}'),
            onTap: onSelect,
            trailing: const Icon(Icons.chevron_right),
          );
        },
      ),
    );

    if (selected != null) {
      setState(() {
        _fornecedorCodigoController.text = selected['codigo'];
        _fornecedorDescricaoController.text = selected['descricao'];
      });
    }
  }

  Future<void> _searchProduct() async {
    final List<Map<String, dynamic>> products = [
      {'codigo': 'P001', 'descricao': 'Capacete de Segurança', 'ca': 'CA12345'},
      {'codigo': 'P002', 'descricao': 'Luvas de Proteção', 'ca': 'CA12346'},
      {'codigo': 'P003', 'descricao': 'Óculos de Proteção', 'ca': 'CA12347'},
      {'codigo': 'P004', 'descricao': 'Protetor Auricular', 'ca': 'CA12348'},
      {'codigo': 'P005', 'descricao': 'Botina de Segurança', 'ca': 'CA12349'},
    ];

    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SearchSelectionDialog<Map<String, dynamic>>(
        title: 'Selecionar EPIs',
        searchHint: 'Buscar por código, descrição ou CA...',
        items: products,
        searchFilter: (item, query) {
          return item['descricao'].toString().toLowerCase().contains(query) ||
              item['codigo'].toString().toLowerCase().contains(query) ||
              item['ca'].toString().toLowerCase().contains(query);
        },
        // Como desenhar cada item
        itemBuilder: (context, item, onSelect) {
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.inventory_2, size: 20)),
            title: Text(item['descricao']),
            subtitle: Text('CA: ${item['ca']} • Codigo: ${item['codigo']}'),
            onTap: onSelect,
            trailing: const Icon(Icons.chevron_right),
          );
        },
      ),
    );

    if (selected != null) {
      setState(() {
        _produtoCodigoController.text = selected['codigo'];
        _caController.text = selected['ca'];
        _produtoDescricaoController.text = selected['descricao'];
      });
    }
  }

  void _addProduct() {
    if (_produtoCodigoController.text.isEmpty ||
        _quantidadeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Preencha o produto e a quantidade'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _produtos.add({
        'codigo': _produtoCodigoController.text,
        'descricao': _produtoDescricaoController.text,
        'aplicacao': _aplicacaoController.text,
        'ca': _caController.text,
        'quantidade': int.tryParse(_quantidadeController.text) ?? 0,
        'valorUnitario':
            double.tryParse(
              _valorUnitarioController.text.replaceAll(',', '.'),
            ) ??
            0.0,
      });

      // Limpa campos do produto
      _produtoCodigoController.clear();
      _produtoDescricaoController.clear();
      _aplicacaoController.clear();
      _caController.clear();
      _quantidadeController.clear();
      _valorUnitarioController.clear();
    });
  }

  void _removeProduct(int index) {
    setState(() {
      _produtos.removeAt(index);
    });
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate() && _produtos.isNotEmpty) {
      setState(() => _isSaving = true);

      final entryData = {
        'notaFiscal': _notaFiscalController.text,
        'dataEntrega': _dataEntregaController.text,
        'fornecedorCodigo': _fornecedorCodigoController.text,
        'fornecedorDescricao': _fornecedorDescricaoController.text,
        'produtos': List.from(_produtos),
      };

      // Simula delay para UX
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          widget.onSave(entryData);
          setState(() => _isSaving = false);
        }
      });
    } else if (_produtos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Adicione pelo menos um produto à entrada'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseDrawer(
      onClose: widget.onClose,
      widthFactor: 0.6,
      header: _buildHeader(theme),
      body: _buildBody(theme),
      footer: _buildFooter(theme),
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
              Icons.input_rounded,
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
                  'Nova Entrada de Materiais',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Registre a entrada de notas fiscais e produtos no estoque',
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
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Se tela larga, usa 2 colunas. Se estreita, 1 coluna.
              if (constraints.maxWidth > 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildInvoiceInfoSection(theme),
                          const SizedBox(height: 24),
                          _buildSupplierSection(theme),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(flex: 3, child: _buildProductSection(theme)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildInvoiceInfoSection(theme),
                    const SizedBox(height: 24),
                    _buildSupplierSection(theme),
                    const SizedBox(height: 24),
                    _buildProductSection(theme),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceInfoSection(ThemeData theme) {
    return InfoSection(
      title: 'Dados da Nota Fiscal',
      icon: Icons.receipt_long_outlined,
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              controller: _notaFiscalController,
              label: 'Número da NF*',
              hint: '000.000',
              icon: Icons.confirmation_number_outlined,
              validator: (v) => v?.isEmpty ?? true ? 'Obrigatório' : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomDateField(
              controller: _dataEntregaController,
              label: 'Data Entrada',
              hint: 'dd/mm/aaaa',
              icon: Icons.calendar_today_outlined,
              onTap: _selectDate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierSection(ThemeData theme) {
    return InfoSection(
      title: 'Fornecedor',
      icon: Icons.business_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: CustomTextField(
                  controller: _fornecedorDescricaoController,
                  label: 'Razão Social / Nome',
                  hint: 'Selecione o fornecedor',
                  icon: Icons.store_outlined,
                  enabled: false,
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.tonalIcon(
                onPressed: _searchSupplier,
                icon: const Icon(Icons.search),
                label: const Text('Buscar'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _fornecedorCodigoController,
            label: 'Código / CNPJ',
            hint: '',
            icon: Icons.numbers_outlined,
            enabled: false,
          ),
        ],
      ),
    );
  }

  Widget _buildProductSection(ThemeData theme) {
    return InfoSection(
      title: 'Itens da Entrada',
      icon: Icons.inventory_2_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Área de Adição de Produto
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _produtoDescricaoController,
                        label: 'Produto',
                        hint: 'Selecione o produto...',
                        icon: Icons.search,
                        enabled:
                            true, // Permite clicar no campo se quiser implementar onTap no CustomTextField
                        // ou use um GestureDetector envolvendo
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      onPressed: _searchProduct,
                      icon: const Icon(Icons.search),
                      tooltip: 'Buscar Produto',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _caController,
                        label: 'CA',
                        hint: '',
                        icon: Icons.verified_outlined,
                        enabled: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _quantidadeController,
                        label: 'Qtd.',
                        hint: '0',
                        icon: Icons.numbers,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _valorUnitarioController,
                        label: 'Valor Unit.',
                        hint: 'R\$ 0,00',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          CurrencyInputFormatter()
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _addProduct,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Adicionar Item'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Lista de Produtos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Itens Adicionados (${_produtos.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_produtos.isNotEmpty)
                TextButton.icon(
                  onPressed: () => setState(() => _produtos.clear()),
                  icon: const Icon(Icons.delete_sweep, size: 18),
                  label: const Text('Limpar Lista'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          if (_produtos.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.post_add,
                    size: 48,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nenhum produto adicionado ainda',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _produtos.length,
              itemBuilder: (context, index) {
                final prod = _produtos[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainer,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      prod['descricao'],
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'CA: ${prod['ca']} • Código: ${prod['codigo']}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${prod['quantidade']} un',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            if ((prod['valorUnitario'] ?? 0) > 0)
                              Text(
                                'R\$ ${(prod['valorUnitario'] * prod['quantidade']).toStringAsFixed(2)}',
                                style: theme.textTheme.bodySmall,
                              ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: theme.colorScheme.error,
                          onPressed: () => _removeProduct(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    final double totalValor = _produtos.fold(
      0,
      (sum, item) =>
          sum +
          ((item['quantidade'] as int) * (item['valorUnitario'] as double)),
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_produtos.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Valor Total Estimado', style: theme.textTheme.labelSmall),
                Text(
                  'R\$ ${totalValor.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          const Spacer(),
          OutlinedButton(
            onPressed: widget.onClose,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 16),
          FilledButton.icon(
            onPressed: _produtos.isEmpty || _isSaving ? null : _saveEntry,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check),
            label: Text(_isSaving ? 'Salvando...' : 'Confirmar Entrada'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
