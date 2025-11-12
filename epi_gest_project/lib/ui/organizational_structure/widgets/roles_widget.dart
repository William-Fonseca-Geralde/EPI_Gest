import 'package:flutter/material.dart';

class RolesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cargos / Funções',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Text(
          'Defina os cargos e funções dos colaboradores:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        const Text('• Operador de Máquinas'),
        const Text('• Auxiliar de Produção'),
        const Text('• Supervisor'),
        const Text('• Gerente'),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implementar cadastro de cargos
          },
          icon: const Icon(Icons.add),
          label: const Text('Novo Cargo'),
        ),
      ],
    );
  }
}