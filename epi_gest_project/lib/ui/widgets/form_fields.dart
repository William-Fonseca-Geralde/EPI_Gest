import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: !enabled,
        fillColor: enabled
            ? null
            : Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
    );
  }
}

class CustomDateField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const CustomDateField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: const Icon(Icons.event),
          onPressed: enabled ? onTap : null, // MODIFICADO
        ),
        filled: !enabled, // NOVO
        fillColor: enabled
            ? null
            : Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      readOnly: true,
      onTap: enabled ? onTap : null,
      style: TextStyle(
        color: enabled
            ? Theme.of(context).colorScheme.onSurface
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class CustomTimeField extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const CustomTimeField({
    super.key,
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.access_time_outlined,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            time.format(context),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class CustomAutocompleteField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final List<String> suggestions;
  final bool showAddButton;
  final VoidCallback? onAddPressed;
  final GlobalKey? addButtonKey;
  final bool enabled;

  const CustomAutocompleteField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.suggestions,
    this.showAddButton = false,
    this.onAddPressed,
    this.addButtonKey,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final String? currentValue =
        controller.text.isNotEmpty && suggestions.contains(controller.text)
        ? controller.text
        : null;

    final dropdownField = DropdownButtonFormField<String>(
      initialValue: currentValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: !enabled,
        fillColor: enabled
            ? null
            : Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      onChanged: enabled
          ? (String? newValue) {
              if (newValue != null) {
                controller.text = newValue;
              }
            }
          : null,
      items: suggestions.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      disabledHint: controller.text.isNotEmpty
          ? Text(
              controller.text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          : null,
    );

    if (!showAddButton) {
      return dropdownField;
    }

    return Row(
      children: [
        Expanded(child: dropdownField),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          key: addButtonKey,
          onPressed: enabled ? onAddPressed : null,
          icon: const Icon(Icons.add),
          tooltip: 'Adicionar novo',
        ),
      ],
    );
  }
}

class CustomMultiSelectField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final List<String> selectedItems;
  final GlobalKey buttonKey;
  final VoidCallback onTap;
  final bool enabled;

  const CustomMultiSelectField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.selectedItems,
    required this.buttonKey,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      key: buttonKey,
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
          color: enabled
              ? theme.colorScheme.surface
              : theme.colorScheme.surfaceContainerHighest,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedItems.isEmpty
                        ? hint
                        : '${selectedItems.length} ${selectedItems.length == 1 ? 'item selecionado' : 'itens selecionados'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: selectedItems.isEmpty
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.primary,
                      fontWeight: selectedItems.isEmpty
                          ? FontWeight.normal
                          : FontWeight.w500,
                    ),
                  ),
                  if (selectedItems.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildSelectedItemsChips(context, theme),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 24,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedItemsChips(BuildContext context, ThemeData theme) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children:
          selectedItems.take(3).map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          }).toList()..addAll(
            selectedItems.length > 3
                ? [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '+${selectedItems.length - 3}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ]
                : [],
          ),
    );
  }
}

class CustomSwitchField extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;
  final String label;
  final String activeText;
  final String inactiveText;
  final IconData icon;
  final bool enabled;

  const CustomSwitchField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    required this.activeText,
    required this.inactiveText,
    required this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        color: enabled ? null : theme.colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value ? activeText : inactiveText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: enabled ? onChanged : null),
        ],
      ),
    );
  }
}
