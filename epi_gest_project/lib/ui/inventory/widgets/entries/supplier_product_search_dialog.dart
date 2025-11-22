import 'package:flutter/material.dart';

enum SearchType { supplier, product }

class SupplierProductSearchDialog extends StatefulWidget {
  final SearchType type;
  final Function(Map<String, dynamic>) onSelect;

  const SupplierProductSearchDialog({
    super.key,
    required this.type,
    required this.onSelect,
  });

  @override
  State<SupplierProductSearchDialog> createState() => _SupplierProductSearchDialogState();
}

class _SupplierProductSearchDialogState extends State<SupplierProductSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredItems = [];
  
  // Dados mockados - substituir por dados reais
  final List<Map<String, dynamic>> _suppliers = [
    {'codigo': '001', 'descricao': 'Fornecedor A Ltda'},
    {'codigo': '002', 'descricao': 'Fornecedor B S/A'},
    {'codigo': '003', 'descricao': 'Fornecedor C ME'},
    {'codigo': '004', 'descricao': 'Fornecedor D EPP'},
  ];

  final List<Map<String, dynamic>> _products = [
    {'codigo': 'P001', 'descricao': 'Capacete de Segurança', 'ca': 'CA12345'},
    {'codigo': 'P002', 'descricao': 'Luvas de Proteção', 'ca': 'CA12346'},
    {'codigo': 'P003', 'descricao': 'Óculos de Proteção', 'ca': 'CA12347'},
    {'codigo': 'P004', 'descricao': 'Protetor Auricular', 'ca': 'CA12348'},
    {'codigo': 'P005', 'descricao': 'Botina de Segurança', 'ca': 'CA12349'},
  ];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.type == SearchType.supplier ? _suppliers : _products;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final searchText = _searchController.text.toLowerCase();
    final sourceList = widget.type == SearchType.supplier ? _suppliers : _products;

    setState(() {
      if (searchText.isEmpty) {
        _filteredItems = sourceList;
      } else {
        _filteredItems = sourceList.where((item) {
          return item['codigo'].toLowerCase().contains(searchText) ||
                 item['descricao'].toLowerCase().contains(searchText) ||
                 (item['ca']?.toLowerCase().contains(searchText) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = widget.type == SearchType.supplier ? 'Buscar Fornecedor' : 'Buscar Produto';

    return Dialog(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        body: Column(
          children: [
            // Campo de busca
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar por código, descrição ou CA',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
                autofocus: true,
              ),
            ),
            const Divider(height: 1),

            // Lista de resultados
            Expanded(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum item encontrado',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              widget.type == SearchType.supplier 
                                  ? Icons.business 
                                  : Icons.inventory_2,
                              color: theme.colorScheme.onPrimaryContainer,
                              size: 20,
                            ),
                          ),
                          title: Text(item['descricao']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Código: ${item['codigo']}'),
                              if (widget.type == SearchType.product)
                                Text('CA: ${item['ca']}'),
                            ],
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          onTap: () {
                            widget.onSelect(item);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}