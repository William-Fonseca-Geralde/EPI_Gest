import 'package:epi_gest_project/data/services/organizational_structure/cargo_repository.dart';
import 'package:epi_gest_project/data/services/product_technical_registration/categoria_repository.dart';
import 'package:epi_gest_project/data/services/organizational_structure/mapeamento_epi_repository.dart';
import 'package:epi_gest_project/data/services/mapeamento_funcionario_repository.dart';
import 'package:epi_gest_project/data/services/organizational_structure/riscos_repository.dart';
import 'package:epi_gest_project/data/services/organizational_structure/setor_repository.dart';
import 'package:epi_gest_project/domain/models/cargo_model.dart';
import 'package:epi_gest_project/domain/models/categoria_model.dart';
import 'package:epi_gest_project/domain/models/mapeamento_epi_model.dart';
import 'package:epi_gest_project/domain/models/riscos_model.dart';
import 'package:epi_gest_project/domain/models/setor_model.dart';
import 'package:epi_gest_project/ui/widgets/builds_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'epi_mapping_drawer.dart';

class EpiMapingWidget extends StatefulWidget {
  const EpiMapingWidget({super.key});

  @override
  State<EpiMapingWidget> createState() => EpiMapingWidgetState();
}

class EpiMapingWidgetState extends State<EpiMapingWidget> {
  List<MapeamentoEpiModel> _mapeamentos = [];
  List<MapeamentoEpiModel> _filteredMapeamentos = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _error;

  List<SetorModel> _availableSectors = [];
  List<CargoModel> _availableRoles = [];
  List<RiscosModel> _availableRisks = [];
  List<CategoriaModel> _availableCategories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final mapRepo = Provider.of<MapeamentoEpiRepository>(
        context,
        listen: false,
      );
      final setorRepo = Provider.of<SetorRepository>(context, listen: false);
      final cargoRepo = Provider.of<CargoRepository>(context, listen: false);
      final riscoRepo = Provider.of<RiscosRepository>(context, listen: false);
      final catRepo = Provider.of<CategoriaRepository>(context, listen: false);

      final results = await Future.wait([
        mapRepo.getAllMapeamentos(),
        setorRepo.getAllSetores(),
        cargoRepo.getAllCargos(),
        riscoRepo.getAllRiscos(),
        catRepo.getAllCategorias(),
      ]);

