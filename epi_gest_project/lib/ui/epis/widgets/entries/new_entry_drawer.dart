import 'package:epi_gest_project/data/services/entradas_repository.dart';
import 'package:epi_gest_project/data/services/epi_repository.dart';
import 'package:epi_gest_project/data/services/product_technical_registration/fornecedor_repository.dart';
import 'package:epi_gest_project/domain/models/entradas_epi_model.dart';
import 'package:epi_gest_project/domain/models/entradas_model.dart';
import 'package:epi_gest_project/domain/models/epi_model.dart';
import 'package:epi_gest_project/domain/models/product_technical_registration/fornecedor_model.dart';
import 'package:epi_gest_project/ui/utils/input_formatters.dart';
import 'package:epi_gest_project/ui/widgets/base_drawer.dart';
import 'package:epi_gest_project/ui/widgets/form_fields.dart';
import 'package:epi_gest_project/ui/widgets/info_section.dart';
import 'package:epi_gest_project/ui/widgets/search_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
  final TextEditingController _fornecedorCnpjController =
      TextEditingController();
  final TextEditingController _fornecedorNomeController =
      TextEditingController();

  final TextEditingController _produtoDescricaoController =
      TextEditingController();
  final TextEditingController _caController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _valorUnitarioController =
      TextEditingController();

  FornecedorModel? _selectedFornecedor;
  EpiModel? _tempSelectedEpi;
  final List<Map<String, dynamic>> _produtosVisuais = [];
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
    _fornecedorCnpjController.dispose();
    _fornecedorNomeController.dispose();
    _produtoDescricaoController.dispose();
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
    final repo = Provider.of<FornecedorRepository>(context, listen: false);
    final suppliers = await repo.getAllFornecedores();

    final selected = await showDialog<FornecedorModel>(
      context: context,
      builder: (context) => SearchSelectionDialog<FornecedorModel>(
        title: 'Selecionar Fornecedor',
        searchHint: 'Buscar por nome ou CNPJ...',
        items: suppliers,
        searchFilter: (item, query) =>
            item.nomeFornecedor.toLowerCase().contains(query) ||
            item.cnpj.contains(query),
        itemBuilder: (context, item, onSelect) {
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.business)),
            title: Text(item.nomeFornecedor),
            subtitle: Text('CNPJ: ${item.cnpj}'),
            onTap: onSelect,
          );
        },
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedFornecedor = selected;
        _fornecedorNomeController.text = selected.nomeFornecedor;
        _fornecedorCnpjController.text = selected.cnpj;
      });
    }
  }

  Future<void> _searchProduct() async {
    final repo = Provider.of<EpiRepository>(context, listen: false);
    final products = await repo.getAllEpis();

    final selected = await showDialog<EpiModel>(
      context: context,
      builder: (context) => SearchSelectionDialog<EpiModel>(
        title: 'Selecionar Produto',
        searchHint: 'Buscar por nome ou CA...',
        items: products,
        searchFilter: (item, query) =>
            item.nomeProduto.toLowerCase().contains(query) ||
            item.ca.contains(query),
        itemBuilder: (context, item, onSelect) {
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.inventory_2)),
            title: Text(item.nomeProduto),
            subtitle: Text('CA: ${item.ca} | Estoque Atual: ${item.estoque}'),
            onTap: onSelect,
          );
        },
      ),
    );

    if (selected != null) {
      setState(() {
        _tempSelectedEpi = selected;
        _produtoDescricaoController.text = selected.nomeProduto;
        _caController.text = selected.ca;
        // Sugere o valor atual, mas permite editar
        _valorUnitarioController.text = NumberFormat.currency(
          locale: 'pt_BR',
          symbol: 'R\$',
        ).format(selected.valor);
        _quantidadeController.clear();
      });
    }
  }

  void _addProduct() {
    if (_tempSelectedEpi == null || _quantidadeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um produto e informe a quantidade'),
        ),
      );
      return;
    }

    final qtd = int.tryParse(_quantidadeController.text) ?? 0;
    // Remove R$ e formata para double
    String valorLimpo = _valorUnitarioController.text
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    final valor = double.tryParse(valorLimpo) ?? 0.0;

    if (qtd <= 0) return;

    setState(() {
      _produtosVisuais.add({
        'epiModel': _tempSelectedEpi, // Guarda o objeto real
        'descricao': _tempSelectedEpi!.nomeProduto,
        'ca': _tempSelectedEpi!.ca,
        'quantidade': qtd,
        'valorUnitario': valor,
        'valorTotal': qtd * valor,
      });

      // Limpar campos de item
      _tempSelectedEpi = null;
      _produtoDescricaoController.clear();
      _caController.clear();
      _quantidadeController.clear();
      _valorUnitarioController.clear();
    });
  }

  void _removeProduct(int index) {
    setState(() {
      _produtosVisuais.removeAt(index);
    });
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate() ||
        _produtosVisuais.isEmpty ||
        _selectedFornecedor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os dados obrigatórios')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 1. Converte lista visual para Models
      final List<EntradasEpiModel> itensParaSalvar = _produtosVisuais.map((p) {
        return EntradasEpiModel(
          epi: p['epiModel'] as EpiModel,
          quantidade: p['quantidade'] as int,
          valor: p['valorUnitario'] as double,
        );
      }).toList();

      // 2. Cria cabeçalho
      final header = EntradasModel(
        nfReferente: _notaFiscalController.text,
        fornecedorId: _selectedFornecedor!,
        entradasId: [], // Será preenchido pelo repositório com os IDs gerados
      );

      // 3. Chama repositório
      final repo = Provider.of<EntradasRepository>(context, listen: false);
      await repo.registrarEntradaCompleta(
        entradaHeader: header,
        itens: itensParaSalvar,
      );

      widget.onSave({});
      widget.onClose();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
                  controller: _fornecedorNomeController,
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
            controller: _fornecedorCnpjController,
            label: 'CNPJ',
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
                        inputFormatters: [CurrencyInputFormatter()],
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
                'Itens Adicionados (${_produtosVisuais.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_produtosVisuais.isNotEmpty)
                TextButton.icon(
                  onPressed: () => setState(() => _produtosVisuais.clear()),
                  icon: const Icon(Icons.delete_sweep, size: 18),
                  label: const Text('Limpar Lista'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          if (_produtosVisuais.isEmpty)
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
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _produtosVisuais.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = _produtosVisuais[index];
                final currency = NumberFormat.currency(
                  locale: 'pt_BR',
                  symbol: 'R\$',
                );

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(
                    item['descricao'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('CA: ${item['ca']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${item['quantidade']} un x ${currency.format(item['valorUnitario'])}',
                          ),
                          Text(
                            currency.format(item['valorTotal']),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeProduct(index),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    final double totalValor = _produtosVisuais.fold(
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
          if (_produtosVisuais.isNotEmpty)
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
            onPressed: _produtosVisuais.isEmpty || _isSaving
                ? null
                : _saveEntry,
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
