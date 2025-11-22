import 'package:epi_gest_project/ui/widgets/form_fields.dart';
import 'package:epi_gest_project/ui/utils/input_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class BasicInfoSection extends StatelessWidget {
  final TextEditingController matriculaController;
  final TextEditingController nomeController;
  final TextEditingController dataEntradaController;
  final VoidCallback onSelectDateEntrada;
  final bool enabled;

  const BasicInfoSection({
    super.key,
    required this.matriculaController,
    required this.nomeController,
    required this.dataEntradaController,
    required this.onSelectDateEntrada,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        Row(
          spacing: 16,
          children: [
            Expanded(
              flex: 2,
              child: CustomTextField(
                controller: matriculaController,
                label: 'Matrícula',
                hint: 'Ex: 12345',
                icon: Icons.confirmation_number_outlined,
                enabled: enabled,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Obrigatório';
                  }
                  return null;
                },
              ),
            ),
            Expanded(
              flex: 3,
              child: CustomDateField(
                controller: dataEntradaController,
                label: 'Data de Entrada',
                hint: 'dd/mm/aaaa',
                icon: Icons.calendar_today_outlined,
                onTap: onSelectDateEntrada,
                enabled: enabled,
              ),
            ),
          ],
        ),
        CustomTextField(
          controller: nomeController,
          label: 'Nome Completo',
          hint: 'Ex: João Silva',
          icon: Icons.person_outline,
          enabled: enabled,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Campo obrigatório';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class DocumentsSection extends StatelessWidget {
  final TextEditingController cpfController;
  final TextEditingController rgController;
  final TextEditingController dataNascimentoController;
  final VoidCallback onSelectDateNascimento;
  final bool enabled;

  const DocumentsSection({
    super.key,
    required this.cpfController,
    required this.rgController,
    required this.dataNascimentoController,
    required this.onSelectDateNascimento,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        CustomTextField(
          controller: cpfController,
          label: 'CPF',
          hint: '000.000.000-00',
          icon: Icons.credit_card_outlined,
          keyboardType: TextInputType.number,
          enabled: enabled,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(14),
            CpfInputFormatter(),
          ],
        ),
        CustomTextField(
          controller: rgController,
          label: 'RG',
          hint: '00.000.000-0',
          icon: Icons.assignment_ind_outlined,
          enabled: enabled,
          inputFormatters: [RgInputFormatter()],
        ),
        CustomDateField(
          controller: dataNascimentoController,
          label: 'Data de Nascimento',
          hint: 'dd/mm/aaaa',
          icon: Icons.cake_outlined,
          onTap: onSelectDateNascimento,
          enabled: enabled,
        ),
      ],
    );
  }
}

class ContactSection extends StatelessWidget {
  final TextEditingController telefoneController;
  final TextEditingController emailController;
  final bool enabled;

  const ContactSection({
    super.key,
    required this.telefoneController,
    required this.emailController,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: telefoneController,
          label: 'Telefone/Celular',
          hint: '(00) 00000-0000',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          enabled: enabled,
          inputFormatters: [TelefoneInputFormatter()],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: emailController,
          label: 'E-mail',
          hint: 'exemplo@empresa.com',
          icon: Icons.email_outlined,
          enabled: enabled,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }
}

class WorkConditionsSection extends StatelessWidget {
  final TextEditingController vinculoController;
  final TextEditingController turnoController;
  final List<String> locaisTrabalhoSugeridos;
  final List<String> turnosSugeridos;
  final GlobalKey turnoButtonKey;
  final GlobalKey vinculoButtonKey; // NOVO PARÂMETRO
  final VoidCallback onAddTurno;
  final VoidCallback onAddVinculo; // NOVO PARÂMETRO
  final bool enabled;

