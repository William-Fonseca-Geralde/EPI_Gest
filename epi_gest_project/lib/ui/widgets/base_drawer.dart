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
                    Expanded(
                      child: widget.body,
                    ),
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
