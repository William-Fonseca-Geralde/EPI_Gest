import 'package:epi_gest_project/domain/models/epi_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewEpiDrawer extends StatefulWidget {
  final EpiModel epi;
  final VoidCallback onClose;

  const ViewEpiDrawer({super.key, required this.epi, required this.onClose});

  @override
  State<ViewEpiDrawer> createState() => _ViewEpiDrawerState();
}

class _ViewEpiDrawerState extends State<ViewEpiDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
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
        // Overlay escuro
        GestureDetector(
          onTap: _closeDrawer,
          child: Container(color: Colors.black.withValues(alpha: 0.5)),
        ),

        // Painel lateral
        Align(
          alignment: Alignment.centerRight,
          child: SlideTransition(
            position: _slideAnimation,
            child: Material(
              elevation: 16,
              child: Container(
                width: size.width > 600 ? size.width * 0.45 : size.width * 0.85,
                height: size.height,
                color: theme.colorScheme.surface,
                child: Column(
                  children: [
                    // Cabeçalho
                    _buildHeader(theme),

                    // Conteúdo
                    Expanded(child: _buildContent(theme)),

                    // Rodapé
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
    // Determina cor e ícone do status
    Color statusColor;
    IconData statusIcon;
    String statusText = widget.epi.status;

    if (widget.epi.isVencido) {
      statusColor = theme.colorScheme.error;
      statusIcon = Icons.error_outline;
    } else if (widget.epi.isProximoVencimento) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning_amber_outlined;
    } else {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            spacing: 16,
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
              Expanded(
                child: Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visualizar EPI',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Informações do equipamento',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Status: $statusText',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final dateFormat = DateFormat('dd/MM/yyyy');

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Seção: Informações Básicas
        _buildSectionTitle('Informações Básicas', Icons.info_outline),
        const SizedBox(height: 16),

        // Imagem, CA, Validade e Nome
        Row(
          children: [
            // Container da Imagem (placeholder)
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sem imagem',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // CA, Validade e Nome
            Expanded(
              child: Column(
                spacing: 16,
                children: [
                  // Primeira linha: CA e Validade
                  Row(
                    spacing: 16,
                    children: [
                      Expanded(
                        child: _buildDisabledTextField(
                          label: 'CA',
                          value: widget.epi.ca,
                          icon: Icons.verified_outlined,
                        ),
                      ),
                      Expanded(
                        child: _buildDisabledTextField(
                          label: 'Validade',
                          value: dateFormat.format(widget.epi.dataValidade),
                          icon: Icons.calendar_today_outlined,
                        ),
                      ),
                    ],
                  ),
                  // Segunda linha: Nome do EPI
                  _buildDisabledTextField(
                    label: 'Nome do EPI',
                    value: widget.epi.nome,
                    icon: Icons.label_outline,
                  ),
                  // Categoria
                  _buildDisabledTextField(
                    label: 'Categoria',
                    value: widget.epi.categoria,
                    icon: Icons.category_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Seção: Fornecedor
        _buildSectionTitle('Fornecedor', Icons.business_outlined),
        const SizedBox(height: 16),

        _buildDisabledTextField(
          label: 'Fornecedor',
          value: widget.epi.fornecedor,
          icon: Icons.store_outlined,
        ),

        const SizedBox(height: 32),

        // Seção: Estoque e Valores
        _buildSectionTitle('Estoque e Valores', Icons.inventory_outlined),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildDisabledTextField(
                label: 'Quantidade',
                value: widget.epi.quantidadeEstoque.toString(),
                icon: Icons.numbers,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDisabledTextField(
                label: 'Valor Unitário',
                value: currencyFormat.format(widget.epi.valorUnitario),
                icon: Icons.attach_money,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDisabledTextField({
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

  Widget _buildFooter(ThemeData theme) {
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
