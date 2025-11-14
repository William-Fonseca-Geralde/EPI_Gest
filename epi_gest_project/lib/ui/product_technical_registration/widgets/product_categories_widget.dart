import 'package:flutter/material.dart';

class ProductCategoriesWidget extends StatefulWidget {
  const ProductCategoriesWidget({super.key});

  @override
  State<ProductCategoriesWidget> createState() => ProductCategoriesWidgetState();
}

class ProductCategoriesWidgetState extends State<ProductCategoriesWidget> {
  void showAddDrawer() {
    // Implementar drawer de adição
    print('Abrir drawer para Nova Categoria');
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Categorias de Produtos Widget - Em desenvolvimento'),
    );
  }
}