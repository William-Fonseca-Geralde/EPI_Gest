import 'package:flutter/material.dart';

class BuildEmpty extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String titleDrawer;
  final VoidCallback drawer;

  const BuildEmpty({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.titleDrawer,
    required this.drawer,
  });

  @override
  State<BuildEmpty> createState() => _BuildEmptyState();
}

class _BuildEmptyState extends State<BuildEmpty> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: FilledButton.icon(
                onPressed: widget.drawer,
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.add),
                label: Text(
                  widget.titleDrawer,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}