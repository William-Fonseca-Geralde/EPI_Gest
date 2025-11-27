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
  final String time;
  final VoidCallback onTap;
  final bool enabled;

  const CustomTimeField({
    super.key,
    required this.label,
    required this.time,
    required this.onTap,
    required this.enabled,
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
        enabled: enabled,
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
            time,
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

  // Novos parâmetros para o botão de adicionar
  final bool showAddButton;
  final VoidCallback? onAddPressed;
  final GlobalKey? addButtonKey;

  const CustomMultiSelectField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.selectedItems,
    required this.buttonKey,
    required this.onTap,
    this.enabled = true,
    this.showAddButton = false,
    this.onAddPressed,
    this.addButtonKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final fieldWidget = GestureDetector(
      key: buttonKey,
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(
          12,
        ), // Padding reduzido para alinhar melhor
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
          color: enabled
              ? theme.colorScheme.surface
              : theme.colorScheme.surfaceContainerHighest,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 24,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            if (selectedItems.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildSelectedItemsChips(context, theme),
            ] else ...[
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 32),
                child: Text(
                  hint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (!showAddButton) return fieldWidget;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: fieldWidget),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 4), // Pequeno ajuste visual
          child: IconButton.filledTonal(
            key: addButtonKey,
            onPressed: enabled ? onAddPressed : null,
            icon: const Icon(Icons.add),
            tooltip: 'Adicionar novo',
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16), // Tamanho maior para alinhar
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedItemsChips(BuildContext context, ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: selectedItems.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// --- NOVO WIDGET: Dialog de Seleção Múltipla com Busca ---
class MultiSelectSearchDialog extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<String> selectedItems;

  const MultiSelectSearchDialog({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItems,
  });

  @override
  State<MultiSelectSearchDialog> createState() =>
      _MultiSelectSearchDialogState();
}

class _MultiSelectSearchDialogState extends State<MultiSelectSearchDialog> {
  late List<String> _tempSelectedItems;
  late List<String> _filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tempSelectedItems = List.from(widget.selectedItems);
    _filteredItems = List.from(widget.items);
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest
                    .withOpacity(0.3),
              ),
              onChanged: _filterItems,
            ),
            const SizedBox(height: 12),

            // List
            Expanded(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum item encontrado',
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isSelected = _tempSelectedItems.contains(item);

                        return CheckboxListTile(
                          title: Text(item),
                          value: isSelected,
                          activeColor: theme.colorScheme.primary,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _tempSelectedItems.add(item);
                              } else {
                                _tempSelectedItems.remove(item);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),

            const SizedBox(height: 16),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context, _tempSelectedItems);
                  },
                  child: Text('Confirmar (${_tempSelectedItems.length})'),
                ),
              ],
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: value ? theme.colorScheme.primary : theme.colorScheme.outline),
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
                    color: value ? Colors.green : Colors.red,
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

class CustomSearchField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;
  final IconData? icon;
  final String? Function(String?)? validator;
  final bool isRequired;

  const CustomSearchField({
    super.key,
    required this.label,
    required this.controller,
    required this.onTap,
    this.icon = Icons.search,
    this.validator,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isRequired)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ),
          ),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          validator:
              validator ??
              (value) {
                if (isRequired && (value == null || value.isEmpty)) {
                  return 'Campo obrigatório';
                }
                return null;
              },
          decoration: InputDecoration(
            labelText: isRequired ? null : label,
            hintText: 'Selecione $label',
            suffixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
          ),
        ),
      ],
    );
  }
}
