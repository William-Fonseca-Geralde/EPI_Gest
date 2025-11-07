import 'package:flutter/material.dart';

class RecentActivitiesWidget extends StatelessWidget {
  const RecentActivitiesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () {
                // Ver todas as atividades
              },
              icon: const Icon(Icons.history_rounded, size: 18),
              label: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            itemCount: 5,
            separatorBuilder: (context, index) => Divider(
              height: 12,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            itemBuilder: (context, index) {
              return _buildActivityItem(context, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(BuildContext context, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Dados mockados para exemplo
    final activities = [
      {
        'type': 'exchange',
        'title': 'Troca de EPI realizada',
        'description': 'João Silva recebeu Capacete de Segurança',
        'time': 'Há 15 minutos',
        'icon': Icons.swap_horiz_rounded,
        'color': Colors.blue,
      },
      {
        'type': 'alert',
        'title': 'Alerta de vencimento',
        'description': '5 EPIs vencerão nos próximos 7 dias',
        'time': 'Há 1 hora',
        'icon': Icons.warning_amber_rounded,
        'color': Colors.orange,
      },
      {
        'type': 'new_employee',
        'title': 'Novo funcionário cadastrado',
        'description': 'Maria Santos - Setor de Produção',
        'time': 'Há 2 horas',
        'icon': Icons.person_add_rounded,
        'color': Colors.green,
      },
      {
        'type': 'stock',
        'title': 'Estoque atualizado',
        'description': '50 unidades de Luvas de Proteção adicionadas',
        'time': 'Há 3 horas',
        'icon': Icons.inventory_2_rounded,
        'color': Colors.purple,
      },
      {
        'type': 'expired',
        'title': 'EPIs vencidos removidos',
        'description': '8 itens foram marcados como vencidos',
        'time': 'Há 5 horas',
        'icon': Icons.delete_outline_rounded,
        'color': Colors.red,
      },
    ];

    final activity = activities[index];

    return InkWell(
      onTap: () {
        // Navegar para detalhes da atividade
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // Ícone
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (activity['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                activity['icon'] as IconData,
                color: activity['color'] as Color,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Conteúdo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['title'] as String,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity['description'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Tempo
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  activity['time'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
