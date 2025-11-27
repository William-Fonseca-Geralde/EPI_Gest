import 'package:flutter/material.dart';

class BaseDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final Widget header;
  final Widget body;
  final Widget footer;
  final double? widthFactor;

  const BaseDrawer({
    super.key,
    required this.onClose,
    required this.header,
    required this.body,
    required this.footer,
    this.widthFactor,
  });

  @override
  State<BaseDrawer> createState() => _BaseDrawerState();
}

class _BaseDrawerState extends State<BaseDrawer>
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

    final double drawerWidth = widget.widthFactor != null
        ? size.width * widget.widthFactor!
        : (size.width > 600 ? size.width * 0.6 : size.width * 0.9);

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
                width: drawerWidth,
                height: size.height,
                color: theme.colorScheme.surface,
                child: Column(
                  children: [
                    // Header customizável
                    widget.header,
                    // Corpo principal que pode rolar
                    Expanded(child: widget.body),
                    // Footer customizável
                    widget.footer,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BaseAddDrawer extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onClose;
  final Future<void> Function() onSave;
  final Widget child;
  final GlobalKey<FormState> formKey;
  final bool isEditing;
  final bool isViewing;
  final bool isSaving;
  final double? widthFactor;

  const BaseAddDrawer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onClose,
    required this.onSave,
    required this.child,
    required this.formKey,
    this.isEditing = false,
    this.isViewing = false,
    required this.isSaving,
    this.widthFactor,
  });

  @override
  State<BaseAddDrawer> createState() => _BaseAddDrawerState();
}

class _BaseAddDrawerState extends State<BaseAddDrawer> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseDrawer(
      onClose: widget.onClose,
      widthFactor: widget.widthFactor,

      // --- HEADER ---
      header: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          border: Border(
            bottom: BorderSide(color: theme.colorScheme.outlineVariant),
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
                widget.icon,
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
                    widget.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: widget.onClose,
              icon: const Icon(Icons.close),
              tooltip: 'Fechar',
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),

      // --- BODY ---
      body: Form(key: widget.formKey, child: widget.child),

      // --- FOOTER ---
      footer: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          spacing: 16,
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: widget.isSaving ? null : widget.onClose,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface,
                    side: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  label: Text(widget.isViewing ? "Fechar" : "Cancelar"),
                ),
              ),
            ),
            ?widget.isViewing
                ? null
                : Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: widget.isSaving ? null : widget.onSave,
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(
                          widget.isEditing ? Icons.save_outlined : Icons.add,
                          size: 18,
                        ),
                        label: widget.isSaving
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              )
                            : Text(
                                widget.isEditing
                                    ? "Salvar Alterações"
                                    : "Adicionar",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