      if (mounted) {
        setState(() {
          _mapeamentos = results[0] as List<MapeamentoEpiModel>;
          _availableSectors = results[1] as List<SetorModel>;
          _availableRoles = results[2] as List<CargoModel>;
          _availableRisks = results[3] as List<RiscosModel>;
          _availableCategories = results[4] as List<CategoriaModel>;
          _filteredMapeamentos = _mapeamentos;

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Erro ao carregar dados: $e';
        });
      }
    }
  }

  void showAddDrawer() {
    _showMapingDrawer();
  }

  void _showMapingDrawer({MapeamentoEpiModel? mapping, bool viewOnly = false}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Gerenciar Mapeamento',
      pageBuilder: (context, _, __) => EpiMappingDrawer(
        mappingToEdit: mapping,
        view: viewOnly,
        onClose: () => Navigator.of(context).pop(),
        onSave: (_) => _loadData(),
        availableSectors: _availableSectors,
        availableRoles: _availableRoles,
        availableRisks: _availableRisks,
        availableCategories: _availableCategories,
      ),
    );
  }

  Future<void> _toggleStatus(MapeamentoEpiModel map) async {
    final repo = Provider.of<MapeamentoEpiRepository>(context, listen: false);
    final vinculoRepo = Provider.of<MapeamentoFuncionarioRepository>(
      context,
      listen: false,
    );

    if (!map.status) {
      try {
        await repo.ativarMapeamento(map.id!);
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mapeamento ativado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        _showErrorSnackBar('Erro ao ativar: $e');
      }
      return;
    }

    try {
      final count = await vinculoRepo.countByMapeamentoId(map.id!);

      if (!mounted) return;

      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _InactivationDialog(
          mapeamentoName: map.nomeMapeamento,
          affectedCount: count,
          availableMappings: _mapeamentos
              .where((m) => m.id != map.id && m.status)
              .toList(),
        ),
      );

      if (result != null && result['confirm'] == true) {
        final String? replacementId = result['replacementId'];

        await vinculoRepo.handleMapeamentoInactivation(map.id!, replacementId);

        await repo.inativarMapeamento(map.id!);

        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              replacementId != null
                  ? 'Mapeamento inativado e funcionários migrados.'
                  : 'Mapeamento inativado e vínculos removidos.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Erro no processo de inativação: $e');
    }
  }

  void _showErrorSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _filterMappings(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredMapeamentos = _mapeamentos;
      } else {
        _filteredMapeamentos = _mapeamentos.where((map) {
          return map.nomeMapeamento.toLowerCase().contains(lowerQuery) ||
              map.cargo.nomeCargo.toLowerCase().contains(lowerQuery) ||
              map.setor.nomeSetor.toLowerCase().contains(lowerQuery) ||
              map.codigoMapeamento.toLowerCase().contains(lowerQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Column(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [CircularProgressIndicator(), Text('Carregando dados...')],
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            Text(_error!),
            FilledButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text("Tentar Novamente"),
            ),
          ],
        ),
      );
    }

    if (_mapeamentos.isEmpty) {
      return BuildEmpty(
        title: 'Nenhum mapeamento cadastrado',
        subtitle: 'Clique em "Novo Mapeamento" para começar',
        icon: Icons.map_outlined,
        titleDrawer: "Novo Mapeamento",
        drawer: _showMapingDrawer,
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: _filterMappings,
            decoration: InputDecoration(
              labelText: 'Pesquisar Mapeamento',
              hintText: 'Busque por nome, cargo ou setor...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
        Expanded(
          child: _filteredMapeamentos.isEmpty
              ? Center(child: Text('Nenhum mapeamento encontrado'))
              : ListView.builder(
                  itemCount: _mapeamentos.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final map = _mapeamentos[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          Icons.assignment_turned_in,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(map.nomeMapeamento),
                        subtitle: Text(
                          'Riscos: ${map.riscos.length} | Categorias EPI: ${map.listCategoriasEpis.length}\nCód: ${map.codigoMapeamento}',
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: map.status
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                map.status ? 'Ativo' : 'Inativo',
                                style: TextStyle(
                                  color: map.status ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.visibility_outlined),
                              tooltip: 'Visualizar',
                              onPressed: () => _showMapingDrawer(
                                mapping: map,
                                viewOnly: true,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: 'Editar',
                              onPressed: () => _showMapingDrawer(mapping: map),
                            ),
                            IconButton(
                              icon: Icon(
                                map.status
                                    ? Icons.power_settings_new
                                    : Icons.power_off,
                                color: map.status
                                    ? null
                                    : Theme.of(context).colorScheme.error,
                              ),
                              tooltip: map.status ? 'Inativar' : 'Ativar',
                              onPressed: () => _toggleStatus(map),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _InactivationDialog extends StatefulWidget {
  final String mapeamentoName;
  final int affectedCount;
  final List<MapeamentoEpiModel> availableMappings;

  const _InactivationDialog({
    required this.mapeamentoName,
    required this.affectedCount,
    required this.availableMappings,
  });

  @override
  State<_InactivationDialog> createState() => _InactivationDialogState();
}

class _InactivationDialogState extends State<_InactivationDialog> {
  String? _selectedReplacementId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
          const SizedBox(width: 12),
          const Text('Inativar Mapeamento'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Você está prestes a inativar "${widget.mapeamentoName}".',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (widget.affectedCount > 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people, color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Existem ${widget.affectedCount} funcionários vinculados a este mapeamento.',
                      style: const TextStyle(fontSize: 13, color: Colors.brown),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'O que deseja fazer com os vínculos existentes?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedReplacementId,
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Selecione uma ação...',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    'Remover vínculos (Deixar sem mapeamento)',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                ...widget.availableMappings.map(
                  (m) => DropdownMenuItem(
                    value: m.id,
                    child: Text('Substituir por: ${m.nomeMapeamento}'),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedReplacementId = value;
                });
              },
            ),
          ] else
            const Text('Nenhum funcionário será afetado.'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, {'confirm': false}),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, {
            'confirm': true,
            'replacementId': _selectedReplacementId,
          }),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
          ),
          child: const Text('Confirmar Inativação'),
        ),
      ],
    );
  }
}
