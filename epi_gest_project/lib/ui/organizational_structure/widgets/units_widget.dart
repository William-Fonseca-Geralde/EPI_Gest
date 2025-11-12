import 'package:flutter/material.dart';

class UnitsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unidades (Matriz / Filial)',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Text(
          'Gerencie as unidades da empresa:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        const Text('• Matriz - Unidade principal'),
        const Text('• Filiais - Unidades secundárias'),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implementar cadastro de unidades
          },
          icon: const Icon(Icons.add),
          label: const Text('Nova Unidade'),
        ),
      ],
    );
  }
}