import 'package:epi_gest_project/ui/epi_exchange/widgets/exchange_drawer_content.dart';
import 'package:flutter/material.dart';

class ExchangePage extends StatefulWidget {
  const ExchangePage({super.key});

  @override
  State<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  String _selectedFilter = 'Todos';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<Widget?> _drawerContentNotifier = ValueNotifier<Widget?>(null);

  final List<Map<String, dynamic>> _employees = [
    {
      'name': 'Roberto Guedes',
      'registration': '0001',
      'department': 'Produção',
      'position': 'Operador de Máquinas',
      'epis': [
        {
          'name': 'Capacete de Segurança',
          'ca': '12345',
          'expiryDate': DateTime.now().subtract(const Duration(days: 5)),
          'status': 'expired',
        },
        {
          'name': 'Luvas de Proteção',
          'ca': '67890',
          'expiryDate': DateTime.now().add(const Duration(days: 10)),
          'status': 'expiring',
        },
        {
          'name': 'Protetor Auricular Concha',
          'ca': '27584',
          'expiryDate': DateTime.now().add(const Duration(days: 13)),
          'status': 'expiring',
        },
      ],
    },
    {
      'name': 'Wesley Kilian',
      'registration': '0002',
      'department': 'Manutenção',
      'position': 'Eletricista',
      'epis': [
        {
          'name': 'Botina de Segurança',
          'ca': '11111',
          'expiryDate': DateTime.now().subtract(const Duration(days: 15)),
          'status': 'expired',
        },
        {
          'name': 'Óculos de Proteção',
          'ca': '22222',
          'expiryDate': DateTime.now().subtract(const Duration(days: 2)),
          'status': 'expired',
        },
        {
          'name': 'Protetor Auricular Plug',
          'ca': '18189',
          'expiryDate': DateTime.now().subtract(const Duration(days: 8)),
          'status': 'expired',
        },
      ],
    },
    {
      'name': 'William Geralde',
      'registration': '0003',
      'department': 'Logística',
      'position': 'Operador de Empilhadeira',
      'epis': [
        {
          'name': 'Protetor Auricular',
          'ca': '33333',
          'expiryDate': DateTime.now().add(const Duration(days: 7)),
          'status': 'expiring',
        },
      ],
    },
    {
      'name': 'Valdir de Jesus',
      'registration': '0004',
      'department': 'Produção',
      'position': 'Operador de Linha',
      'epis': [
        {
          'name': 'Máscara PFF2',
          'ca': '44444',
          'expiryDate': DateTime.now().add(const Duration(days: 5)),
          'status': 'expiring',
        },
        {
          'name': 'Luvas Nitrílicas',
          'ca': '55555',
          'expiryDate': DateTime.now().subtract(const Duration(days: 8)),
          'status': 'expired',
        },
      ],
    },
  ];

