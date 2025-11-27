import 'package:flutter/material.dart';

class ProductSearchDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSelect;

  const ProductSearchDialog({
    super.key,
    required this.onSelect,
  });

  @override
  State<ProductSearchDialog> createState() => _ProductSearchDialogState();
}

class _ProductSearchDialogState extends State<ProductSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredProducts = [];
  
  // Dados mockados - substituir por dados reais
  final List<Map<String, dynamic>> _products = [
    {'codigo': 'P001', 'descricao': 'Capacete de Segurança', 'ca': 'CA12345', 'quantidadeSistema': 50},
    {'codigo': 'P002', 'descricao': 'Luvas de Proteção', 'ca': 'CA12346', 'quantidadeSistema': 100},
    {'codigo': 'P003', 'descricao': 'Óculos de Proteção', 'ca': 'CA12347', 'quantidadeSistema': 75},
    {'codigo': 'P004', 'descricao': 'Protetor Auricular', 'ca': 'CA12348', 'quantidadeSistema': 30},
    {'codigo': 'P005', 'descricao': 'Botina de Segurança', 'ca': 'CA12349', 'quantidadeSistema': 60},
  ];

  @override
  void initState() {
    super.initState();
    _filteredProducts = _products;
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    final searchText = _searchController.text.toLowerCase();

    setState(() {
      if (searchText.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products.where((product) {
          return product['codigo'].toLowerCase().contains(searchText) ||
                 product['descricao'].toLowerCase().contains(searchText) ||
                 product['ca'].toLowerCase().contains(searchText);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Buscar Produto'),
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
              child: _filteredProducts.isEmpty
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
                            'Nenhum produto encontrado',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.inventory_2,
                              color: theme.colorScheme.onPrimaryContainer,
                              size: 20,
                            ),
                          ),
                          title: Text(product['descricao']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Código: ${product['codigo']}'),
                              Text('CA: ${product['ca']}'),
                              Text('Saldo: ${product['quantidadeSistema']}'),
                            ],
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          onTap: () {
                            widget.onSelect(product);
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