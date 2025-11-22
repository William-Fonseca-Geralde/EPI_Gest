import 'package:epi_gest_project/ui/inventory/widgets/inventory/product_search_dialog.dart';
import 'package:epi_gest_project/ui/widgets/base_drawer.dart'; // Certifique-se de importar o BaseDrawer
import 'package:epi_gest_project/ui/widgets/search_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewInventoryDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onSave;

  const NewInventoryDrawer({
    super.key,
    required this.onClose,
    required this.onSave,
  });

  @override
  State<NewInventoryDrawer> createState() => _NewInventoryDrawerState();
}

class _NewInventoryDrawerState extends State<NewInventoryDrawer> {
  final _formKey = GlobalKey<FormState>();
  
  // Dados do inventário
  final TextEditingController _dataInventarioController = TextEditingController();
  final TextEditingController _produtoCodigoController = TextEditingController();
  final TextEditingController _produtoDescricaoController = TextEditingController();
  final TextEditingController _caController = TextEditingController();
  final TextEditingController _quantidadeSistemaController = TextEditingController();
  final TextEditingController _novaQuantidadeController = TextEditingController();

  // Lista de produtos do inventário
  final List<Map<String, dynamic>> _produtos = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _dataInventarioController.text = _formatDate(DateTime.now());
  }

  @override
  void dispose() {
    _dataInventarioController.dispose();
    _produtoCodigoController.dispose();
    _produtoDescricaoController.dispose();
    _caController.dispose();
    _quantidadeSistemaController.dispose();
    _novaQuantidadeController.dispose();
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
        _dataInventarioController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _searchProduct() async {
    final List<Map<String, dynamic>> products = [
      {'codigo': 'P001', 'descricao': 'Capacete de Segurança', 'ca': 'CA12345', 'quantidadeSistema': 50},
      {'codigo': 'P002', 'descricao': 'Luvas de Proteção', 'ca': 'CA12346', 'quantidadeSistema': 100},
      {'codigo': 'P003', 'descricao': 'Óculos de Proteção', 'ca': 'CA12347', 'quantidadeSistema': 75},
      {'codigo': 'P004', 'descricao': 'Protetor Auricular', 'ca': 'CA12348', 'quantidadeSistema': 30},
      {'codigo': 'P005', 'descricao': 'Botina de Segurança', 'ca': 'CA12349', 'quantidadeSistema': 60},
    ];

    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SearchSelectionDialog<Map<String, dynamic>>(
        title: 'Buscar Produto',
        searchHint: 'Buscar por código, descrição ou CA...',
        items: products,
        searchFilter: (item, query) {
          return item['descricao'].toString().toLowerCase().contains(query) ||
              item['codigo'].toString().toLowerCase().contains(query) ||
              item['ca'].toString().toLowerCase().contains(query);
        },
        itemBuilder: (context, item, onSelect) {
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.inventory_2, size: 20)),
            title: Text(item['descricao']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CA: ${item['ca']} • Codigo: ${item['codigo']}'),
                Text('Saldo: ${item['quantidadeSistema']}')
              ],
            ),
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
        _quantidadeSistemaController.text = selected['quantidadeSistema'].toString();
        _novaQuantidadeController.text = selected['quantidadeSistema'].toString();
      });
    }
  }

  void _addProduct() {
    if (_produtoCodigoController.text.isEmpty || 
        _novaQuantidadeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha o código do produto e a nova quantidade'),
        ),
      );
      return;
    }

    final quantidadeSistema = int.tryParse(_quantidadeSistemaController.text) ?? 0;
    final novaQuantidade = int.tryParse(_novaQuantidadeController.text) ?? 0;
    final diferenca = novaQuantidade - quantidadeSistema;

    setState(() {
      _produtos.add({
        'codigo': _produtoCodigoController.text,
        'descricao': _produtoDescricaoController.text,
        'ca': _caController.text,
        'quantidadeSistema': quantidadeSistema,
        'novaQuantidade': novaQuantidade,
        'diferenca': diferenca,
      });

      // Limpa campos do produto
      _produtoCodigoController.clear();
      _produtoDescricaoController.clear();
      _caController.clear();
      _quantidadeSistemaController.clear();
      _novaQuantidadeController.clear();
    });
  }

  void _removeProduct(int index) {
    setState(() {
      _produtos.removeAt(index);
    });
  }

  void _saveInventory() {
    if (_formKey.currentState!.validate() && _produtos.isNotEmpty) {
      setState(() => _isSaving = true);

      final inventoryData = {
        'dataInventario': _dataInventarioController.text,
        'produtos': List.from(_produtos),
      };

      // Simula delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          widget.onSave(inventoryData);
          setState(() => _isSaving = false);
        }
      });
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
      widthFactor: 0.6, // Largura similar ao drawer de entradas
      header: _buildHeader(theme),
      body: _buildBody(theme),
      footer: _buildFooter(theme),
    );
  }

  // --- Widgets de Construção do Drawer ---

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
              Icons.inventory_outlined,
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
                  'Novo Inventário',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Realize a contagem e ajuste de estoque',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção Data do Inventário
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dados do Inventário',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dataInventarioController,
                      decoration: InputDecoration(
                        labelText: 'Data do Inventário',
                        prefixIcon: const Icon(Icons.calendar_today),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_month),
                          onPressed: () => _selectDate(context),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) =>
                          (value == null || value.isEmpty) ? 'Informe a data' : null,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),

              // Seção Adicionar Produto
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.add_box_outlined, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Adicionar Produto',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _produtoCodigoController,
                            decoration: InputDecoration(
                              labelText: 'Código/Produto',
                              hintText: 'Busque o produto...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: _searchProduct,
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            readOnly: true,
                            onTap: _searchProduct,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _produtoDescricaoController,
                            decoration: InputDecoration(
                              labelText: 'Descrição',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
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
                            controller: _caController,
                            decoration: InputDecoration(
                              labelText: 'C.A',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                            ),
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _quantidadeSistemaController,
                            decoration: InputDecoration(
                              labelText: 'Qtd. Sistema',
                              prefixIcon: const Icon(Icons.inventory_2),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                            ),
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _novaQuantidadeController,
                            decoration: InputDecoration(
                              labelText: 'Nova Qtd.',
                              prefixIcon: const Icon(Icons.edit_note),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: _addProduct,
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar à Lista'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Lista de Produtos Adicionados
              if (_produtos.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Itens do Inventário (${_produtos.length})',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: () => setState(() => _produtos.clear()),
                      icon: const Icon(Icons.delete_sweep, size: 18),
                      label: const Text('Limpar Lista'),
                      style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _produtos.length,
                  itemBuilder: (context, index) {
                    final produto = _produtos[index];
                    final diferenca = produto['diferenca'];
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: diferenca == 0 
                              ? theme.colorScheme.outlineVariant
                              : diferenca > 0
                                  ? theme.colorScheme.primary.withOpacity(0.5)
                                  : theme.colorScheme.error.withOpacity(0.5),
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          '${produto['codigo']} - ${produto['descricao']}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Row(
                          children: [
                            Text('CA: ${produto['ca']}'),
                            const SizedBox(width: 16),
                            Text('Sistema: ${produto['quantidadeSistema']}'),
                            const SizedBox(width: 16),
                            Text(
                              'Contagem: ${produto['novaQuantidade']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: diferenca == 0
                                    ? theme.colorScheme.surfaceContainerHighest
                                    : diferenca > 0
                                        ? theme.colorScheme.primaryContainer
                                        : theme.colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Dif: ${diferenca >= 0 ? '+' : ''}$diferenca',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: diferenca == 0
                                      ? theme.colorScheme.onSurfaceVariant
                                      : diferenca > 0
                                          ? theme.colorScheme.onPrimaryContainer
                                          : theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                              onPressed: () => _removeProduct(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ] else 
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(Icons.playlist_add, size: 48, color: theme.colorScheme.outline),
                        const SizedBox(height: 8),
                        Text(
                          'Nenhum item adicionado ao inventário',
                          style: TextStyle(color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_produtos.isNotEmpty)
            Text(
              '${_produtos.length} itens listados',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
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
            onPressed: _produtos.isEmpty || _isSaving ? null : _saveInventory,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save_as),
            label: Text(_isSaving ? 'Salvando...' : 'Finalizar Inventário'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}