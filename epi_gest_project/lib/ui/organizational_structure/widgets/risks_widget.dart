import 'package:flutter/material.dart';

class RisksWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riscos Ocupacionais',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Text(
          'Classifique os riscos ocupacionais por atividade:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        const Text('• Físicos - Ruído, calor, vibração'),
        const Text('• Químicos - Poeira, fumos, vapores'),
        const Text('• Biológicos - Bactérias, vírus, fungos'),
        const Text('• Ergonômicos - Postura, repetição'),
        const Text('• Acidentes - Quedas, choques, incêndios'),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implementar cadastro de riscos
          },
          icon: const Icon(Icons.add),
          label: const Text('Novo Risco'),
        ),
      ],
    );
  }
}