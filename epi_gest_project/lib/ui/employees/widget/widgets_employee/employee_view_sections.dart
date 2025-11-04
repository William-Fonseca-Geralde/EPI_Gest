import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BasicInfoViewSection extends StatelessWidget {
  final String id;
  final String matricula;
  final String nome;
  final DateTime? dataEntrada;

  const BasicInfoViewSection({
    super.key,
    required this.id,
    required this.matricula,
    required this.nome,
    required this.dataEntrada,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildDisabledTextField(
                context: context,
                label: 'ID',
                value: id,
                icon: Icons.badge_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _buildDisabledTextField(
                context: context,
                label: 'Matrícula',
                value: matricula,
                icon: Icons.confirmation_number_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDisabledTextField(
          context: context,
          label: 'Nome Completo',
          value: nome,
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildDisabledTextField(
          context: context,
          label: 'Data de Entrada',
          value: dataEntrada != null
              ? dateFormat.format(dataEntrada!)
              : 'Não informada',
          icon: Icons.calendar_today_outlined,
        ),
      ],
    );
  }

  Widget _buildDisabledTextField({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
    );
  }
}

class DocumentsViewSection extends StatelessWidget {
  final String? cpf;
  final String? rg;
  final DateTime? dataNascimento;

  const DocumentsViewSection({
    super.key,
    this.cpf,
    this.rg,
    this.dataNascimento,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      children: [
        _buildDisabledTextField(
          context: context,
          label: 'CPF',
          value: cpf ?? 'Não informado',
          icon: Icons.credit_card_outlined,
        ),
        const SizedBox(height: 16),
        _buildDisabledTextField(
          context: context,
          label: 'RG',
          value: rg ?? 'Não informado',
          icon: Icons.assignment_ind_outlined,
        ),
        const SizedBox(height: 16),
        _buildDisabledTextField(
          context: context,
          label: 'Data de Nascimento',
          value: dataNascimento != null
              ? dateFormat.format(dataNascimento!)
              : 'Não informada',
          icon: Icons.cake_outlined,
        ),
      ],
    );
  }

  Widget _buildDisabledTextField({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
    );
  }
}

class ContactViewSection extends StatelessWidget {
  final String? telefone;
  final String? email;

  const ContactViewSection({
    super.key,
    this.telefone,
    this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDisabledTextField(
          context: context,
          label: 'Telefone/Celular',
          value: telefone ?? 'Não informado',
          icon: Icons.phone_outlined,
        ),
        const SizedBox(height: 16),
        _buildDisabledTextField(
          context: context,
          label: 'E-mail',
          value: email ?? 'Não informado',
          icon: Icons.email_outlined,
        ),
      ],
    );
  }

  Widget _buildDisabledTextField({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
    );
  }
}

class JobViewSection extends StatelessWidget {
  final String? setor;
  final String? funcao;
  final String? vinculo;

  const JobViewSection({
    super.key,
    this.setor,
    this.funcao,
    this.vinculo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDisabledTextField(
          context: context,
          label: 'Setor/Departamento',
          value: setor ?? 'Não informado',
          icon: Icons.business_outlined,
        ),
        const SizedBox(height: 16),
        _buildDisabledTextField(
          context: context,
          label: 'Cargo/Função',
          value: funcao ?? 'Não informado',
          icon: Icons.assignment_ind_outlined,
        ),
        const SizedBox(height: 16),
        _buildDisabledTextField(
          context: context,
          label: 'Tipo de Vínculo',
          value: vinculo ?? 'Não informado',
          icon: Icons.work_history_outlined,
        ),
      ],
    );
  }

  Widget _buildDisabledTextField({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
    );
  }
}

class WorkConditionsViewSection extends StatelessWidget {
  final String? localTrabalho;
  final String? turno;
  final List<String>? epis;
  final List<String>? riscos;

