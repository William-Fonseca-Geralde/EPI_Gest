import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Configurações de notificações
  bool _notifyExpiredEPIs = true;
  bool _notifyLowStock = true;
  bool _notifyPendingExchanges = true;
  int _expirationWarningDays = 30;

  // Configurações de estoque
  int _minimumStockLevel = 10;
  bool _autoGenerateOrders = false;

  // Configurações de relatórios
  String _defaultReportFormat = 'PDF';
  bool _includePhotosInReports = true;

  // Configurações de segurança
  bool _requirePasswordForCriticalActions = true;
  int _sessionTimeoutMinutes = 30;
  bool _enableAuditLog = true;

  // Configurações de dados
  int _dataRetentionMonths = 24;
  bool _autoBackup = true;
  String _backupFrequency = 'Diário';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        color: colorScheme.surface,
        child: Column(
          children: [
            Container(
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
              child: Row(
                spacing: 16,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.settings,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 40,
                    ),
                  ),
                  Column(
                    spacing: 4,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configurações',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Configurações gerais do sistema',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Conteúdo com Scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Define se deve usar layout de duas colunas
                    final useTwoColumns = constraints.maxWidth > 850;

                    if (useTwoColumns) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Coluna Esquerda
                          Expanded(
                            child: Column(
                              children: [
                                _buildNotificationsSection(context),
                                const SizedBox(height: 16),
                                _buildInventorySection(context),
                                const SizedBox(height: 16),
                                _buildReportsSection(context),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Coluna Direita
                          Expanded(
                            child: Column(
                              children: [
                                _buildSecuritySection(context),
                                const SizedBox(height: 16),
                                _buildDataBackupSection(context),
                                const SizedBox(height: 16),
                                _buildAboutSection(context),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Layout de uma coluna para telas menores
                      return Column(
                        children: [
                          _buildNotificationsSection(context),
                          const SizedBox(height: 16),
                          _buildInventorySection(context),
                          const SizedBox(height: 16),
                          _buildReportsSection(context),
                          const SizedBox(height: 16),
                          _buildSecuritySection(context),
                          const SizedBox(height: 16),
                          _buildDataBackupSection(context),
                          const SizedBox(height: 16),
                          _buildAboutSection(context),
                          const SizedBox(height: 80), // Espaço para o FAB
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _saveSettings(context);
        },
        icon: const Icon(Icons.save_outlined),
        label: const Text('Salvar Configurações'),
        elevation: 4,
      ),
    );
  }

  Widget _buildNotificationsSection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: 'Notificações',
      icon: Icons.notifications_outlined,
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.warning_amber_outlined),
          title: const Text('EPIs Vencidos'),
          subtitle: const Text('Alertar sobre EPIs vencidos'),
          value: _notifyExpiredEPIs,
          onChanged: (value) {
            setState(() => _notifyExpiredEPIs = value);
          },
        ),
        const Divider(height: 0),
        SwitchListTile(
          secondary: const Icon(Icons.inventory_outlined),
          title: const Text('Estoque Baixo'),
          subtitle: const Text('Alertar quando estoque estiver baixo'),
          value: _notifyLowStock,
          onChanged: (value) {
            setState(() => _notifyLowStock = value);
          },
        ),
        const Divider(height: 0),
        SwitchListTile(
          secondary: const Icon(Icons.swap_horiz_outlined),
          title: const Text('Trocas Pendentes'),
          subtitle: const Text('Notificar sobre trocas pendentes'),
          value: _notifyPendingExchanges,
          onChanged: (value) {
            setState(() => _notifyPendingExchanges = value);
          },
        ),
        const Divider(height: 0),
        ListTile(
          leading: const Icon(Icons.calendar_today_outlined),
          title: const Text('Aviso de Vencimento'),
          subtitle: Text('Alertar $_expirationWarningDays dias antes'),
          trailing: SizedBox(
            width: 100,
            child: DropdownButtonFormField<int>(
              value: _expirationWarningDays,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              items: [7, 15, 30, 60, 90]
                  .map(
                    (days) => DropdownMenuItem(
                      value: days,
                      child: Text('$days dias'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _expirationWarningDays = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInventorySection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: 'Gestão de Estoque',
      icon: Icons.inventory_2_outlined,
      children: [
        ListTile(
          leading: const Icon(Icons.production_quantity_limits_outlined),
          title: const Text('Nível Mínimo de Estoque'),
          subtitle: Text(
            'Alertar quando abaixo de $_minimumStockLevel unidades',
          ),
          trailing: SizedBox(
            width: 80,
            child: TextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.all(8),
              ),
              controller: TextEditingController(
                text: _minimumStockLevel.toString(),
              ),
              onChanged: (value) {
                final parsed = int.tryParse(value);
                if (parsed != null) {
                  setState(() => _minimumStockLevel = parsed);
                }
              },
            ),
          ),
        ),
        const Divider(height: 0),
        SwitchListTile(
          secondary: const Icon(Icons.auto_awesome_outlined),
          title: const Text('Pedidos Automáticos'),
          subtitle: const Text('Gerar pedidos quando estoque baixo'),
          value: _autoGenerateOrders,
          onChanged: (value) {
            setState(() => _autoGenerateOrders = value);
          },
        ),
      ],
    );
  }

  Widget _buildReportsSection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: 'Relatórios',
      icon: Icons.assessment_outlined,
      children: [
        ListTile(
          leading: const Icon(Icons.picture_as_pdf_outlined),
          title: const Text('Formato Padrão'),
          subtitle: const Text('Formato de exportação padrão'),
          trailing: DropdownButton<String>(
            value: _defaultReportFormat,
            items: ['PDF', 'Excel', 'CSV']
                .map(
                  (format) =>
                      DropdownMenuItem(value: format, child: Text(format)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _defaultReportFormat = value);
              }
            },
          ),
        ),
        const Divider(height: 0),
        SwitchListTile(
          secondary: const Icon(Icons.photo_library_outlined),
          title: const Text('Incluir Fotos'),
          subtitle: const Text('Adicionar fotos dos EPIs nos relatórios'),
          value: _includePhotosInReports,
          onChanged: (value) {
            setState(() => _includePhotosInReports = value);
          },
        ),
      ],
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: 'Segurança',
      icon: Icons.security_outlined,
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.lock_outlined),
          title: const Text('Autenticação Extra'),
          subtitle: const Text('Senha para ações críticas'),
          value: _requirePasswordForCriticalActions,
          onChanged: (value) {
            setState(() => _requirePasswordForCriticalActions = value);
          },
        ),
        const Divider(height: 0),
        ListTile(
          leading: const Icon(Icons.timer_outlined),
          title: const Text('Timeout de Sessão'),
          subtitle: Text('Deslogar após $_sessionTimeoutMinutes minutos'),
          trailing: SizedBox(
            width: 100,
            child: DropdownButtonFormField<int>(
              value: _sessionTimeoutMinutes,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              items: [15, 30, 60, 120]
                  .map(
                    (minutes) => DropdownMenuItem(
                      value: minutes,
                      child: Text('$minutes min'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _sessionTimeoutMinutes = value);
                }
              },
            ),
          ),
        ),
        const Divider(height: 0),
        SwitchListTile(
          secondary: const Icon(Icons.history_outlined),
          title: const Text('Log de Auditoria'),
          subtitle: const Text('Registrar todas as ações do sistema'),
          value: _enableAuditLog,
          onChanged: (value) {
            setState(() => _enableAuditLog = value);
          },
        ),
        const Divider(height: 0),
        ListTile(
          leading: const Icon(Icons.key_outlined),
          title: const Text('Alterar Senha'),
          subtitle: const Text('Modificar senha de acesso'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showChangePasswordDialog(context);
          },
        ),
      ],
    );
  }

  Widget _buildDataBackupSection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: 'Dados e Backup',
      icon: Icons.backup_outlined,
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.cloud_upload_outlined),
          title: const Text('Backup Automático'),
          subtitle: const Text('Fazer backup automático dos dados'),
          value: _autoBackup,
          onChanged: (value) {
            setState(() => _autoBackup = value);
          },
        ),
        if (_autoBackup) ...[
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.schedule_outlined),
            title: const Text('Frequência de Backup'),
            subtitle: Text('Backup $_backupFrequency'),
            trailing: DropdownButton<String>(
              value: _backupFrequency,
              items: ['Diário', 'Semanal', 'Mensal']
                  .map(
                    (freq) => DropdownMenuItem(value: freq, child: Text(freq)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _backupFrequency = value);
                }
              },
            ),
          ),
        ],
        const Divider(height: 0),
        ListTile(
          leading: const Icon(Icons.delete_sweep_outlined),
          title: const Text('Retenção de Dados'),
          subtitle: Text('Manter dados por $_dataRetentionMonths meses'),
          trailing: SizedBox(
            width: 100,
            child: DropdownButtonFormField<int>(
              value: _dataRetentionMonths,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              items: [12, 24, 36, 60]
                  .map(
                    (months) => DropdownMenuItem(
                      value: months,
                      child: Text('$months meses'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _dataRetentionMonths = value);
                }
              },
            ),
          ),
        ),
        const Divider(height: 0),
        ListTile(
          leading: const Icon(Icons.download_outlined),
          title: const Text('Exportar Dados'),
          subtitle: const Text('Fazer download de todos os dados'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showExportDataDialog(context);
          },
        ),
        const Divider(height: 0),
        ListTile(
          leading: Icon(
            Icons.delete_forever_outlined,
            color: Theme.of(context).colorScheme.error,
          ),
          title: Text(
            'Limpar Dados',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          subtitle: const Text('Remover todos os dados do sistema'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showClearDataDialog(context);
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: 'Sobre',
      icon: Icons.info_outlined,
      children: [
        ListTile(
          leading: const Icon(Icons.apps_outlined),
          title: const Text('Versão do App'),
          subtitle: const Text('1.0.0 (Build 1)'),
        ),
        const Divider(height: 0),
        ListTile(
          leading: const Icon(Icons.update_outlined),
          title: const Text('Verificar Atualizações'),
          subtitle: const Text('Última verificação: Hoje'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Você está usando a versão mais recente'),
              ),
            );
          },
        ),
        const Divider(height: 0),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Termos de Uso'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Abrir termos de uso
          },
        ),
        const Divider(height: 0),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Política de Privacidade'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Abrir política de privacidade
          },
        ),
        const Divider(height: 0),
        ListTile(
          leading: const Icon(Icons.code_outlined),
          title: const Text('Licenças Open Source'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            showLicensePage(context: context);
          },
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  void _saveSettings(BuildContext context) {
    // Aqui você implementaria a lógica de salvar as configurações
    // Por exemplo, usando SharedPreferences, banco de dados local, etc.

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 12),
            Text('Configurações salvas com sucesso!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Senha'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha Atual',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nova Senha',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar Nova Senha',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              // Implementar lógica de alteração de senha
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Senha alterada com sucesso!')),
              );
            },
            child: const Text('Alterar'),
          ),
        ],
      ),
    );
  }

  void _showExportDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Dados'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selecione o que deseja exportar:'),
            SizedBox(height: 16),
            CheckboxListTile(
              title: Text('EPIs e Estoque'),
              value: true,
              onChanged: null,
            ),
            CheckboxListTile(
              title: Text('Funcionários'),
              value: true,
              onChanged: null,
            ),
            CheckboxListTile(
              title: Text('Histórico de Trocas'),
              value: true,
              onChanged: null,
            ),
            CheckboxListTile(
              title: Text('Relatórios'),
              value: true,
              onChanged: null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Exportação iniciada! Você receberá uma notificação quando concluir.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Exportar'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.error,
          size: 48,
        ),
        title: const Text('Atenção!'),
        content: const Text(
          'Esta ação irá remover TODOS os dados do sistema de forma PERMANENTE. '
          'Esta operação não pode ser desfeita.\n\n'
          'Tem certeza que deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementar lógica de limpeza de dados
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Dados removidos com sucesso'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sim, Limpar Tudo'),
          ),
        ],
      ),
    );
  }
}
