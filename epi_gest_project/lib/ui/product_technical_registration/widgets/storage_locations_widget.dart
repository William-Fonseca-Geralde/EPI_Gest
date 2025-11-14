import 'package:flutter/material.dart';

class StorageLocationsWidget extends StatefulWidget {
  const StorageLocationsWidget({super.key});

  @override
  State<StorageLocationsWidget> createState() => StorageLocationsWidgetState();
}

class StorageLocationsWidgetState extends State<StorageLocationsWidget> {
  void showAddDrawer() {
    // Implementar drawer de adição
    print('Abrir drawer para Novo Local');
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Locais de Armazenamento Widget - Em desenvolvimento'),
    );
  }
}