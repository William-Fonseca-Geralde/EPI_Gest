import 'package:flutter/material.dart';

class AddItemOverlay extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final TextEditingController controller;
  final Offset position;
  final Size buttonSize;
  final VoidCallback onAdd;
  final VoidCallback onCancel;

  const AddItemOverlay({
    super.key,
    required this.theme,
    required this.title,
    required this.controller,
    required this.position,
    required this.buttonSize,
    required this.onAdd,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const dropdownWidth = 450.0;
    const dropdownMaxHeight = 200.0;

    double left = position.dx;
    double? right;

    if (left + dropdownWidth > screenSize.width) {
      right = screenSize.width - (position.dx + buttonSize.width);
      left = screenSize.width - right - dropdownWidth;
    }

    double top = position.dy + buttonSize.height + 16;
    double? bottom;

    if (top + dropdownMaxHeight > screenSize.height) {
      bottom = screenSize.height - position.dy + 16;
      top = position.dy - dropdownMaxHeight - 16;
    }

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onCancel,
            child: Container(color: Colors.transparent),
          ),
        ),
        Positioned(
          left: left,
          right: right,
          top: bottom == null ? top : null,
          bottom: bottom,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: dropdownWidth,
              constraints: const BoxConstraints(maxHeight: dropdownMaxHeight),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: onCancel,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Digite o nome',
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          onSubmitted: (_) {
                            if (controller.text.trim().isNotEmpty) {
                              onAdd();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: () {
                          if (controller.text.trim().isNotEmpty) {
                            onAdd();
                          }
                        },
                        icon: const Icon(Icons.check),
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MultiSelectOverlay extends StatefulWidget {
  final ThemeData theme;
  final String title;
  final IconData icon;
  final Offset position;
  final Size buttonSize;
  final List<String> items;
  final List<String> selectedItems;
  final Function(List<String>) onChanged;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const MultiSelectOverlay({
    super.key,
    required this.theme,
    required this.title,
    required this.icon,
    required this.position,
    required this.buttonSize,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  State<MultiSelectOverlay> createState() => _MultiSelectOverlayState();
}

class _MultiSelectOverlayState extends State<MultiSelectOverlay> {
  late List<String> localSelectedItems;

  @override
  void initState() {
    super.initState();
    localSelectedItems = List.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const dropdownWidth = 450.0;
    const dropdownMaxHeight = 360.0;

    double left = widget.position.dx;
    double? right;

    if (left + dropdownWidth > screenSize.width) {
      right = screenSize.width - (widget.position.dx + widget.buttonSize.width);
      left = screenSize.width - right - dropdownWidth;
    }

    double top = widget.position.dy + widget.buttonSize.height + 8;
    double? bottom;

    if (top + dropdownMaxHeight > screenSize.height) {
      bottom = screenSize.height - widget.position.dy + 8;
      top = widget.position.dy - dropdownMaxHeight - 8;
    }

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onCancel,
            child: Container(color: Colors.transparent),
          ),
        ),
        Positioned(
          left: left,
          right: right,
          top: bottom == null ? top : null,
          bottom: bottom,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: dropdownWidth,
              constraints: const BoxConstraints(
                maxHeight: dropdownMaxHeight,
              ),
              decoration: BoxDecoration(
                color: widget.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  if (localSelectedItems.isNotEmpty) _buildCounter(),
                  _buildItemsList(),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            widget.icon,
            size: 20,
            color: widget.theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.title,
              style: widget.theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: widget.theme.colorScheme.primary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: widget.onCancel,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildCounter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      color: widget.theme.colorScheme.primaryContainer.withOpacity(0.3),
      child: Text(
        '${localSelectedItems.length} ${localSelectedItems.length == 1 ? 'item selecionado' : 'itens selecionados'}',
        style: widget.theme.textTheme.bodySmall?.copyWith(
          color: widget.theme.colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return Flexible(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.items.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final isSelected = localSelectedItems.contains(item);

          return CheckboxListTile(
            title: Text(
              item,
              style: widget.theme.textTheme.bodyMedium,
            ),
            value: isSelected,
            dense: true,
            activeColor: widget.theme.colorScheme.primary,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  localSelectedItems.add(item);
                } else {
                  localSelectedItems.remove(item);
                }
              });
              widget.onChanged(localSelectedItems);
            },
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border(
          top: BorderSide(
            color: widget.theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (localSelectedItems.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  localSelectedItems.clear();
                });
                widget.onChanged(localSelectedItems);
              },
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Limpar'),
              style: TextButton.styleFrom(
                foregroundColor: widget.theme.colorScheme.error,
              ),
            ),
          const Spacer(),
          TextButton(
            onPressed: widget.onCancel,
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: widget.onConfirm,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}