  const WorkConditionsSection({
    super.key,
    required this.vinculoController,
    required this.turnoController,
    required this.locaisTrabalhoSugeridos,
    required this.turnosSugeridos,
    required this.turnoButtonKey,
    required this.vinculoButtonKey, // NOVO PARÂMETRO
    required this.onAddTurno,
    required this.onAddVinculo, // NOVO PARÂMETRO
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAutocompleteField(
          controller: vinculoController,
          label: 'Vinculo',
          hint: 'Selecione o vinculo',
          icon: Icons.location_on_outlined,
          suggestions: locaisTrabalhoSugeridos,
          showAddButton: enabled,
          onAddPressed: onAddVinculo,
          addButtonKey: vinculoButtonKey,
          enabled: enabled,
        ),
        const SizedBox(height: 16),
        CustomAutocompleteField(
          controller: turnoController,
          label: 'Turno de Trabalho',
          hint: 'Selecione o turno',
          icon: Icons.access_time_outlined,
          suggestions: turnosSugeridos,
          showAddButton: enabled,
          onAddPressed: onAddTurno,
          addButtonKey: turnoButtonKey,
          enabled: enabled,
        ),
      ],
    );
  }
}

class HierarchySection extends StatelessWidget {
  final TextEditingController liderController;
  final TextEditingController gestorController;
  final List<String> funcionariosSugeridos;
  final bool enabled;

  const HierarchySection({
    super.key,
    required this.liderController,
    required this.gestorController,
    required this.funcionariosSugeridos,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAutocompleteField(
          controller: liderController,
          label: 'Líder Responsável',
          hint: 'Selecione o líder',
          icon: Icons.supervisor_account_outlined,
          suggestions: funcionariosSugeridos,
          enabled: enabled,
        ),
        const SizedBox(height: 16),
        CustomAutocompleteField(
          controller: gestorController,
          label: 'Gestor Direto',
          hint: 'Selecione o gestor',
          icon: Icons.manage_accounts_outlined,
          suggestions: funcionariosSugeridos,
          enabled: enabled,
        ),
      ],
    );
  }
}

class StatusSection extends StatelessWidget {
  final bool statusAtivo;
  final bool statusFerias;
  final DateTime? dataRetornoFerias;
  final Function(bool) onStatusAtivoChanged;
  final Function(bool) onStatusFeriasChanged;
  final VoidCallback onSelectDateRetornoFerias;
  final bool enabled;

  const StatusSection({
    super.key,
    required this.statusAtivo,
    required this.statusFerias,
    required this.dataRetornoFerias,
    required this.onStatusAtivoChanged,
    required this.onStatusFeriasChanged,
    required this.onSelectDateRetornoFerias,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomSwitchField(
          value: statusAtivo,
          onChanged: onStatusAtivoChanged,
          label: 'Status do Funcionário',
          activeText: 'Ativo',
          inactiveText: 'Inativo',
          icon: Icons.person_outlined,
          enabled: enabled,
        ),
        const SizedBox(height: 16),
        CustomSwitchField(
          value: statusFerias,
          onChanged: onStatusFeriasChanged,
          label: 'Status de Férias',
          activeText: 'Em Férias',
          inactiveText: 'Não está de férias',
          icon: Icons.beach_access_outlined,
          enabled: enabled,
        ),
        if (statusFerias) ...[
          const SizedBox(height: 16),
          CustomDateField(
            controller: TextEditingController(
              text: dataRetornoFerias != null
                  ? DateFormat('dd/MM/yyyy').format(dataRetornoFerias!)
                  : '',
            ),
            label: 'Data de Retorno das Férias',
            hint: 'dd/mm/aaaa',
            icon: Icons.event_available_outlined,
            onTap: onSelectDateRetornoFerias,
            enabled: enabled,
          ),
        ],
      ],
    );
  }
}

class TerminationSection extends StatelessWidget {
  final TextEditingController dataDesligamentoController;
  final TextEditingController motivoDesligamentoController;
  final VoidCallback onSelectDateDesligamento;
  final bool enabled;

  const TerminationSection({
    super.key,
    required this.dataDesligamentoController,
    required this.motivoDesligamentoController,
    required this.onSelectDateDesligamento,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomDateField(
          controller: dataDesligamentoController,
          label: 'Data de Desligamento',
          hint: 'dd/mm/aaaa',
          icon: Icons.event_busy_outlined,
          onTap: onSelectDateDesligamento,
          enabled: enabled,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: motivoDesligamentoController,
          label: 'Motivo do Desligamento',
          hint: 'Digite o motivo',
          icon: Icons.description_outlined,
          maxLines: 3,
          enabled: enabled,
        ),
      ],
    );
  }
}