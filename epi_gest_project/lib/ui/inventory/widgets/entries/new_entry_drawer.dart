import 'package:flutter/material.dart';
import 'package:epi_gest_project/ui/inventory/widgets/entries/supplier_product_search_dialog.dart';
import 'package:epi_gest_project/ui/widgets/base_drawer.dart';

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
  
  // Dados da entrada
  final TextEditingController _notaFiscalController = TextEditingController();
  final TextEditingController _dataEntregaController = TextEditingController();
  final TextEditingController _fornecedorCodigoController = TextEditingController();
  final TextEditingController _fornecedorDescricaoController = TextEditingController();
  final TextEditingController _produtoCodigoController = TextEditingController();
  final TextEditingController _produtoDescricaoController = TextEditingController();
  final TextEditingController _aplicacaoController = TextEditingController();
  final TextEditingController _caController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();

  // Lista de produtos (pode adicionar múltiplos)
  final List<Map<String, dynamic>> _produtos = [];

  @override
  void initState() {
    super.initState();
    // Define a data atual como padrão
    _dataEntregaController.text = _formatDate(DateTime.now());
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
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dataEntregaController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _searchSupplier() async {
    final result = await showDialog(
      context: context,
      builder: (context) => SupplierProductSearchDialog(
        type: SearchType.supplier,
        onSelect: (item) {
          setState(() {
            _fornecedorCodigoController.text = item['codigo'] ?? '';
            _fornecedorDescricaoController.text = item['descricao'] ?? '';
          });
        },
      ),
    );
  }

  Future<void> _searchProduct() async {
    final result = await showDialog(
      context: context,
      builder: (context) => SupplierProductSearchDialog(
        type: SearchType.product,
        onSelect: (item) {
          setState(() {
            _produtoCodigoController.text = item['codigo'] ?? '';
            _produtoDescricaoController.text = item['descricao'] ?? '';
            _aplicacaoController.text = item['aplicacao'] ?? '';
            _caController.text = item['ca'] ?? '';
          });
        },
      ),
    );
  }

  void _addProduct() {
    if (_produtoCodigoController.text.isEmpty || 
        _quantidadeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha o código do produto e a quantidade'),
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
      });

      // Limpa campos do produto
      _produtoCodigoController.clear();
      _produtoDescricaoController.clear();
      _aplicacaoController.clear();
      _caController.clear();
      _quantidadeController.clear();
    });
  }

  void _removeProduct(int index) {
    setState(() {
      _produtos.removeAt(index);
    });
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate() && _produtos.isNotEmpty) {
      final entryData = {
        'notaFiscal': _notaFiscalController.text,
        'dataEntrega': _dataEntregaController.text,
        'fornecedorCodigo': _fornecedorCodigoController.text,
        'fornecedorDescricao': _fornecedorDescricaoController.text,
        'produtos': List.from(_produtos),
      };

      widget.onSave(entryData);
    } else if (_produtos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um produto'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseDrawer(
      onClose: widget.onClose,
      widthFactor: 0.5, // Reduzido para metade da tela
      header: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.assignment_add,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Nova Entrada de Materiais',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dados da Entrada
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dados da Entrada',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // Nota Fiscal
                          Expanded(
                            child: TextFormField(
                              controller: _notaFiscalController,
                              decoration: const InputDecoration(
                                labelText: 'Número da Nota Fiscal',
                                prefixIcon: Icon(Icons.receipt),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Informe o número da nota fiscal';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Data de Entrega
                          Expanded(
                            child: TextFormField(
                              controller: _dataEntregaController,
                              decoration: InputDecoration(
                                labelText: 'Data da Entrega',
                                prefixIcon: const Icon(Icons.calendar_today),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_month),
                                  onPressed: () => _selectDate(context),
                                ),
                              ),
                              readOnly: true,
                              onTap: () => _selectDate(context),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Informe a data de entrega';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Fornecedor
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _fornecedorCodigoController,
                              decoration: InputDecoration(
                                labelText: 'Código do Fornecedor',
                                prefixIcon: const Icon(Icons.code),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.search),
                                  onPressed: _searchSupplier,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Informe o código do fornecedor';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _fornecedorDescricaoController,
                              decoration: const InputDecoration(
                                labelText: 'Descrição do Fornecedor',
                              ),
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Produtos
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Produtos',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: _addProduct,
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar Produto'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Formulário para adicionar produto
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: TextFormField(
                                    controller: _produtoCodigoController,
                                    decoration: InputDecoration(
                                      labelText: 'Código do Produto',
                                      prefixIcon: const Icon(Icons.code),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.search),
                                        onPressed: _searchProduct,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: _produtoDescricaoController,
                                    decoration: const InputDecoration(
                                      labelText: 'Descrição do Produto',
                                    ),
                                    readOnly: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _aplicacaoController,
                                    decoration: const InputDecoration(
                                      labelText: 'Aplicação do Produto',
                                    ),
                                    readOnly: true,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _quantidadeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Quantidade Entregue',
                                      prefixIcon: Icon(Icons.inventory_2),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _caController,
                              decoration: const InputDecoration(
                                labelText: 'C.A do Produto',
                              ),
                              readOnly: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Lista de produtos adicionados
                      if (_produtos.isNotEmpty) ...[
                        Text(
                          'Produtos Adicionados (${_produtos.length})',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ..._produtos.asMap().entries.map((entry) {
                          final index = entry.key;
                          final produto = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${produto['codigo']} - ${produto['descricao']}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text('Aplicação: ${produto['aplicacao']}'),
                                      Text('CA: ${produto['ca']}'),
                                      Text('Quantidade: ${produto['quantidade']}'),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: theme.colorScheme.error,
                                  ),
                                  onPressed: () => _removeProduct(index),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      footer: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: widget.onClose,
              child: const Text('Cancelar'),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: _saveEntry,
              child: const Text('Salvar Entrada'),
            ),
          ],
        ),
      ),
    );
  }
}