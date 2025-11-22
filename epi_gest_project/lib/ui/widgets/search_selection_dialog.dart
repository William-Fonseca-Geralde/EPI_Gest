import 'package:flutter/material.dart';

class SearchSelectionDialog<T> extends StatefulWidget {
  final String title;
  final String searchHint;
  final List<T> items;

  /// Função que define como filtrar a lista baseada no texto digitado
  final bool Function(T item, String query) searchFilter;

  /// Função que constrói o item da lista (ListTile, Card, etc.)
  final Widget Function(BuildContext context, T item, VoidCallback onSelect)
  itemBuilder;

  const SearchSelectionDialog({
    super.key,
    required this.title,
    this.searchHint = 'Pesquisar...',
    required this.items,
    required this.searchFilter,
    required this.itemBuilder,
  });

  @override
  State<SearchSelectionDialog<T>> createState() =>
      _SearchSelectionDialogState<T>();
}

class _SearchSelectionDialogState<T> extends State<SearchSelectionDialog<T>> {
  final TextEditingController _searchController = TextEditingController();
  late List<T> _filteredItems;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          return widget.searchFilter(item, query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600, // Largura fixa ideal para drawers/web, pode ser ajustada
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          children: [
            // Cabeçalho
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Campo de Busca
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: widget.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withOpacity(0.3),
                ),
                autofocus: true,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),

            // Lista de Resultados
            Expanded(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: theme.colorScheme.outline.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum item encontrado',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: _filteredItems.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return widget.itemBuilder(context, item, () {
                          // Retorna o item selecionado
                          Navigator.of(context).pop(item);
                        });
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
