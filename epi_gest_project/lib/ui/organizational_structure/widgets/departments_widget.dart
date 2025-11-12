import 'package:flutter/material.dart';

class DepartmentsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Setores / Departamentos',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Text(
          'Configure os departamentos da empresa:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        const Text('• Produção'),
        const Text('• Administrativo'),
        const Text('• RH'),
        const Text('• Segurança do Trabalho'),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implementar cadastro de departamentos
          },
          icon: const Icon(Icons.add),
          label: const Text('Novo Departamento'),
        ),
      ],
    );
  }
}