import 'package:flutter/material.dart';
import 'organizational_structure_drawer.dart';

class UnitsWidget extends StatefulWidget {
  const UnitsWidget({super.key});

  @override
  State<UnitsWidget> createState() => UnitsWidgetState();
}

class UnitsWidgetState extends State<UnitsWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _responsavelController = TextEditingController();
  
  String _tipoUnidade = 'Matriz';
  bool _statusAtiva = true;

  // LISTA DE UNIDADES CADASTRADAS (EXEMPLO)
  final List<Map<String, dynamic>> _unidadesCadastradas = [
    {
      'id': '1',
      'nome': 'Matriz São Paulo',
      'cnpj': '12.345.678/0001-90',
      'tipo': 'Matriz',
      'responsavel': 'Carlos Silva',
      'status': 'Ativa',
    },
    {
      'id': '2',
      'nome': 'Filial Rio de Janeiro',
      'cnpj': '98.765.432/0001-10',
      'tipo': 'Filial',
      'responsavel': 'Ana Oliveira',
      'status': 'Ativa',
    },
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _cnpjController.dispose();
    _enderecoController.dispose();
    _responsavelController.dispose();
    super.dispose();
  }

  // MÉTODO CHAMADO PELO BOTÃO DO HEADER
  void showAddDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Nova Unidade',
      pageBuilder: (context, _, __) => OrganizationalStructureDrawer(
        title: 'Nova Unidade',
        onClose: () => Navigator.of(context).pop(),
        onSave: _salvarUnidade,
        child: _buildUnitForm(),
      ),
    );
  }

  // FORMATAÇÃO DO CNPJ
  String _formatarCNPJ(String cnpj) {
    // Remove caracteres não numéricos
    cnpj = cnpj.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limita a 14 caracteres
    if (cnpj.length > 14) {
      cnpj = cnpj.substring(0, 14);
    }
    
    // Aplica a formatação
    if (cnpj.length >= 2) {
      cnpj = '${cnpj.substring(0, 2)}.${cnpj.substring(2)}';
    }
    if (cnpj.length >= 6) {
      cnpj = '${cnpj.substring(0, 6)}.${cnpj.substring(6)}';
    }
    if (cnpj.length >= 10) {
      cnpj = '${cnpj.substring(0, 10)}/${cnpj.substring(10)}';
    }
    if (cnpj.length >= 15) {
      cnpj = '${cnpj.substring(0, 15)}-${cnpj.substring(15)}';
    }
    
    return cnpj;
  }

  // VALIDAÇÃO DO CNPJ
  String? _validarCNPJ(String? value) {
    if (value == null || value.isEmpty) {
      return 'CNPJ é obrigatório';
    }
    
    // Remove caracteres não numéricos para validação
    final cnpjLimpo = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cnpjLimpo.length != 14) {
      return 'CNPJ deve ter exatamente 14 dígitos';
    }
    
    // Verifica se todos os dígitos são iguais (CNPJ inválido)
    if (RegExp(r'^(\d)\1+$').hasMatch(cnpjLimpo)) {
      return 'CNPJ inválido';
    }
    
    // Validação dos dígitos verificadores
    if (!_validarDigitosCNPJ(cnpjLimpo)) {
      return 'CNPJ inválido';
    }
    
    return null;
  }

  // ALGORITMO DE VALIDAÇÃO DOS DÍGITOS DO CNPJ
  bool _validarDigitosCNPJ(String cnpj) {
    // Peso para cálculo do primeiro dígito verificador
    final peso1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    // Peso para cálculo do segundo dígito verificador
    final peso2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    
    // Calcula primeiro dígito verificador
    var soma = 0;
    for (var i = 0; i < 12; i++) {
      soma += int.parse(cnpj[i]) * peso1[i];
    }
    
    var resto = soma % 11;
    var digito1 = resto < 2 ? 0 : 11 - resto;
    
    if (digito1 != int.parse(cnpj[12])) {
      return false;
    }
    
    // Calcula segundo dígito verificador
    soma = 0;
    for (var i = 0; i < 13; i++) {
      soma += int.parse(cnpj[i]) * peso2[i];
    }
    
    resto = soma % 11;
    var digito2 = resto < 2 ? 0 : 11 - resto;
    
    return digito2 == int.parse(cnpj[13]);
  }

  Widget _buildUnitForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seção: Informações da Unidade
          _buildSectionTitle('Informações da Unidade'),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _nomeController,
            decoration: const InputDecoration(
              labelText: 'Nome da Unidade*',
              hintText: 'Ex: Matriz São Paulo',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _cnpjController,
            decoration: const InputDecoration(
              labelText: 'CNPJ*',
              hintText: '00.000.000/0000-00',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            maxLength: 18, // 14 dígitos + 4 caracteres de formatação
            validator: _validarCNPJ,
            onChanged: (value) {
              final cursorPosition = _cnpjController.selection.baseOffset;
              final formattedValue = _formatarCNPJ(value);
              
              if (formattedValue != value) {
                _cnpjController.value = _cnpjController.value.copyWith(
                  text: formattedValue,
                  selection: TextSelection.collapsed(
                    offset: cursorPosition + (formattedValue.length - value.length),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _enderecoController,
            decoration: const InputDecoration(
              labelText: 'Endereço Completo*',
              hintText: 'Rua, número, bairro, cidade, estado',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _tipoUnidade,
            items: ['Matriz', 'Filial']
                .map((tipo) => DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _tipoUnidade = value!;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Tipo de Unidade*',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _responsavelController,
            decoration: const InputDecoration(
              labelText: 'Responsável Local*',
              hintText: 'Nome do responsável',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              const Text('Status da Unidade:'),
              const SizedBox(width: 12),
              Switch(
                value: _statusAtiva,
                onChanged: (value) {
                  setState(() {
                    _statusAtiva = value;
                  });
                },
              ),
              Text(
                _statusAtiva ? 'Ativa' : 'Inativa',
                style: TextStyle(
                  color: _statusAtiva ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  void _salvarUnidade() {
    if (_formKey.currentState!.validate()) {
      final novaUnidade = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'nome': _nomeController.text,
        'cnpj': _cnpjController.text,
        'endereco': _enderecoController.text,
        'tipo': _tipoUnidade,
        'responsavel': _responsavelController.text,
        'status': _statusAtiva ? 'Ativa' : 'Inativa',
      };
      
      // Adiciona na lista (simulação)
      setState(() {
        _unidadesCadastradas.add(novaUnidade);
      });
      
      // Limpar campos após salvar
      _limparCampos();
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unidade cadastrada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _limparCampos() {
    _nomeController.clear();
    _cnpjController.clear();
    _enderecoController.clear();
    _responsavelController.clear();
    _tipoUnidade = 'Matriz';
    _statusAtiva = true;
  }

  // MÉTODO PARA VISUALIZAR UNIDADE
  void _visualizarUnidade(Map<String, dynamic> unidade) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Visualizar ${unidade['nome']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoItem('Nome', unidade['nome']),
              _buildInfoItem('CNPJ', unidade['cnpj']),
              _buildInfoItem('Tipo', unidade['tipo']),
              _buildInfoItem('Responsável', unidade['responsavel']),
              _buildInfoItem('Status', unidade['status']),
              _buildInfoItem('Endereço', unidade['endereco']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // MÉTODO PARA EDITAR UNIDADE
  void _editarUnidade(Map<String, dynamic> unidade) {
    // Preenche os campos com os dados existentes
    _nomeController.text = unidade['nome'];
    _cnpjController.text = unidade['cnpj'];
    _enderecoController.text = unidade['endereco'];
    _responsavelController.text = unidade['responsavel'];
    _tipoUnidade = unidade['tipo'];
    _statusAtiva = unidade['status'] == 'Ativa';

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Editar Unidade',
      pageBuilder: (context, _, __) => OrganizationalStructureDrawer(
        title: 'Editar Unidade',
        onClose: () {
          _limparCampos();
          Navigator.of(context).pop();
        },
        onSave: () {
          _atualizarUnidade(unidade['id']);
        },
        child: _buildUnitForm(),
      ),
    );
  }

  void _atualizarUnidade(String id) {
    if (_formKey.currentState!.validate()) {
      setState(() {
        final index = _unidadesCadastradas.indexWhere((u) => u['id'] == id);
        if (index != -1) {
          _unidadesCadastradas[index] = {
            'id': id,
            'nome': _nomeController.text,
            'cnpj': _cnpjController.text,
            'endereco': _enderecoController.text,
            'tipo': _tipoUnidade,
            'responsavel': _responsavelController.text,
            'status': _statusAtiva ? 'Ativa' : 'Inativa',
          };
        }
      });
      
      _limparCampos();
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unidade atualizada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // MÉTODO PARA INATIVAR UNIDADE
  void _inativarUnidade(Map<String, dynamic> unidade) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Inativação'),
        content: Text(
          'Tem certeza que deseja inativar a unidade "${unidade['nome']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                final index = _unidadesCadastradas.indexWhere((u) => u['id'] == unidade['id']);
                if (index != -1) {
                  _unidadesCadastradas[index]['status'] = 'Inativa';
                }
              });
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Unidade "${unidade['nome']}" inativada com sucesso!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Inativar'),
          ),
        ],
      ),
    );
  }

  // MÉTODO PARA ATIVAR UNIDADE
  void _ativarUnidade(Map<String, dynamic> unidade) {
    setState(() {
      final index = _unidadesCadastradas.indexWhere((u) => u['id'] == unidade['id']);
      if (index != -1) {
        _unidadesCadastradas[index]['status'] = 'Ativa';
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unidade "${unidade['nome']}" ativada com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // REMOVIDO O TÍTULO DUPLICADO
        // APENAS A LISTA DE UNIDADES CADASTRADAS
        if (_unidadesCadastradas.isEmpty)
          _buildEmptyState()
        else
          Expanded(child: _buildUnitsList()),
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
              Icons.business_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma unidade cadastrada',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Clique em "Nova Unidade" para começar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitsList() {
    return ListView.builder(
      itemCount: _unidadesCadastradas.length,
      itemBuilder: (context, index) {
        final unidade = _unidadesCadastradas[index];
        final bool isAtiva = unidade['status'] == 'Ativa';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              unidade['tipo'] == 'Matriz' 
                  ? Icons.business 
                  : Icons.business_center,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              unidade['nome'],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CNPJ: ${unidade['cnpj']}'),
                Text('Responsável: ${unidade['responsavel']}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ÍCONE DE VISUALIZAR - COR ADAPTATIVA
                IconButton(
                  icon: Icon(Icons.visibility_outlined,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () => _visualizarUnidade(unidade),
                  tooltip: 'Visualizar',
                ),
                
                // ÍCONE DE EDITAR - COR ADAPTATIVA
                IconButton(
                  icon: Icon(Icons.edit_outlined,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () => _editarUnidade(unidade),
                  tooltip: 'Editar',
                ),
                
                // ÍCONE DE INATIVAR/ATIVAR - COR ADAPTATIVA
                if (isAtiva)
                  IconButton(
                    icon: Icon(Icons.toggle_off_outlined,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () => _inativarUnidade(unidade),
                    tooltip: 'Inativar',
                  )
                else
                  IconButton(
                    icon: Icon(Icons.toggle_on_outlined,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () => _ativarUnidade(unidade),
                    tooltip: 'Ativar',
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}