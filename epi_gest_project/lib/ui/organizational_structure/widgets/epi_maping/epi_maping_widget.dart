import 'package:epi_gest_project/data/services/cargo_repository.dart';
import 'package:epi_gest_project/data/services/categoria_repository.dart';
import 'package:epi_gest_project/data/services/mapeamento_epi_repository.dart';
import 'package:epi_gest_project/data/services/riscos_repository.dart';
import 'package:epi_gest_project/data/services/setor_repository.dart';
import 'package:epi_gest_project/domain/models/cargo_model.dart';
import 'package:epi_gest_project/domain/models/categoria_model.dart';
import 'package:epi_gest_project/domain/models/mapeamento_epi_model.dart';
import 'package:epi_gest_project/domain/models/riscos_model.dart';
import 'package:epi_gest_project/domain/models/setor_model.dart';
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
      final mapRepo = Provider.of<MapeamentoEpiRepository>(context, listen: false);
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
    try {
      if (map.status) {
        await repo.inativarMapeamento(map.id!);
      } else {
        await repo.ativarMapeamento(map.id!);
      }
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status do mapeamento alterado!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao alterar status: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteMapping(MapeamentoEpiModel map) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Excluir mapeamento ${map.setor.nomeSetor} - ${map.cargo.nomeCargo}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final repo = Provider.of<MapeamentoEpiRepository>(context, listen: false);
        await repo.delete(map.id!);
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Excluído com sucesso!'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));

    if (_mapeamentos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Nenhum mapeamento cadastrado'),
            const SizedBox(height: 8),
            const Text('Clique em "Novo Mapeamento" para começar'),
          ],
        ),
      );
    }

    return ListView.builder(
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
            title: Text('${map.setor.nomeSetor} - ${map.cargo.nomeCargo}'),
            subtitle: Text(
              'Riscos: ${map.riscos.length} | Categorias EPI: ${map.listCategoriasEpis.length}\nCód: ${map.codigoMapeamento}',
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: map.status ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
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
                  onPressed: () => _showMapingDrawer(mapping: map, viewOnly: true),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar',
                  onPressed: () => _showMapingDrawer(mapping: map),
                ),
                IconButton(
                  icon: Icon(
                    map.status ? Icons.toggle_on : Icons.toggle_off,
                    color: map.status ? Colors.green : Colors.grey,
                  ),
                  tooltip: map.status ? 'Inativar' : 'Ativar',
                  onPressed: () => _toggleStatus(map),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Excluir',
                  onPressed: () => _deleteMapping(map),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}