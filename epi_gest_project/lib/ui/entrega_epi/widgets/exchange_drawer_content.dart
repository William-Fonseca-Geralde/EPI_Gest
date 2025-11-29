import 'package:epi_gest_project/ui/entrega_epi/widgets/epi_form_page.dart';
import 'package:epi_gest_project/ui/widgets/base_drawer.dart';
import 'package:flutter/material.dart';
import 'epi_selection_page.dart';
import 'confirmation_page.dart';

enum ExchangeStep { selection, confirmation }

class ExchangeDrawerContent extends StatefulWidget {
  final Map<String, dynamic> employee;
  final VoidCallback onCloseDrawer;

  const ExchangeDrawerContent({
    super.key,
    required this.employee,
    required this.onCloseDrawer,
  });

  @override
  State<ExchangeDrawerContent> createState() => _ExchangeDrawerContentState();
}

class _ExchangeDrawerContentState extends State<ExchangeDrawerContent> {
  ExchangeStep _currentStep = ExchangeStep.selection;
  Map<int, Map<String, dynamic>> _selectedEPIs = {};
  
  final TextEditingController _authorizedByController = TextEditingController();
  final TextEditingController _observationsController = TextEditingController();

  @override
  void dispose() {
    _authorizedByController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  void _handleGenerateForm() {
    if (_authorizedByController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: Colors.white),
              SizedBox(width: 8),
              Text('Informe o nome do responsável'),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    widget.onCloseDrawer();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EPIFormPage(
          employee: widget.employee,
          selectedEPIs: _selectedEPIs,
          authorizedBy: _authorizedByController.text.trim(),
          observations: _observationsController.text.trim(),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    if (_currentStep == ExchangeStep.selection) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          border: Border(
            bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.checklist_outlined,
                color: theme.colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecionar EPIs para Troca',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.employee['name']} • ${widget.employee['registration']}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: widget.onCloseDrawer,
              icon: const Icon(Icons.close),
              tooltip: 'Fechar',
            ),
          ],
        ),
      );
    } else { // ExchangeStep.confirmation
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          border: Border(
            bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.verified_outlined,
                color: theme.colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirmar Troca de EPIs',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Revise os itens selecionados antes de gerar a ficha',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: widget.onCloseDrawer,
              icon: const Icon(Icons.close),
              tooltip: 'Fechar',
            ),
          ],
        ),
      );
    }
  }

  Widget _buildBody(ThemeData theme) {
    if (_currentStep == ExchangeStep.selection) {
      return EPISelectionPage(
        employee: widget.employee,
        initialSelectedEPIs: _selectedEPIs,
        onSelectionChanged: (selectedMap) {
          setState(() {
            _selectedEPIs = selectedMap;
          });
        },
        onCloseDrawer: widget.onCloseDrawer,
      );
    } else {
      return ConfirmationPage(
        employee: widget.employee,
        selectedEPIs: _selectedEPIs,
        authorizedByController: _authorizedByController,
        observationsController: _observationsController,
      );
    }
  }

  Widget _buildFooter(ThemeData theme) {
    if (_currentStep == ExchangeStep.selection) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: widget.onCloseDrawer,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  label: const Text('Cancelar'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: FilledButton.icon(
                  // Habilita apenas se houver seleção
                  onPressed: _selectedEPIs.isNotEmpty ? () {
                    setState(() {
                      _currentStep = ExchangeStep.confirmation;
                    });
                  } : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    'Continuar (${_selectedEPIs.length})',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _currentStep = ExchangeStep.selection;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  label: const Text('Voltar'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: FilledButton.icon(
                  // Agora chama a função local que tem acesso aos controladores
                  onPressed: _handleGenerateForm,
                  icon: const Icon(Icons.description_outlined),
                  label: const Text(
                    'Gerar Ficha de EPI',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BaseDrawer(
      onClose: widget.onCloseDrawer,
      header: _buildHeader(theme),
      body: _buildBody(theme),
      footer: _buildFooter(theme),
    );
  }
}