  List<Map<String, dynamic>> get _filteredEmployees {
    return _employees.where((employee) {
      // Filtro de busca
      final matchesSearch =
          _searchQuery.isEmpty ||
          employee['name'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          employee['registration'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          employee['department'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      if (!matchesSearch) return false;

      // Filtro de status
      if (_selectedFilter == 'Todos') return true;

      final hasExpired = (employee['epis'] as List).any(
        (epi) => epi['status'] == 'expired',
      );
      final hasExpiring = (employee['epis'] as List).any(
        (epi) => epi['status'] == 'expiring',
      );

      if (_selectedFilter == 'Vencidos') return hasExpired;
      if (_selectedFilter == 'A Vencer') return hasExpiring;

      return true;
    }).toList();
  }

  int get _totalExpired {
    int count = 0;
    for (var employee in _employees) {
      count += (employee['epis'] as List)
          .where((epi) => epi['status'] == 'expired')
          .length;
    }
    return count;
  }

  int get _totalExpiring {
    int count = 0;
    for (var employee in _employees) {
      count += (employee['epis'] as List)
          .where((epi) => epi['status'] == 'expiring')
          .length;
    }
    return count;
  }

  // CORREÇÃO: Simplificado para usar ExchangeDrawerContent
  void _openEPISelectionDrawer(Map<String, dynamic> employee) {
    _drawerContentNotifier.value = ExchangeDrawerContent(
      employee: employee,
      onCloseDrawer: () => _drawerContentNotifier.value = null,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _drawerContentNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Stack(
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.08),
                    colorScheme.surface.withValues(alpha: 0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  topLeft: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.swap_horiz,
                          color: theme.colorScheme.onPrimaryContainer,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Troca de EPIs',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'Gerencie as trocas de EPIs vencidos ou próximos do vencimento',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'Todos',
                        label: Text('Todos'),
                        icon: Icon(Icons.list, size: 18),
                      ),
                      ButtonSegment(
                        value: 'Vencidos',
                        label: Text('Vencidos'),
                        icon: Icon(Icons.error_outline, size: 18),
                      ),
                      ButtonSegment(
                        value: 'A Vencer',
                        label: Text('A Vencer'),
                        icon: Icon(Icons.warning_amber_outlined, size: 18),
                      ),
                    ],
                    selected: {_selectedFilter},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedFilter = newSelection.first;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'EPIs Vencidos',
                            value: _totalExpired.toString(),
                            icon: Icons.error_outline,
                            color: Colors.red,
                            backgroundColor: Colors.red.shade50,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _SummaryCard(
                            title: 'EPIs a Vencer (15 dias)',
                            value: _totalExpiring.toString(),
                            icon: Icons.warning_amber_outlined,
                            color: Colors.orange,
                            backgroundColor: Colors.orange.shade50,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Funcionários Afetados',
                            value: _filteredEmployees.length.toString(),
                            icon: Icons.people_outline,
                            color: colorScheme.primary,
                            backgroundColor: colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Buscar por nome, matrícula ou setor...',
                                prefixIcon: const Icon(Icons.search, size: 20),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 20),
                                        onPressed: () {
                                          setState(() {
                                            _searchController.clear();
                                            _searchQuery = '';
                                          });
                                        },
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Expanded(
                      child: _filteredEmployees.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Nenhum funcionário encontrado',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tente ajustar os filtros ou a busca',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: _filteredEmployees.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final employee = _filteredEmployees[index];
                                return _EmployeeCard(
                                  employee: employee,
                                  onRegisterExchange: _openEPISelectionDrawer,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ValueListenableBuilder<Widget?>(
          valueListenable: _drawerContentNotifier,
          builder: (context, drawerContent, child) {
            if (drawerContent == null) {
              return const SizedBox.shrink();
            }
            return drawerContent;
          },
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final Map<String, dynamic> employee;
  final Function(Map<String, dynamic>) onRegisterExchange;

  const _EmployeeCard({required this.employee, required this.onRegisterExchange});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final epis = employee['epis'] as List;

    final hasExpired = epis.any((epi) => epi['status'] == 'expired');
    final expiredCount = epis.where((epi) => epi['status'] == 'expired').length;
    final expiringCount = epis
        .where((epi) => epi['status'] == 'expiring')
        .length;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: hasExpired ? Colors.red.shade500 : Colors.orange.shade500,
          width: 1.5,
        ),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: hasExpired
              ? Colors.red.shade100
              : Colors.orange.shade100,
          child: Text(
            employee['name'].toString().substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: hasExpired ? Colors.red.shade700 : Colors.orange.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee['name'],
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mat: ${employee['registration']} • ${employee['position']}',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Icon(Icons.business_outlined, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(employee['department'], style: textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              )),
              const SizedBox(width: 16),
              if (expiredCount > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error, size: 12, color: Colors.red.shade700),
                      const SizedBox(width: 4),
                      Text(
                        '$expiredCount vencido${expiredCount > 1 ? 's' : ''}',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (expiringCount > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber,
                        size: 12,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$expiringCount a vencer',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        // CORREÇÃO: Uso direto do callback
        trailing: FilledButton.icon(
          onPressed: () => onRegisterExchange(employee),
          icon: const Icon(Icons.swap_horiz, size: 18),
          label: const Text('Registrar Troca'),
          style: FilledButton.styleFrom(
            backgroundColor: hasExpired
                ? Colors.red.shade600
                : Colors.orange.shade600,
          ),
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EPIs que necessitam troca:',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...epis.map((epi) => _EpiItem(epi: epi)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EpiItem extends StatelessWidget {
  final Map<String, dynamic> epi;

  const _EpiItem({required this.epi});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  int _getDaysUntilExpiry(DateTime expiryDate) {
    return expiryDate.difference(DateTime.now()).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isExpired = epi['status'] == 'expired';
    final daysUntilExpiry = _getDaysUntilExpiry(epi['expiryDate']);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isExpired ? Colors.red.shade700 : Colors.orange.shade700,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              isExpired ? Icons.error : Icons.warning_amber,
              color: isExpired ? Colors.red.shade700 : Colors.orange.shade700,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    epi['name'],
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('CA: ${epi['ca']}', style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      )),
                      const SizedBox(width: 16),
                      Text(
                        'Vencimento: ${_formatDate(epi['expiryDate'])}',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isExpired ? Colors.red.shade700 : Colors.orange.shade700,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                isExpired
                    ? 'Vencido há ${daysUntilExpiry.abs()} dia${daysUntilExpiry.abs() > 1 ? 's' : ''}'
                    : 'Vence em $daysUntilExpiry dia${daysUntilExpiry > 1 ? 's' : ''}',
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}