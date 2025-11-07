import 'package:epi_gest_project/ui/widgets/form_fields.dart';
import 'package:epi_gest_project/ui/utils/input_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class BasicInfoSection extends StatelessWidget {
  final TextEditingController idController;
  final TextEditingController matriculaController;
  final TextEditingController nomeController;
  final TextEditingController dataEntradaController;
  final VoidCallback onSelectDateEntrada;

  const BasicInfoSection({
    super.key,
    required this.idController,
    required this.matriculaController,
    required this.nomeController,
    required this.dataEntradaController,
    required this.onSelectDateEntrada,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: CustomTextField(
                controller: idController,
                label: 'ID',
                hint: 'Ex: 001',
                icon: Icons.badge_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Obrigatório';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: CustomTextField(
                controller: matriculaController,
                label: 'Matrícula',
                hint: 'Ex: 12345',
                icon: Icons.confirmation_number_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Obrigatório';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: nomeController,
          label: 'Nome Completo',
          hint: 'Ex: João Silva',
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Campo obrigatório';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomDateField(
          controller: dataEntradaController,
          label: 'Data de Entrada',
          hint: 'dd/mm/aaaa',
          icon: Icons.calendar_today_outlined,
          onTap: onSelectDateEntrada,
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

  const DocumentsSection({
    super.key,
    required this.cpfController,
    required this.rgController,
    required this.dataNascimentoController,
    required this.onSelectDateNascimento,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: cpfController,
          label: 'CPF',
          hint: '000.000.000-00',
          icon: Icons.credit_card_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
            CpfInputFormatter(),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: rgController,
          label: 'RG',
          hint: '00.000.000-0',
          icon: Icons.assignment_ind_outlined,
          inputFormatters: [RgInputFormatter()],
        ),
        const SizedBox(height: 16),
        CustomDateField(
          controller: dataNascimentoController,
          label: 'Data de Nascimento',
          hint: 'dd/mm/aaaa',
          icon: Icons.cake_outlined,
          onTap: onSelectDateNascimento,
        ),
      ],
    );
  }
}

class ContactSection extends StatelessWidget {
  final TextEditingController telefoneController;
  final TextEditingController emailController;

  const ContactSection({
    super.key,
    required this.telefoneController,
    required this.emailController,
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
          inputFormatters: [TelefoneInputFormatter()],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: emailController,
          label: 'E-mail',
          hint: 'exemplo@empresa.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }
}

class JobSection extends StatelessWidget {
  final TextEditingController setorController;
  final TextEditingController funcaoController;
  final TextEditingController vinculoController;
  final List<String> setoresSugeridos;
  final List<String> funcoesSugeridas;
  final List<String> vinculosSugeridos;
  final GlobalKey setorButtonKey;
  final GlobalKey funcaoButtonKey;
  final GlobalKey vinculoButtonKey;
  final VoidCallback onAddSetor;
  final VoidCallback onAddFuncao;
  final VoidCallback onAddVinculo;

  const JobSection({
    super.key,
    required this.setorController,
    required this.funcaoController,
    required this.vinculoController,
    required this.setoresSugeridos,
    required this.funcoesSugeridas,
    required this.vinculosSugeridos,
    required this.setorButtonKey,
    required this.funcaoButtonKey,
    required this.vinculoButtonKey,
    required this.onAddSetor,
    required this.onAddFuncao,
    required this.onAddVinculo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAutocompleteField(
          controller: setorController,
          label: 'Setor/Departamento',
          hint: 'Selecione ou digite um setor',
          icon: Icons.business_outlined,
          suggestions: setoresSugeridos,
          showAddButton: true,
          onAddPressed: onAddSetor,
          addButtonKey: setorButtonKey,
        ),
        const SizedBox(height: 16),
        CustomAutocompleteField(
          controller: funcaoController,
          label: 'Cargo/Função',
          hint: 'Selecione ou digite uma função',
          icon: Icons.assignment_ind_outlined,
          suggestions: funcoesSugeridas,
          showAddButton: true,
          onAddPressed: onAddFuncao,
          addButtonKey: funcaoButtonKey,
        ),
        const SizedBox(height: 16),
        CustomAutocompleteField(
          controller: vinculoController,
          label: 'Tipo de Vínculo',
          hint: 'Selecione o tipo de vínculo',
          icon: Icons.work_history_outlined,
          suggestions: vinculosSugeridos,
          showAddButton: true,
          onAddPressed: onAddVinculo,
          addButtonKey: vinculoButtonKey,
        ),
      ],
    );
  }
}

class WorkConditionsSection extends StatelessWidget {
  final TextEditingController localTrabalhoController;
  final TextEditingController turnoController;
  final List<String> locaisTrabalhoSugeridos;
  final List<String> turnosSugeridos;
  final List<String> episSelecionados;
  final List<String> riscosSelecionados;
  final GlobalKey turnoButtonKey;
  final GlobalKey episButtonKey;
  final GlobalKey riscosButtonKey;
  final VoidCallback onAddTurno;
  final VoidCallback onSelectEpis;
  final VoidCallback onSelectRiscos;