  const WorkConditionsViewSection({
    super.key,
    this.localTrabalho,
    this.turno,
    this.epis,
    this.riscos,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDisabledTextField(
          context: context,
          label: 'Local de Trabalho',
          value: localTrabalho ?? 'Não informado',
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 16),
        _buildDisabledTextField(
          context: context,
          label: 'Turno de Trabalho',
          value: turno ?? 'Não informado',
          icon: Icons.access_time_outlined,
        ),
        const SizedBox(height: 16),
        _buildMultiValueField(
          context: context,
          label: 'EPIs Necessários',
          values: epis,
          icon: Icons.security_outlined,
        ),
        const SizedBox(height: 16),
        _buildMultiValueField(
          context: context,
          label: 'Riscos Associados',
          values: riscos,
          icon: Icons.warning_outlined,
        ),
      ],
    );
  }

  Widget _buildDisabledTextField({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
    );
  }

  Widget _buildMultiValueField({
    required BuildContext context,
    required String label,
    required List<String>? values,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final hasValues = values != null && values.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                if (!hasValues)
                  Text(
                    'Nenhum item cadastrado',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else ...[
                  Text(
                    '${values!.length} ${values.length == 1 ? 'item cadastrado' : 'itens cadastrados'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: values.map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontSize: 11,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HierarchyViewSection extends StatelessWidget {
  final String? lider;
  final String? gestor;

  const HierarchyViewSection({
    super.key,
    this.lider,
    this.gestor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDisabledTextField(
          context: context,
          label: 'Líder Responsável',
          value: lider ?? 'Não informado',
          icon: Icons.supervisor_account_outlined,
        ),
        const SizedBox(height: 16),
        _buildDisabledTextField(
          context: context,
          label: 'Gestor Direto',
          value: gestor ?? 'Não informado',
          icon: Icons.manage_accounts_outlined,
        ),
      ],
    );
  }

  Widget _buildDisabledTextField({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
    );
  }
}

class StatusViewSection extends StatelessWidget {
  final bool statusAtivo;
  final bool statusFerias;
  final DateTime? dataRetornoFerias;

  const StatusViewSection({
    super.key,
    required this.statusAtivo,
    required this.statusFerias,
    this.dataRetornoFerias,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      children: [
        _buildStatusField(
          context: context,
          label: 'Status do Funcionário',
          value: statusAtivo,
          activeText: 'Ativo',
          inactiveText: 'Inativo',
          icon: Icons.person_outlined,
        ),
        const SizedBox(height: 16),
        _buildStatusField(
          context: context,
          label: 'Status de Férias',
          value: statusFerias,
          activeText: 'Em Férias',
          inactiveText: 'Não está de férias',
          icon: Icons.beach_access_outlined,
        ),
        if (statusFerias && dataRetornoFerias != null) ...[
          const SizedBox(height: 16),
          _buildDisabledTextField(
            context: context,
            label: 'Data de Retorno das Férias',
            value: dateFormat.format(dataRetornoFerias!),
            icon: Icons.event_available_outlined,
          ),
        ],
      ],
    );
  }

  Widget _buildStatusField({
    required BuildContext context,
    required String label,
    required bool value,
    required String activeText,
    required String inactiveText,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  value ? activeText : inactiveText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: value
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: value ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: value
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value ? activeText : inactiveText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: value
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledTextField({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
    );
  }
}

class TerminationViewSection extends StatelessWidget {
  final DateTime? dataDesligamento;
  final String? motivoDesligamento;

  const TerminationViewSection({
    super.key,
    this.dataDesligamento,
    this.motivoDesligamento,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      children: [
        _buildDisabledTextField(
          context: context,
          label: 'Data de Desligamento',
          value: dataDesligamento != null
              ? dateFormat.format(dataDesligamento!)
              : 'Não informada',
          icon: Icons.event_busy_outlined,
        ),
        const SizedBox(height: 16),
        _buildDisabledTextField(
          context: context,
          label: 'Motivo do Desligamento',
          value: motivoDesligamento ?? 'Não informado',
          icon: Icons.description_outlined,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildDisabledTextField({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
    );
  }
}