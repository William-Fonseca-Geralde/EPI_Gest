import 'package:flutter/material.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
    Widget build(BuildContext context) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [        
          LayoutBuilder(
            builder: (context, constraints) {
              // Layout responsivo
              if (constraints.maxWidth > 800) {
                return Row(
                  children: [
                    Expanded(child: _buildActionCard(
                      context,
                      'Registrar Troca',
                      'Registre a entrega de EPIs',
                      Icons.swap_horiz_rounded,
                      colorScheme.primary,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _buildActionCard(
                      context,
                      'Novo Funcionário',
                      'Cadastre um novo colaborador',
                      Icons.person_add_rounded,
                      colorScheme.secondary,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _buildActionCard(
                      context,
                      'Adicionar EPI',
                      'Registre novos EPIs no estoque',
                      Icons.add_box_rounded,
                      colorScheme.tertiary,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _buildActionCard(
                      context,
                      'Gerar Relatório',
                      'Exporte dados e análises',
                      Icons.description_rounded,
                      Colors.purple,
                    )),
                  ],
                );
              } else {
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.5,
                  children: [
                    _buildActionCard(
                      context,
                      'Registrar Troca',
                      'Registre a entrega de EPIs',
                      Icons.swap_horiz_rounded,
                      colorScheme.primary,
                    ),
                    _buildActionCard(
                      context,
                      'Novo Funcionário',
                      'Cadastre um novo colaborador',
                      Icons.person_add_rounded,
                      colorScheme.secondary,
                    ),
                    _buildActionCard(
                      context,
                      'Adicionar EPI',
                      'Registre novos EPIs no estoque',
                      Icons.add_box_rounded,
                      colorScheme.tertiary,
                    ),
                    _buildActionCard(
                      context,
                      'Gerar Relatório',
                      'Exporte dados e análises',
                      Icons.description_rounded,
                      Colors.purple,
                    ),
                  ],
                );
              }
            },
          ),
        ],
      );
    }

    Widget _buildActionCard(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      Color color,
      ) {
      final theme = Theme.of(context);
      
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title - Em desenvolvimento'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: color,
                ),
              ],
            ),
          ),
        ),
      );
  }
}