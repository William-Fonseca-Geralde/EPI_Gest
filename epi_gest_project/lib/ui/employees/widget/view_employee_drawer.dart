import 'package:epi_gest_project/ui/employees/widget/widgets_employee/employee_view_sections.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ViewEmployeeDrawer extends StatefulWidget {
  final Map<String, dynamic> employee;
  final VoidCallback onClose;

  const ViewEmployeeDrawer({
    super.key,
    required this.employee,
    required this.onClose,
  });

  @override
  State<ViewEmployeeDrawer> createState() => _ViewEmployeeDrawerState();
}

class _ViewEmployeeDrawerState extends State<ViewEmployeeDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _closeDrawer() async {
    await _animationController.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        GestureDetector(
          onTap: _closeDrawer,
          child: Container(color: Colors.black.withValues(alpha: 0.5)),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: SlideTransition(
            position: _slideAnimation,
            child: Material(
              elevation: 16,
              child: Container(
                width: size.width > 600 ? size.width * 0.6 : size.width * 0.9,
                height: size.height,
                color: theme.colorScheme.surface,
                child: Column(
                  children: [
                    _buildHeader(theme),
                    Expanded(child: _buildContent(theme)),
                    _buildFooter(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
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
              Icons.visibility,
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
                  'Visualizar Funcionário',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Informações do funcionário',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _closeDrawer,
            icon: const Icon(Icons.close),
            tooltip: 'Fechar',
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useTwoColumns = constraints.maxWidth > 700;
          return SingleChildScrollView(
            child: useTwoColumns
                ? _buildTwoColumnLayout(theme)
                : _buildSingleColumnLayout(theme),
          );
        },
      ),
    );
  }

  Widget _buildTwoColumnLayout(ThemeData theme) {
    final statusAtivo = widget.employee['statusAtivo'] as bool? ?? true;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Coluna Esquerda
        Expanded(
          child: Column(
            children: [
              _buildImageDisplay(theme),
              const SizedBox(height: 32),
              _buildSection(
                theme: theme,
                title: 'Documentos Pessoais',
                icon: Icons.assignment_outlined,
                child: DocumentsViewSection(
                  cpf: widget.employee['cpf'] as String?,
                  rg: widget.employee['rg'] as String?,
                  dataNascimento: widget.employee['dataNascimento'] as DateTime?,
                ),
              ),
              const SizedBox(height: 32),
              _buildSection(
                theme: theme,
                title: 'Contato',
                icon: Icons.contact_phone_outlined,
                child: ContactViewSection(
                  telefone: widget.employee['telefone'] as String?,
                  email: widget.employee['email'] as String?,
                ),
              ),
              const SizedBox(height: 32),
              _buildSection(
                theme: theme,
                title: 'Hierarquia',
                icon: Icons.people_outline,
                child: HierarchyViewSection(
                  lider: widget.employee['lider'] as String?,
                  gestor: widget.employee['gestor'] as String?,
                ),
              ),
              if (!statusAtivo) ...[
                const SizedBox(height: 32),
                _buildSection(
                  theme: theme,
                  title: 'Desligamento',
                  icon: Icons.logout_outlined,
                  child: TerminationViewSection(
                    dataDesligamento:
                        widget.employee['dataDesligamento'] as DateTime?,
                    motivoDesligamento:
                        widget.employee['motivoDesligamento'] as String?,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: 24),

        // Coluna Direita
        Expanded(
          child: Column(
            children: [
              _buildSection(
                theme: theme,
                title: 'Informações Básicas',
                icon: Icons.info_outlined,
                child: BasicInfoViewSection(
                  id: widget.employee['id'] as String? ?? '',
                  matricula: widget.employee['matricula'] as String? ?? '',
                  nome: widget.employee['nome'] as String? ?? '',
                  dataEntrada: widget.employee['dataEntrada'] as DateTime?,
                ),
              ),
              const SizedBox(height: 32),
              _buildSection(
                theme: theme,
                title: 'Cargo e Setor',
                icon: Icons.work_outline,
                child: JobViewSection(
                  setor: widget.employee['setor'] as String?,
                  funcao: widget.employee['funcao'] as String?,
                  vinculo: widget.employee['vinculo'] as String?,
                ),
              ),
              const SizedBox(height: 32),
              _buildSection(
                theme: theme,
                title: 'Condições de Trabalho',
                icon: Icons.settings_outlined,
                child: WorkConditionsViewSection(
                  localTrabalho: widget.employee['localTrabalho'] as String?,
                  turno: widget.employee['turno'] as String?,
                  epis: widget.employee['epis'] as List<String>?,
                  riscos: widget.employee['riscos'] as List<String>?,
                ),
              ),
              const SizedBox(height: 32),
              _buildSection(
                theme: theme,
                title: 'Status',
                icon: Icons.info_outlined,
                child: StatusViewSection(
                  statusAtivo: statusAtivo,
                  statusFerias: widget.employee['statusFerias'] as bool? ?? false,
                  dataRetornoFerias:
                      widget.employee['dataRetornoFerias'] as DateTime?,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleColumnLayout(ThemeData theme) {
    final statusAtivo = widget.employee['statusAtivo'] as bool? ?? true;

    return Column(
      children: [
        _buildImageDisplay(theme),
        const SizedBox(height: 32),
        _buildSection(
          theme: theme,
          title: 'Informações Básicas',
          icon: Icons.info_outlined,
          child: BasicInfoViewSection(
            id: widget.employee['id'] as String? ?? '',
            matricula: widget.employee['matricula'] as String? ?? '',
            nome: widget.employee['nome'] as String? ?? '',
            dataEntrada: widget.employee['dataEntrada'] as DateTime?,
          ),
        ),
        const SizedBox(height: 32),
        _buildSection(
          theme: theme,
          title: 'Documentos Pessoais',
          icon: Icons.assignment_outlined,
          child: DocumentsViewSection(
            cpf: widget.employee['cpf'] as String?,
            rg: widget.employee['rg'] as String?,
            dataNascimento: widget.employee['dataNascimento'] as DateTime?,
          ),
        ),
        const SizedBox(height: 32),
        _buildSection(
          theme: theme,
          title: 'Contato',
          icon: Icons.contact_phone_outlined,
          child: ContactViewSection(
            telefone: widget.employee['telefone'] as String?,
            email: widget.employee['email'] as String?,
          ),
        ),
        const SizedBox(height: 32),
        _buildSection(
          theme: theme,
          title: 'Cargo e Setor',
          icon: Icons.work_outline,
          child: JobViewSection(
            setor: widget.employee['setor'] as String?,
            funcao: widget.employee['funcao'] as String?,
            vinculo: widget.employee['vinculo'] as String?,
          ),
        ),
        const SizedBox(height: 32),
        _buildSection(
          theme: theme,
          title: 'Condições de Trabalho',
          icon: Icons.settings_outlined,
          child: WorkConditionsViewSection(
            localTrabalho: widget.employee['localTrabalho'] as String?,
            turno: widget.employee['turno'] as String?,
            epis: widget.employee['epis'] as List<String>?,
            riscos: widget.employee['riscos'] as List<String>?,
          ),
        ),
        const SizedBox(height: 32),
        _buildSection(
          theme: theme,
          title: 'Hierarquia',
          icon: Icons.people_outline,
          child: HierarchyViewSection(
            lider: widget.employee['lider'] as String?,
            gestor: widget.employee['gestor'] as String?,
          ),
        ),
        const SizedBox(height: 32),
        _buildSection(
          theme: theme,
          title: 'Status',
          icon: Icons.info_outlined,
          child: StatusViewSection(
            statusAtivo: statusAtivo,
            statusFerias: widget.employee['statusFerias'] as bool? ?? false,
            dataRetornoFerias: widget.employee['dataRetornoFerias'] as DateTime?,
          ),
        ),
        if (!statusAtivo) ...[
          const SizedBox(height: 32),
          _buildSection(
            theme: theme,
            title: 'Desligamento',
            icon: Icons.logout_outlined,
            child: TerminationViewSection(
              dataDesligamento: widget.employee['dataDesligamento'] as DateTime?,
              motivoDesligamento:
                  widget.employee['motivoDesligamento'] as String?,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageDisplay(ThemeData theme) {
    final imagePath = widget.employee['imagem'] as String?;
    final hasImage = imagePath != null && File(imagePath).existsSync();

    return Container(
      width: 300,
      height: 250,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 2,
        ),
      ),
      child: hasImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(imagePath),
                width: 300,
                height: 250,
                fit: BoxFit.cover,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sem foto',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _closeDrawer,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Fechar'),
            ),
          ),
        ],
      ),
    );
  }
}
