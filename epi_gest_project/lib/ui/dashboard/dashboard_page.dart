import 'dart:ui';
import 'package:flutter/material.dart';

// Importe seus widgets aqui
import 'widgets/status_card.dart';
import 'widgets/cost_per_epi_chart.dart';
import 'widgets/cost_per_sector_chart.dart';
import 'widgets/conformity_selector_chart.dart';
import 'widgets/top_employees_chart.dart';
import 'widgets/epi_durability_chart.dart';
import 'widgets/critical_stock_widget.dart';
import 'widgets/top_reasons_table.dart';
import 'widgets/quick_actions_widget.dart';
import 'widgets/recent_activities_widget.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              children: [
                const SizedBox(height: 8),

                /// Ações Rápidas com Espaçamento Premium
                _buildQuickActionsEnhanced(context),
                const SizedBox(height: 40),

                /// Sistema de Grid Responsivo com Proporção Áurea
                _buildResponsiveGrid(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.08),
            colorScheme.surface.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(12),
          topLeft: Radius.circular(12),
        ),
      ),
      child: Row(
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
                  Icons.analytics_rounded,
                  size: 40,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard EPI',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Gestão Inteligente de Equipamentos',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),

          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                DropdownButton<String>(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  value: '30d',
                  underline: const SizedBox(),
                  borderRadius: BorderRadius.circular(12),
                  items: const [
                    DropdownMenuItem(
                      value: '7d',
                      child: Row(
                        spacing: 12,
                        children: [
                          Icon(Icons.calendar_today_rounded),
                          Text('Últimos 7 dias'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: '30d',
                      child: Row(
                        spacing: 12,
                        children: [
                          Icon(Icons.calendar_today_rounded),
                          Text('Últimos 30 dias'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: '90d',
                      child: Row(
                        spacing: 12,
                        children: [
                          Icon(Icons.calendar_today_rounded),
                          Text('Últimos 90 dias'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // AÇÕES RÁPIDAS APRIMORADAS
  // =====================================================
  Widget _buildQuickActionsEnhanced(BuildContext context) {
    return PremiumSection(
      title: 'Ações Rápidas',
      subtitle: 'Operações frequentes do sistema',
      icon: Icons.bolt_rounded,
      child: const QuickActionsWidget(),
    );
  }

  // =====================================================
  // SISTEMA DE GRID RESPONSIVO PREMIUM
  // =====================================================
  Widget _buildResponsiveGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMedium = constraints.maxWidth > 800;

        return Column(
          children: [
            /// LINHA 1: STATUS + CONFORMIDADE
            Column(
              children: [
                _animatedEnhanced(
                  PremiumSection(
                    title: 'Visão Geral',
                    subtitle: 'Métricas principais do sistema',
                    icon: Icons.insights_rounded,
                    child: _buildStatusSectionEnhanced(context),
                  ),
                  delay: 0,
                ),
                const SizedBox(height: 32),
                _animatedEnhanced(
                  PremiumSection(
                    title: 'Conformidade',
                    subtitle: 'Status de adequação dos EPIs',
                    icon: Icons.verified_rounded,
                    child: ConformitySelectorChart(),
                  ),
                  delay: 100,
                ),
              ],
            ),

            /// LINHA 2: ANÁLISE DE CUSTOS
            _animatedEnhanced(
              PremiumSection(
                title: 'Análise de Custos',
                subtitle: 'Distribuição e otimização de investimentos',
                icon: Icons.pie_chart_rounded,
                child: _buildCostsSectionEnhanced(context),
              ),
              delay: 200,
            ),

            /// LINHA 3: COLABORADORES + DURABILIDADE
            if (isMedium)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _animatedEnhanced(
                      PremiumSection(
                        title: 'Top Colaboradores',
                        subtitle: 'Desempenho e conformidade individual',
                        icon: Icons.people_alt_rounded,
                        child: TopEmployeesChart(),
                      ),
                      delay: 300,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _animatedEnhanced(
                      PremiumSection(
                        title: 'Durabilidade EPI',
                        subtitle: 'Vida útil e tempo de reposição',
                        icon: Icons.timeline_rounded,
                        child: EpiDurabilityChart(),
                      ),
                      delay: 400,
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _animatedEnhanced(
                    PremiumSection(
                      title: 'Top Colaboradores',
                      subtitle: 'Desempenho e conformidade individual',
                      icon: Icons.people_alt_rounded,
                      child: TopEmployeesChart(),
                    ),
                    delay: 300,
                  ),
                  const SizedBox(height: 32),
                  _animatedEnhanced(
                    PremiumSection(
                      title: 'Durabilidade EPI',
                      subtitle: 'Vida útil e tempo de reposição',
                      icon: Icons.timeline_rounded,
                      child: EpiDurabilityChart(),
                    ),
                    delay: 400,
                  ),
                ],
              ),

            /// LINHA 4: MONITORAMENTO DE RISCOS
            _animatedEnhanced(
              PremiumSection(
                title: 'Monitoramento de Riscos',
                subtitle: 'Estoque crítico e principais ocorrências',
                icon: Icons.warning_amber_rounded,
                child: _buildRiskAreaEnhanced(context),
              ),
              delay: 500,
            ),

            /// LINHA 5: ATIVIDADES RECENTES
            _animatedEnhanced(
              PremiumSection(
                title: 'Atividades Recentes',
                subtitle: 'Últimas movimentações do sistema',
                icon: Icons.history_rounded,
                child: const RecentActivitiesWidget(),
              ),
              delay: 600,
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // SEÇÕES ESPECÍFICAS APRIMORADAS
  // =====================================================

  Widget _buildStatusSectionEnhanced(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
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
          childAspectRatio: 1.4,
          children: const [
            StatusCard(
              title: 'EPIs Entregues',
              value: '1.250',
              subtitle: 'R\$ 87.500,00',
              icon: Icons.check_circle_rounded,
              color: Colors.green,
            ),
            StatusCard(
              title: 'Entregas Pendentes',
              value: '85',
              subtitle: 'R\$ 12.500,00',
              icon: Icons.pending_actions_rounded,
              color: Colors.orange,
            ),
            StatusCard(
              title: 'CAs Vencidos',
              value: '23',
              subtitle: 'R\$ 3.450,00',
              icon: Icons.warning_amber_rounded,
              color: Colors.red,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCostsSectionEnhanced(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth > 1100) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: CostPerEpiChart()),
            const SizedBox(width: 24),
            Expanded(child: CostPerSectorChart()),
          ],
        );
      } else {
        return Column(
          children: [
            CostPerEpiChart(),
            const SizedBox(height: 24),
            CostPerSectorChart(),
          ],
        );
      }
    },
  );

  Widget _buildRiskAreaEnhanced(BuildContext context) => Column(
    children: [
      LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1100) {
            return Row(
              children: [
                Expanded(child: CriticalStockWidget()),
                const SizedBox(width: 24),
                Expanded(child: TopReasonsTable()),
              ],
            );
          } else {
            return Column(
              children: [
                CriticalStockWidget(),
                const SizedBox(height: 24),
                TopReasonsTable(),
              ],
            );
          }
        },
      ),
    ],
  );

  // =====================================================
  // ANIMAÇÃO DE ENTRADA SOFISTICADA
  // =====================================================
  Widget _animatedEnhanced(Widget child, {int delay = 0}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform(
          transform: Matrix4.identity()
            ..translate(0.0, 40 * (1 - value))
            ..scale(value),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}

// =====================================================
// COMPONENTE DE SEÇÃO PREMIUM
// =====================================================
class PremiumSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final IconData? icon;
  final VoidCallback? onInfo;

  const PremiumSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.icon,
    this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        margin: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER COM MICROINTERAÇÃO
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (icon != null) ...[
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  icon,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: Text(
                                title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24,
                                  letterSpacing: -0.4,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onInfo != null)
                    IconButton(
                      icon: Icon(Icons.info_outline_rounded, size: 20),
                      onPressed: onInfo,
                      tooltip: 'Mais informações',
                    ),
                ],
              ),
            ),

            /// CONTEÚDO COM ELEVAÇÃO SUTIL
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
