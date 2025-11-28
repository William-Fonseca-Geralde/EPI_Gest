import 'package:epi_gest_project/data/services/funcionarios/funcionario_repository.dart';
import 'package:epi_gest_project/data/services/funcionarios/mapeamento_funcionario_repository.dart';
import 'package:epi_gest_project/domain/models/epi_model.dart';
import 'package:epi_gest_project/domain/models/funcionarios/funcionario_model.dart';
import 'package:epi_gest_project/domain/models/organizational_structure/mapeamento_epi_model.dart';
import 'package:epi_gest_project/ui/gestao_epi/widgets/exchange_drawer_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExchangePage extends StatefulWidget {
  const ExchangePage({super.key});

  @override
  State<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  // Estado de Dados
  List<FuncionarioModel> _allEmployees = [];
  List<FuncionarioModel> _filteredEmployees = [];
  Map<String, MapeamentoEpiModel> _employeeMappings = {};

  // Estado de UI
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Filtros
  String _selectedFilter = 'Todos'; // Todos, Com Pendência, Sem Mapeamento

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final funcRepo = Provider.of<FuncionarioRepository>(
        context,
        listen: false,
      );
      final mapFuncRepo = Provider.of<MapeamentoFuncionarioRepository>(
        context,
        listen: false,
      );

      // Carregamento paralelo para performance
      final results = await Future.wait([
        funcRepo.getAllActivatedFuncionarios(),
        mapFuncRepo.getAllRelations(),
      ]);

      final employees = results[0] as List<FuncionarioModel>;
      final relations = results[1]; // MapeamentoFuncionarioModel list

      // Criar mapa de fácil acesso: FuncionarioID -> MapeamentoEpi
      final Map<String, MapeamentoEpiModel> mappingsMap = {};

      // Assumindo que 'relations' é List<MapeamentoFuncionarioModel>
      // Ajuste conforme o retorno real do seu getAllRelations
      for (var relation in (relations as List<dynamic>)) {
        // Verifica se os objetos relacionados foram carregados corretamente
        if (relation.funcionario.id != null) {
          mappingsMap[relation.funcionario.id!] = relation.mapeamento;
        }
      }

      if (mounted) {
        setState(() {
          _allEmployees = employees;
          _filteredEmployees = employees;
          _employeeMappings = mappingsMap;
          _isLoading = false;
        });
        _applyFilters();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredEmployees = _allEmployees.where((employee) {
        // 1. Filtro de Texto
        final searchLower = _searchQuery.toLowerCase();
        final matchesSearch =
            _searchQuery.isEmpty ||
            employee.nomeFunc.toLowerCase().contains(searchLower) ||
            employee.matricula.contains(searchLower);

        if (!matchesSearch) return false;

        // 2. Filtro de Categoria/Status
        if (_selectedFilter == 'Sem Mapeamento') {
          return !_employeeMappings.containsKey(employee.id);
        }

        // Futuro: Implementar filtro 'Com Pendência' baseado em FichaEpi

        return true;
      }).toList();
    });
  }

  void _openDeliveryDrawer(FuncionarioModel employee) {
    final mapping = _employeeMappings[employee.id];

    if (mapping == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Este funcionário não possui mapeamento de EPI definido.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Prepara os dados para o Drawer
    // Convertendo para o formato Map<String, dynamic> esperado pelo widget legado
    // TODO: Refatorar ExchangeDrawerContent para aceitar Models diretamente na próxima etapa
    final employeeMap = {
      'name': employee.nomeFunc,
      'registration': employee.matricula,
      'department': mapping.setor.nomeSetor,
      'position': mapping.cargo.nomeCargo,
      'id': employee.id,
      // Passamos os EPIs do Mapeamento como "epis" disponíveis
      'epis': mapping.epis
          .map(
            (epi) => {
              'id': epi.id,
              'name': epi.nomeProduto,
              'ca': epi.ca,
              'validadeCA': epi.validadeCa,
              'estoque': epi.estoque,
              // Status fictício por enquanto, será substituído pela lógica de histórico
              'status': 'available',
              'expiryDate': DateTime.now().add(Duration(days: 30)),
            },
          )
          .toList(),
    };

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Registrar Entrega',
      pageBuilder: (context, _, __) => ExchangeDrawerContent(
        employee: employeeMap,
        onCloseDrawer: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        _buildHeader(theme, colorScheme),
        const Divider(height: 1),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(theme),
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Container(
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
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.back_hand_rounded, // Ícone de entrega
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Entrega de EPIs',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'Gerencie as entregas baseadas no mapeamento de risco',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Atualizar Lista'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_filteredEmployees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'Nenhum funcionário encontrado',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        spacing: 12,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar funcionário (Nome ou Matrícula)...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredEmployees.length,
              itemBuilder: (context, index) {
                final employee = _filteredEmployees[index];
                final mapping = _employeeMappings[employee.id];
            
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _EmployeeDeliveryCard(
                    employee: employee,
                    mapping: mapping,
                    onDeliver: () => _openDeliveryDrawer(employee),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeDeliveryCard extends StatelessWidget {
  final FuncionarioModel employee;
  final MapeamentoEpiModel? mapping;
  final VoidCallback onDeliver;

  const _EmployeeDeliveryCard({
    required this.employee,
    this.mapping,
    required this.onDeliver,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasMapping = mapping != null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: hasMapping
              ? colorScheme.outlineVariant
              : Colors.orange.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        leading: CircleAvatar(
          backgroundColor: hasMapping
              ? colorScheme.primaryContainer
              : Colors.orange.shade100,
          child: Text(
            employee.nomeFunc.isNotEmpty
                ? employee.nomeFunc[0].toUpperCase()
                : '?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: hasMapping
                  ? colorScheme.onPrimaryContainer
                  : Colors.orange.shade900,
            ),
          ),
        ),
        title: Text(
          employee.nomeFunc,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Mat: ${employee.matricula} • ${hasMapping ? mapping!.setor.nomeSetor : 'Sem Setor Vinculado'}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: FilledButton.icon(
          onPressed: hasMapping ? onDeliver : null,
          icon: const Icon(Icons.inventory, size: 18),
          label: const Text('Realizar Entrega'),
          style: FilledButton.styleFrom(
            backgroundColor: hasMapping ? null : theme.disabledColor,
          ),
        ),
        children: [
          if (hasMapping)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLowest,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.checklist,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Requisitos do Mapeamento (${mapping!.nomeMapeamento})',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: mapping!.epis
                        .map((epi) => _buildEpiChip(context, epi))
                        .toList(),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Funcionário sem mapeamento de EPI vinculado.',
                    style: TextStyle(color: Colors.orange.shade800),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEpiChip(BuildContext context, EpiModel epi) {
    final theme = Theme.of(context);
    final hasStock = epi.estoque > 0;
    final isCritical = epi.estoque <= epi.periodicidade; // Exemplo de regra

    Color chipColor;
    if (!hasStock) {
      chipColor = theme.colorScheme.errorContainer;
    } else if (isCritical) {
      chipColor = Colors.orange.shade100;
    } else {
      chipColor = theme.colorScheme.surfaceContainerHigh;
    }

    return Tooltip(
      message: 'CA: ${epi.ca} | Estoque: ${epi.estoque}',
      child: Chip(
        avatar: CircleAvatar(
          backgroundColor: hasStock ? Colors.green : Colors.red,
          radius: 6,
        ),
        label: Text(epi.nomeProduto, style: theme.textTheme.bodySmall),
        backgroundColor: chipColor,
        side: BorderSide.none,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}
