import 'package:flutter/material.dart';

class ShiftsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Turnos de Trabalho',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Text(
          'Configure os turnos e jornadas de trabalho:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        const Text('• Manhã - 06:00 às 14:00'),
        const Text('• Tarde - 14:00 às 22:00'),
        const Text('• Noite - 22:00 às 06:00'),
        const Text('• Administrativo - 08:00 às 17:00'),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implementar cadastro de turnos
          },
          icon: const Icon(Icons.add),
          label: const Text('Novo Turno'),
        ),
      ],
    );
  }
}