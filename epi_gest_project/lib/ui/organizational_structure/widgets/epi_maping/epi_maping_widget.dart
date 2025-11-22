import 'package:epi_gest_project/domain/models/epi/epi_model.dart';
import 'package:flutter/material.dart';
import 'package:epi_gest_project/ui/organizational_structure/widgets/epi_maping/epi_mapping_drawer.dart';

// MODELOS SIMPLES DENTRO DO MESMO ARQUIVO
class Sector {
  final String id;
  final String descricao;

  Sector({required this.id, required this.descricao});
}

class Role {
  final String id;
  final String descricao;

  Role({required this.id, required this.descricao});
}

class Risk {
  final String id;
  final String descricao;

  Risk({required this.id, required this.descricao});
}

class EpiMapingWidget extends StatefulWidget {
  const EpiMapingWidget({super.key});

  @override
  State<EpiMapingWidget> createState() => EpiMapingWidgetState();
}

class EpiMapingWidgetState extends State<EpiMapingWidget> {
  final List<Map<String, dynamic>> _mapeamentos = [];

  // DADOS FALSOS PARA TESTE
  final List<Sector> _availableSectors = [
    Sector(id: '1', descricao: 'Produção'),
    Sector(id: '2', descricao: 'Manutenção'),
    Sector(id: '3', descricao: 'Almoxarifado'),
    Sector(id: '4', descricao: 'Administrativo'),
    Sector(id: '5', descricao: 'Qualidade'),
  ];

  final List<Role> _availableRoles = [
    Role(id: '1', descricao: 'Operador de Máquinas'),
    Role(id: '2', descricao: 'Auxiliar de Produção'),
    Role(id: '3', descricao: 'Técnico de Manutenção'),
    Role(id: '4', descricao: 'Almoxarife'),
    Role(id: '5', descricao: 'Supervisor'),
  ];

  final List<Risk> _availableRisks = [
    Risk(id: '1', descricao: 'Risco Químico'),
    Risk(id: '2', descricao: 'Risco Físico'),
    Risk(id: '3', descricao: 'Risco Biológico'),
    Risk(id: '4', descricao: 'Risco Ergonômico'),
    Risk(id: '5', descricao: 'Risco de Acidentes'),
  ];

  final List<EpiModel> _availableEpis = [
    EpiModel(
      id: '1',
      nome: 'Capacete de Segurança',
      categoria: 'Proteção da Cabeça',
      ca: 'CA12345',
      quantidadeEstoque: 50,
      valorUnitario: 45.90,
      dataValidade: DateTime.now().add(Duration(days: 365)),
      fornecedor: 'Fornecedor A',
      descricao: 'Capacete de segurança industrial',
    ),
    EpiModel(
      id: '2',
      nome: 'Luvas de Proteção',
      categoria: 'Proteção das Mãos',
      ca: 'CA12346',
      quantidadeEstoque: 100,
      valorUnitario: 12.50,
      dataValidade: DateTime.now().add(Duration(days: 180)),
      fornecedor: 'Fornecedor B',
      descricao: 'Luvas de proteção contra produtos químicos',
    ),
    EpiModel(
      id: '3',
      nome: 'Óculos de Proteção',
      categoria: 'Proteção Ocular',
      ca: 'CA12347',
      quantidadeEstoque: 75,
      valorUnitario: 28.90,
      dataValidade: DateTime.now().add(Duration(days: 365)),
      fornecedor: 'Fornecedor C',
      descricao: 'Óculos de proteção contra impactos',
    ),
    EpiModel(
      id: '4',
      nome: 'Protetor Auricular',
      categoria: 'Proteção Auditiva',
      ca: 'CA12348',
      quantidadeEstoque: 60,
      valorUnitario: 35.00,
      dataValidade: DateTime.now().add(Duration(days: 365)),
      fornecedor: 'Fornecedor D',
      descricao: 'Protetor auricular tipo concha',
    ),
  ];

  // ADICIONAR: Lista de categorias disponíveis
  final List<String> _availableCategories = [
    'Proteção da Cabeça',
    'Proteção das Mãos', 
    'Proteção Ocular',
    'Proteção Auditiva',
    'Proteção Respiratória',
  ];

  void showAddDrawer() {
    _showMapingDrawer();
  }

  void _showMapingDrawer({Map<String, dynamic>? mapping, bool viewOnly = false}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Gerenciar Mapeamento',
      pageBuilder: (context, _, __) => EpiMappingDrawer(
        mappingToEdit: mapping,
        view: viewOnly,
        onClose: () => Navigator.of(context).pop(),
        onSave: (mapSalvo) {
          setState(() {
            if (mapping != null) {
              final index = _mapeamentos.indexWhere((m) => m['id'] == mapSalvo['id']);
              if (index != -1) _mapeamentos[index] = mapSalvo;
            } else {
              _mapeamentos.add(mapSalvo);
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mapeamento ${mapping != null ? 'atualizado' : 'cadastrado'} com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        },
        // CORRIGIDO: Converter os tipos para Map<String, dynamic>
        availableSectors: _availableSectors.map((sector) => {
          'id': sector.id,
          'descricao': sector.descricao,
        }).toList(),
        availableRoles: _availableRoles.map((role) => {
          'id': role.id,
          'descricao': role.descricao,
        }).toList(),
        availableRisks: _availableRisks.map((risk) => {
          'id': risk.id,
          'descricao': risk.descricao,
        }).toList(),
        availableCategories: _availableCategories, // ADICIONADO
        availableEpis: _availableEpis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Botão para adicionar novo mapeamento
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton.icon(
            onPressed: showAddDrawer,
            icon: const Icon(Icons.add),
            label: const Text('Novo Mapeamento'),
          ),
        ),

        if (_mapeamentos.isEmpty)
          _buildEmptyState()
        else
          Expanded(child: _buildMappingsList()),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum mapeamento cadastrado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Clique em "Novo Mapeamento" para começar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMappingsList() {
    return ListView.builder(
      itemCount: _mapeamentos.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final map = _mapeamentos[index];
        final sector = map['sector'] as Map<String, dynamic>;
        final role = map['role'] as Map<String, dynamic>;
        final risks = map['risks'] as List<Map<String, dynamic>>;
        final categories = map['categories'] as List<String>;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              Icons.assignment_turned_in_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text('${sector['descricao']} - ${role['descricao']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Riscos: ${risks.length}'),
                Text('Categorias: ${categories.length}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Excluir',
                  onPressed: () {
                    _deleteMapping(map);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteMapping(Map<String, dynamic> mapping) {
    final sector = mapping['sector'] as Map<String, dynamic>;
    final role = mapping['role'] as Map<String, dynamic>;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir o mapeamento ${sector['descricao']} - ${role['descricao']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _mapeamentos.remove(mapping);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mapeamento excluído com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}