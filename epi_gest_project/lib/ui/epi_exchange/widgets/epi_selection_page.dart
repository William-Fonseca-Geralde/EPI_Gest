import 'package:flutter/material.dart';

class EPISelectionPage extends StatefulWidget {
  final Map<String, dynamic> employee;
  final VoidCallback onCloseDrawer;
  final Map<int, Map<String, dynamic>>? initialSelectedEPIs;
  final Function(Map<int, Map<String, dynamic>>) onSelectionChanged;

  const EPISelectionPage({
    super.key,
    required this.employee,
    required this.onSelectionChanged,
    required this.onCloseDrawer,
    this.initialSelectedEPIs,
  });

  @override
  State<EPISelectionPage> createState() => _EPISelectionPageState();
}

class _EPISelectionPageState extends State<EPISelectionPage> {
  late Map<int, Map<String, dynamic>> _selectedEPIs;

  final List<String> _reasons = [
    'Troca periódica (vencimento)',
    'Perda/Extraviou',
    'Danificado/Avaria',
    'Roubo/Furto',
    'Ajuste de tamanho',
    'Outros'
  ];

  @override
  void initState() {
    super.initState();
    _selectedEPIs = widget.initialSelectedEPIs ?? {};
  }

  void _notifyParent() {
    widget.onSelectionChanged(_selectedEPIs);
  }

  void _toggleEPISelection(int index, Map<String, dynamic> epi) {
    setState(() {
      if (_selectedEPIs.containsKey(index)) {
        _selectedEPIs.remove(index);
      } else {
        _selectedEPIs[index] = {
          'epi': epi,
          'quantity': 1,
          'reason': _reasons[0],
          'custom_reason': '',
        };
      }
    });
    _notifyParent();
  }

  void _updateQuantity(int index, int quantity) {
    setState(() {
      if (_selectedEPIs.containsKey(index)) {
        _selectedEPIs[index]!['quantity'] = quantity;
      }
    });
    _notifyParent();
  }

  void _updateReason(int index, String reason) {
    setState(() {
      if (_selectedEPIs.containsKey(index)) {
        _selectedEPIs[index]!['reason'] = reason;
      }
    });
    _notifyParent();
  }

  void _updateCustomReason(int index, String customReason) {
    setState(() {
      if (_selectedEPIs.containsKey(index)) {
        _selectedEPIs[index]!['custom_reason'] = customReason;
      }
    });
    _notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final epis = widget.employee['epis'] as List;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicador de progresso
          if (_selectedEPIs.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedEPIs.length} EPI${_selectedEPIs.length != 1 ? 's' : ''} selecionado${_selectedEPIs.length != 1 ? 's' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
      
          // Lista de EPIs
          Expanded(
            child: ListView.builder(
              itemCount: epis.length,
              itemBuilder: (context, index) {
                final epi = epis[index];
                final isSelected = _selectedEPIs.containsKey(index);
      
                return _EPISelectionCard(
                  epi: epi,
                  isSelected: isSelected,
                  onToggle: () => _toggleEPISelection(index, epi),
                  quantity: isSelected ? _selectedEPIs[index]!['quantity'] : 1,
                  onQuantityChanged: (qty) => _updateQuantity(index, qty),
                  reason: isSelected ? _selectedEPIs[index]!['reason'] : _reasons[0],
                  onReasonChanged: (reason) => _updateReason(index, reason),
                  customReason: isSelected ? _selectedEPIs[index]!['custom_reason'] : '',
                  onCustomReasonChanged: (custom) => _updateCustomReason(index, custom),
                  reasons: _reasons,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// _EPISelectionCard permanece o mesmo que o original
class _EPISelectionCard extends StatelessWidget {
  final Map<String, dynamic> epi;
  final bool isSelected;
  final VoidCallback onToggle;
  final int quantity;
  final Function(int) onQuantityChanged;
  final String reason;
  final Function(String) onReasonChanged;
  final String customReason;
  final Function(String) onCustomReasonChanged;
  final List<String> reasons;

  const _EPISelectionCard({
    required this.epi,
    required this.isSelected,
    required this.onToggle,
    required this.quantity,
    required this.onQuantityChanged,
    required this.reason,
    required this.onReasonChanged,
    required this.customReason,
    required this.onCustomReasonChanged,
    required this.reasons,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  int _getDaysUntilExpiry(DateTime expiryDate) {
    return expiryDate.difference(DateTime.now()).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpired = epi['status'] == 'expired';
    final daysUntilExpiry = _getDaysUntilExpiry(epi['expiryDate']);

    return Card(
      elevation: isSelected ? 4 : 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : (isExpired ? Colors.red.shade300 : Colors.orange.shade300),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 16,
                            color: theme.colorScheme.onPrimary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isExpired
                                    ? Colors.red.shade100
                                    : Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                isExpired
                                    ? Icons.error_outline
                                    : Icons.warning_amber_outlined,
                                color: isExpired
                                    ? Colors.red.shade700
                                    : Colors.orange.shade700,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                epi['name'],
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildInfoChip(
                              'CA: ${epi['ca']}',
                              Icons.badge_outlined,
                            ),
                            const SizedBox(width: 12),
                            _buildInfoChip(
                              'Venc: ${_formatDate(epi['expiryDate'])}',
                              Icons.calendar_today_outlined,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isExpired
                                ? Colors.red.shade600
                                : Colors.orange.shade600,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isExpired
                                ? 'Vencido há ${daysUntilExpiry.abs()} dias'
                                : 'Vence em $daysUntilExpiry dias',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isSelected) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildQuantitySelector(theme),
                const SizedBox(height: 16),
                _buildReasonSelector(theme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ],
    );
  }

  Widget _buildQuantitySelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantidade para troca:',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: quantity > 1
                    ? theme.colorScheme.primary
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.remove,
                  size: 16,
                  color: quantity > 1
                      ? theme.colorScheme.onPrimary
                      : Colors.grey.shade600,
                ),
                onPressed: quantity > 1
                    ? () => onQuantityChanged(quantity - 1)
                    : null,
                padding: EdgeInsets.zero,
              ),
            ),
            Container(
              width: 60,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: TextEditingController(text: quantity.toString()),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onChanged: (value) {
                  final newQuantity = int.tryParse(value);
                  if (newQuantity != null &&
                      newQuantity > 0 &&
                      newQuantity <= 100) {
                    onQuantityChanged(newQuantity);
                  }
                },
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.add,
                  size: 16,
                  color: theme.colorScheme.onPrimary,
                ),
                onPressed: () => onQuantityChanged(quantity + 1),
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Máx: 100',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [1, 2, 5, 10].map((suggestedQty) {
            return GestureDetector(
              onTap: () => onQuantityChanged(suggestedQty),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: quantity == suggestedQty
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: quantity == suggestedQty
                        ? theme.colorScheme.primary
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  suggestedQty.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: quantity == suggestedQty
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                    fontWeight: quantity == suggestedQty
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReasonSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Motivo da troca:',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: reason,
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: reasons.map((reason) {
            return DropdownMenuItem(value: reason, child: Text(reason));
          }).toList(),
          onChanged: (reason) => onReasonChanged(reason!),
        ),
        if (reason == 'Outros') ...[
          const SizedBox(height: 12),
          TextField(
            controller: TextEditingController(text: customReason),
            decoration: InputDecoration(
              labelText: 'Especifique o motivo',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: onCustomReasonChanged,
          ),
        ],
      ],
    );
  }
}