import 'package:flutter/material.dart';

class EmploymentTypesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipos de Vínculo',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Text(
          'Configure os tipos de vínculo empregatício:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        const Text('• CLT'),
        const Text('• PJ'),
        const Text('• Estagiário'),
        const Text('• Temporário'),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implementar cadastro de tipos de vínculo
          },
          icon: const Icon(Icons.add),
          label: const Text('Novo Tipo de Vínculo'),
        ),
      ],
    );
  }
}