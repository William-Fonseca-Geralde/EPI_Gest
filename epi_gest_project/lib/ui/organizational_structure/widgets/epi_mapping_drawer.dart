import 'package:flutter/material.dart';
import 'package:epi_gest_project/ui/organizational_structure/widgets/organizational_structure_drawer.dart';

class EpiMappingDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback? onSave;

  const EpiMappingDrawer({
    super.key,
    required this.onClose,
    this.onSave,
  });

  @override
  State<EpiMappingDrawer> createState() => _EpiMappingDrawerState();
}

class _EpiMappingDrawerState extends State<EpiMappingDrawer> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para os campos
  String? _selectedSetor;
  String? _selectedCargo;
  List<String> _selectedRiscos = [];
  List<EpiItem> _selectedEpis = [];

  // Listas mockadas - você vai substituir por dados reais do seu sistema
  final List<String> _setores = [
    'Produção',
    'Administrativo',
    'Manutenção',
    'Qualidade',
    'Logística',
    'Recursos Humanos',
    'Financeiro',
    'Comercial',
    'Marketing',
    'TI',
    'Engenharia',
    'Almoxarifado',
    'Limpeza',
    'Segurança do Trabalho',
    'Controle de Qualidade'
  ];

  final List<String> _cargos = [
    'Operador de Máquina',
    'Auxiliar de Produção',
    'Supervisor',
    'Analista de Qualidade',
    'Técnico de Manutenção',
    'Gerente de Produção',
    'Coordenador de Logística',
    'Assistente Administrativo',
    'Analista Financeiro',
    'Engenheiro de Produção',
    'Técnico em Segurança',
    'Auxiliar de Limpeza',
    'Almoxarife',
    'Motorista',
    'Estoquista',
    'Recepcionista',
    'Analista de TI',
    'Vendedor',
    'Promotor de Vendas'
  ];

  final List<String> _riscos = [
    'Risco Físico',
    'Risco Químico',
    'Risco Biológico',
    'Risco Ergonômico',
    'Risco de Acidente',
    'Ruído Excessivo',
    'Calor Excessivo',
    'Frio Excessivo',
    'Umidade',
    'Vibração',
    'Radiação Ionizante',
    'Radiação Não Ionizante',
    'Pressões Anormais',
    'Iluminação Inadequada',
    'Produtos Químicos',
    'Poeiras',
    'Fumos',
    'Névoas',
    'Neblinas',
    'Gases',
    'Vapores',
    'Agentes Biológicos',
    'Vírus',
    'Bactérias',
    'Fungos',
    'Protozoários',
    'Postura Inadequada',
    'Levantamento de Peso',
    'Repetitividade',
    'Trabalho em Turnos',
    'Jornada Prolongada',
    'Risco Mecânico',
    'Risco Elétrico',
    'Incêndio',
    'Explosão'
  ];

  // Lista de EPIs com nome e C.A.
  final List<EpiItem> _epis = [
    EpiItem(nome: 'Capacete de Segurança', ca: '12345'),
    EpiItem(nome: 'Óculos de Proteção', ca: '67890'),
    EpiItem(nome: 'Protetor Auricular', ca: '11223'),
    EpiItem(nome: 'Protetor Auricular Tipo Concha', ca: '33445'),
    EpiItem(nome: 'Luvas de Proteção Nitrílica', ca: '44556'),
    EpiItem(nome: 'Luvas de Proteção Latex', ca: '77889'),
    EpiItem(nome: 'Luvas de Proteção PVC', ca: '99101'),
    EpiItem(nome: 'Luvas de Couro', ca: '11213'),
    EpiItem(nome: 'Máscara Respiratória PFF2', ca: '99001'),
    EpiItem(nome: 'Máscara Respiratória N95', ca: '22334'),
    EpiItem(nome: 'Máscara Cirúrgica', ca: '44556'),
    EpiItem(nome: 'Respirador com Filtro', ca: '66778'),
    EpiItem(nome: 'Botina de Segurança', ca: '55667'),
    EpiItem(nome: 'Botina com Biqueira de Aço', ca: '88990'),
    EpiItem(nome: 'Sapato de Segurança', ca: '00112'),
    EpiItem(nome: 'Colete Refletivo', ca: '88990'),
    EpiItem(nome: 'Cinto de Segurança Tipo Paraquedista', ca: '33445'),
    EpiItem(nome: 'Talabarte de Segurança', ca: '55667'),
    EpiItem(nome: 'Capacete com Jugular', ca: '77889'),
    EpiItem(nome: 'Avental de PVC', ca: '99001'),
    EpiItem(nome: 'Avental de Led', ca: '11213'),
    EpiItem(nome: 'Manga de Proteção', ca: '33445'),
    EpiItem(nome: 'Perneira de Proteção', ca: '55667'),
    EpiItem(nome: 'Protetor Facial', ca: '77889'),
    EpiItem(nome: 'Protetor Auditivo Tipo Inserto', ca: '99001')
  ];

  void _showRiscosSelection() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  maxHeight: 600,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header do modal
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Riscos Associados',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    
                    // Conteúdo com scroll
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              'Selecione os riscos',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Lista de riscos com scroll
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: _riscos.map((risco) {
                                    return CheckboxListTile(
                                      title: Text(risco),
                                      value: _selectedRiscos.contains(risco),
                                      onChanged: (value) {
                                        setDialogState(() {
                                          if (value == true) {
                                            _selectedRiscos.add(risco);
                                          } else {
                                            _selectedRiscos.remove(risco);
                                          }
                                        });
                                      },
                                      contentPadding: EdgeInsets.zero,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Footer com botões
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {});
                            },
                            child: const Text('Confirmar'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEpisSelection() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  maxHeight: 600,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header do modal
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'EPIs Necessários',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    
                    // Conteúdo com scroll
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              'Selecione os EPIs',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Lista de EPIs com scroll
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: _epis.map((epi) {
                                    return CheckboxListTile(
                                      title: Text(epi.nome),
                                      subtitle: Text(
                                        'C.A. ${epi.ca}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      value: _selectedEpis.contains(epi),
                                      onChanged: (value) {
                                        setDialogState(() {
                                          if (value == true) {
                                            _selectedEpis.add(epi);
                                          } else {
                                            _selectedEpis.remove(epi);
                                          }
                                        });
                                      },
                                      contentPadding: EdgeInsets.zero,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Footer com botões
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {});
                            },
                            child: const Text('Confirmar'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      // Aqui você vai implementar a lógica de salvamento
      // usando _selectedSetor, _selectedCargo, _selectedRiscos, _selectedEpis
      
      if (widget.onSave != null) {
        widget.onSave!();
      }
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrganizationalStructureDrawer(
      title: 'Novo Mapeamento de EPI',
      onClose: widget.onClose,
      onSave: _onSave,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo Setor
              _buildDropdownField(
                label: 'Setor',
                value: _selectedSetor,
                items: _setores,
                onChanged: (value) {
                  setState(() {
                    _selectedSetor = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione um setor';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Campo Cargo/Função
              _buildDropdownField(
                label: 'Cargo/Função',
                value: _selectedCargo,
                items: _cargos,
                onChanged: (value) {
                  setState(() {
                    _selectedCargo = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione um cargo';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Campo Riscos
              _buildMultiSelectionField(
                label: 'Riscos Ocupacionais',
                selectedItems: _selectedRiscos,
                onTap: _showRiscosSelection,
              ),

              const SizedBox(height: 20),

              // Campo EPIs
              _buildEpiSelectionField(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

 Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: 'Selecione um $label',
          ),
          isExpanded: true,
          // Correção: usar menuMaxHeight em vez de dropdownMaxHeight
          menuMaxHeight: 400,
        ),
      ],
    );
  }

  Widget _buildMultiSelectionField({
    required String label,
    required List<String> selectedItems,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedItems.isEmpty)
                        Text(
                          'Selecione os $label',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        )
                      else
                        Text(
                          '${selectedItems.length} ${selectedItems.length == 1 ? 'item selecionado' : 'itens selecionados'}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      if (selectedItems.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          selectedItems.join(', '),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEpiSelectionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EPIs Necessários',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _showEpisSelection,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedEpis.isEmpty)
                        Text(
                          'Selecione os EPIs',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        )
                      else
                        Text(
                          '${_selectedEpis.length} ${_selectedEpis.length == 1 ? 'EPI selecionado' : 'EPIs selecionados'}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      if (_selectedEpis.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        ..._selectedEpis.map((epi) {
                          return Text(
                            '${epi.nome} - C.A. ${epi.ca}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        }).toList(),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Classe para representar um EPI com nome e C.A.
class EpiItem {
  final String nome;
  final String ca;

  EpiItem({
    required this.nome,
    required this.ca,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EpiItem && other.nome == nome && other.ca == ca;
  }

  @override
  int get hashCode => nome.hashCode ^ ca.hashCode;

  @override
  String toString() {
    return '$nome (C.A. $ca)';
  }
}