  const WorkConditionsSection({
    super.key,
    required this.localTrabalhoController,
    required this.turnoController,
    required this.locaisTrabalhoSugeridos,
    required this.turnosSugeridos,
    required this.episSelecionados,
    required this.riscosSelecionados,
    required this.turnoButtonKey,
    required this.episButtonKey,
    required this.riscosButtonKey,
    required this.onAddTurno,
    required this.onSelectEpis,
    required this.onSelectRiscos,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAutocompleteField(
          controller: localTrabalhoController,
          label: 'Local de Trabalho',
          hint: 'Selecione o local',
          icon: Icons.location_on_outlined,
          suggestions: locaisTrabalhoSugeridos,
        ),
        const SizedBox(height: 16),
        CustomAutocompleteField(
          controller: turnoController,
          label: 'Turno de Trabalho',
          hint: 'Selecione o turno',
          icon: Icons.access_time_outlined,
          suggestions: turnosSugeridos,
          showAddButton: true,
          onAddPressed: onAddTurno,
          addButtonKey: turnoButtonKey,
        ),
        const SizedBox(height: 16),
        CustomMultiSelectField(
          label: 'EPIs Necessários',
          hint: 'Selecione os EPIs',
          icon: Icons.security_outlined,
          selectedItems: episSelecionados,
          buttonKey: episButtonKey,
          onTap: onSelectEpis,
        ),
        const SizedBox(height: 16),
        CustomMultiSelectField(
          label: 'Riscos Associados',
          hint: 'Selecione os riscos',
          icon: Icons.warning_outlined,
          selectedItems: riscosSelecionados,
          buttonKey: riscosButtonKey,
          onTap: onSelectRiscos,
        ),
      ],
    );
  }
}

class HierarchySection extends StatelessWidget {
  final TextEditingController liderController;
  final TextEditingController gestorController;
  final List<String> funcionariosSugeridos;

  const HierarchySection({
    super.key,
    required this.liderController,
    required this.gestorController,
    required this.funcionariosSugeridos,
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
        ),
        const SizedBox(height: 16),
        CustomAutocompleteField(
          controller: gestorController,
          label: 'Gestor Direto',
          hint: 'Selecione o gestor',
          icon: Icons.manage_accounts_outlined,
          suggestions: funcionariosSugeridos,
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

  const StatusSection({
    super.key,
    required this.statusAtivo,
    required this.statusFerias,
    required this.dataRetornoFerias,
    required this.onStatusAtivoChanged,
    required this.onStatusFeriasChanged,
    required this.onSelectDateRetornoFerias,
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
        ),
        const SizedBox(height: 16),
        CustomSwitchField(
          value: statusFerias,
          onChanged: onStatusFeriasChanged,
          label: 'Status de Férias',
          activeText: 'Em Férias',
          inactiveText: 'Não está de férias',
          icon: Icons.beach_access_outlined,
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

  const TerminationSection({
    super.key,
    required this.dataDesligamentoController,
    required this.motivoDesligamentoController,
    required this.onSelectDateDesligamento,
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
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: motivoDesligamentoController,
          label: 'Motivo do Desligamento',
          hint: 'Digite o motivo',
          icon: Icons.description_outlined,
          maxLines: 3,
        ),
      ],
    );
  }
}