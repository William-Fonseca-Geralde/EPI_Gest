import 'package:flutter/material.dart';
import 'widgets/status_card.dart';
import 'widgets/epi_expiration_chart.dart';
import 'widgets/cost_per_employee_chart.dart';
import 'widgets/quick_actions_widget.dart';
import 'widgets/recent_activities_widget.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surface,
      child: CustomScrollView(
        slivers: [
          // Header com título e ações rápidas
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        spacing: 16,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.dashboard,
                              color: theme.colorScheme.onPrimaryContainer,
                              size: 40,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dashboard',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Visão geral do sistema de EPIs',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Filtro de período
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: '7d', label: Text('7 dias')),
                          ButtonSegment(value: '30d', label: Text('30 dias')),
                          ButtonSegment(value: '90d', label: Text('90 dias')),
                        ],
                        selected: const {'30d'},
                        onSelectionChanged: (Set<String> newSelection) {
                          // Implementar filtro futuramente
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Conteúdo principal
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Cards de Status
                _buildStatusSection(context),

                const SizedBox(height: 32),

                // Ações Rápidas
                const QuickActionsWidget(),

                const SizedBox(height: 32),

                // Gráficos
                _buildChartsSection(context),

                const SizedBox(height: 32),

                // Atividades Recentes
                const RecentActivitiesWidget(),

                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visão Geral',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Grid de Cards - Responsivo
        LayoutBuilder(
          builder: (context, constraints) {
            // Define número de colunas baseado na largura
            final crossAxisCount = constraints.maxWidth > 1200
                ? 4
                : constraints.maxWidth > 900
                ? 3
                : constraints.maxWidth > 600
                ? 2
                : 1;

            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.6,
              children: const [
                StatusCard(
                  title: 'EPIs Vencidos',
                  value: '23',
                  icon: Icons.warning_amber_rounded,
                  color: Colors.red,
                  trend: TrendType.negative,
                  trendValue: '+5 esta semana',
                ),
                StatusCard(
                  title: 'Vencendo em 30 dias',
                  value: '47',
                  icon: Icons.schedule_rounded,
                  color: Colors.orange,
                  trend: TrendType.neutral,
                  trendValue: '12 CAs diferentes',
                ),
                StatusCard(
                  title: 'EPIs em Estoque',
                  value: '342',
                  icon: Icons.inventory_2_rounded,
                  color: Colors.blue,
                  trend: TrendType.positive,
                  trendValue: '+18 este mês',
                ),
                StatusCard(
                  title: 'Funcionários Ativos',
                  value: '156',
                  icon: Icons.people_rounded,
                  color: Colors.green,
                  trend: TrendType.positive,
                  trendValue: '98% cobertura',
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildChartsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Análises',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Layout responsivo para gráficos
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 1100) {
              // Desktop: lado a lado
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: EpiExpirationChart()),
                  const SizedBox(width: 16),
                  Expanded(child: CostPerEmployeeChart()),
                ],
              );
            } else {
              // Mobile/Tablet: empilhado
              return Column(
                children: [
                  EpiExpirationChart(),
                  const SizedBox(height: 16),
                  CostPerEmployeeChart(),
                ],
              );
            }
          },
        ),
      ],
    );
  }
}
