import 'package:flutter/material.dart';
import 'organizational_structure_drawer.dart';

class ShiftsWidget extends StatefulWidget {
  const ShiftsWidget({super.key});

  @override
  State<ShiftsWidget> createState() => ShiftsWidgetState();
}

class ShiftsWidgetState extends State<ShiftsWidget> {
  final _formKey = GlobalKey<FormState>();
  
  // LISTA DE TURNOS CADASTRADOS
  List<Map<String, dynamic>> _turnosCadastrados = [
    {
      'id': '1',
      'codigo': 'TUR001',
      'nome': 'Manhã',
      'entrada': '06:00',
      'saida': '14:00',
      'almocoInicio': '12:00',
      'almocoFim': '13:00',
      'status': 'Ativo',
    },
    {
      'id': '2',
      'codigo': 'TUR002',
      'nome': 'Tarde',
      'entrada': '14:00', 
      'saida': '22:00',
      'almocoInicio': '18:00',
      'almocoFim': '19:00',
      'status': 'Ativo',
    },
  ];

  void showAddDrawer() {
    // VARIÁVEIS LOCAIS para este drawer específico
    final codigoController = TextEditingController();
    final nomeController = TextEditingController();
    TimeOfDay entrada = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay saida = const TimeOfDay(hour: 17, minute: 0);
    TimeOfDay almocoInicio = const TimeOfDay(hour: 12, minute: 0);
    TimeOfDay almocoFim = const TimeOfDay(hour: 13, minute: 0);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Novo Turno',
      pageBuilder: (context, _, __) {
        return OrganizationalStructureDrawer(
          title: 'Novo Turno de Trabalho',
          onClose: () {
            codigoController.dispose();
            Navigator.of(context).pop();
          },
          onSave: () {
            _salvarTurno(
              codigoController.text,
              nomeController.text,
              entrada,
              saida,
              almocoInicio,
              almocoFim,
            );
          },
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              // FUNÇÃO para formatar duração DENTRO do StatefulBuilder
              String formatarDuracao(int minutos) {
                final horas = minutos ~/ 60;
                final min = minutos % 60;
                
                if (horas > 0 && min > 0) {
                  return '${horas}h ${min.toString().padLeft(2, '0')}min';
                } else if (horas > 0) {
                  return '${horas}h';
                } else {
                  return '${min}min';
                }
              }

              // FUNÇÃO para calcular duração do almoço DENTRO do StatefulBuilder
              int calcularDuracaoAlmoco() {
                final inicioMinutos = almocoInicio.hour * 60 + almocoInicio.minute;
                final fimMinutos = almocoFim.hour * 60 + almocoFim.minute;
                var duracao = fimMinutos - inicioMinutos;
                
                if (duracao < 0) {
                  duracao += 24 * 60;
                }
                
                return duracao;
              }

              // FUNÇÃO para calcular horário trabalhado DENTRO do StatefulBuilder
              String calcularHorarioTrabalhado() {
                final entradaMinutos = entrada.hour * 60 + entrada.minute;
                final saidaMinutos = saida.hour * 60 + saida.minute;
                var duracaoMinutos = saidaMinutos - entradaMinutos;
                
                if (duracaoMinutos < 0) {
                  duracaoMinutos += 24 * 60;
                }
                
                final duracaoAlmoco = calcularDuracaoAlmoco();
                if (duracaoAlmoco > 0) {
                  duracaoMinutos -= duracaoAlmoco;
                }
                
                return formatarDuracao(duracaoMinutos);
              }

              // FUNÇÃO para calcular duração total DENTRO do StatefulBuilder
              String calcularDuracaoTotal() {
                final entradaMinutos = entrada.hour * 60 + entrada.minute;
                final saidaMinutos = saida.hour * 60 + saida.minute;
                var duracaoMinutos = saidaMinutos - entradaMinutos;
                
                if (duracaoMinutos < 0) {
                  duracaoMinutos += 24 * 60;
                }
                
                return formatarDuracao(duracaoMinutos);
              }

              // FUNÇÃO para selecionar horário DENTRO do StatefulBuilder
              Future<void> selectTime(String tipo) async {
                TimeOfDay initialTime;
                
                switch (tipo) {
                  case 'entrada':
                    initialTime = entrada;
                    break;
                  case 'saida':
                    initialTime = saida;
                    break;
                  case 'almocoInicio':
                    initialTime = almocoInicio;
                    break;
                  case 'almocoFim':
                    initialTime = almocoFim;
                    break;
                  default:
                    initialTime = const TimeOfDay(hour: 12, minute: 0);
                }

                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: initialTime,
                );
                
                if (picked != null) {
                  // ATUALIZA o estado DENTRO do drawer
                  setDialogState(() {
                    switch (tipo) {
                      case 'entrada':
                        entrada = picked;
                        break;
                      case 'saida':
                        saida = picked;
                        break;
                      case 'almocoInicio':
                        almocoInicio = picked;
                        break;
                      case 'almocoFim':
                        almocoFim = picked;
                        break;
                    }
                  });
                }
              }

              // FORMULÁRIO DENTRO do StatefulBuilder
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Informações do Turno'),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: codigoController,
                      decoration: const InputDecoration(
                        labelText: 'Código do Turno*',
                        hintText: 'Ex: TUR001',
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
                      controller: nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Turno*',
                        hintText: 'Ex: Manhã, Tarde, Noite, 12x36',
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
                    
                    _buildSectionTitle('Horários do Turno'),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: ListTile(
                              leading: const Icon(Icons.login),
                              title: const Text('Horário de Entrada*'),
                              subtitle: Text(entrada.format(context)),
                              onTap: () => selectTime('entrada'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            child: ListTile(
                              leading: const Icon(Icons.logout),
                              title: const Text('Horário de Saída*'),
                              subtitle: Text(saida.format(context)),
                              onTap: () => selectTime('saida'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    _buildSectionTitle('Horário da Refeição'),
                    const SizedBox(height: 8),
                    Text(
                      'Defina o intervalo para refeição (opcional)',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: ListTile(
                              leading: const Icon(Icons.restaurant),
                              title: const Text('Início'),
                              subtitle: Text(almocoInicio.format(context)),
                              onTap: () => selectTime('almocoInicio'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            child: ListTile(
                              leading: const Icon(Icons.restaurant_menu),
                              title: const Text('Fim'),
                              subtitle: Text(almocoFim.format(context)),
                              onTap: () => selectTime('almocoFim'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    if (calcularDuracaoAlmoco() > 0)
                      Center(
                        child: Text(
                          'Duração da refeição: ${formatarDuracao(calcularDuracaoAlmoco())}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Resumo da Jornada',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'Duração Total',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      calcularDuracaoTotal(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Horário Trabalhado',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      calcularHorarioTrabalhado(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
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

  void _salvarTurno(
    String codigo,
    String nome,
    TimeOfDay entrada,
    TimeOfDay saida,
    TimeOfDay almocoInicio,
    TimeOfDay almocoFim,
  ) {
    if (_formKey.currentState!.validate()) {
      final novoTurno = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'codigo': codigo,
        'nome': nome,
        'entrada': '${entrada.hour}:${entrada.minute.toString().padLeft(2, '0')}',
        'saida': '${saida.hour}:${saida.minute.toString().padLeft(2, '0')}',
        'almocoInicio': '${almocoInicio.hour}:${almocoInicio.minute.toString().padLeft(2, '0')}',
        'almocoFim': '${almocoFim.hour}:${almocoFim.minute.toString().padLeft(2, '0')}',
        'duracaoTotal': _calcularDuracaoTotal(entrada, saida),
        'horarioTrabalhado': _calcularHorarioTrabalhado(entrada, saida, almocoInicio, almocoFim),
        'status': 'Ativo',
      };
      
      setState(() {
        _turnosCadastrados.add(novoTurno);
      });
      
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turno cadastrado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // FUNÇÕES de cálculo para uso externo
  String _calcularHorarioTrabalhado(TimeOfDay entrada, TimeOfDay saida, TimeOfDay almocoInicio, TimeOfDay almocoFim) {
    final entradaMinutos = entrada.hour * 60 + entrada.minute;
    final saidaMinutos = saida.hour * 60 + saida.minute;
    var duracaoMinutos = saidaMinutos - entradaMinutos;
    
    if (duracaoMinutos < 0) {
      duracaoMinutos += 24 * 60;
    }
    
    final almocoInicioMinutos = almocoInicio.hour * 60 + almocoInicio.minute;
    final almocoFimMinutos = almocoFim.hour * 60 + almocoFim.minute;
    var duracaoAlmoco = almocoFimMinutos - almocoInicioMinutos;
    
    if (duracaoAlmoco < 0) {
      duracaoAlmoco += 24 * 60;
    }
    
    if (duracaoAlmoco > 0) {
      duracaoMinutos -= duracaoAlmoco;
    }
    
    return _formatarDuracao(duracaoMinutos);
  }

  String _calcularDuracaoTotal(TimeOfDay entrada, TimeOfDay saida) {
    final entradaMinutos = entrada.hour * 60 + entrada.minute;
    final saidaMinutos = saida.hour * 60 + saida.minute;
    var duracaoMinutos = saidaMinutos - entradaMinutos;
    
    if (duracaoMinutos < 0) {
      duracaoMinutos += 24 * 60;
    }
    
    return _formatarDuracao(duracaoMinutos);
  }

  String _formatarDuracao(int minutos) {
    final horas = minutos ~/ 60;
    final min = minutos % 60;
    
    if (horas > 0 && min > 0) {
      return '${horas}h ${min.toString().padLeft(2, '0')}min';
    } else if (horas > 0) {
      return '${horas}h';
    } else {
      return '${min}min';
    }
  }

  // ... (resto dos métodos permanecem iguais)
  void _visualizarTurno(Map<String, dynamic> turno) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Visualizar ${turno['nome']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoItem('Código', turno['codigo']),
              _buildInfoItem('Nome', turno['nome']),
              _buildInfoItem('Entrada', turno['entrada']),
              _buildInfoItem('Saída', turno['saida']),
              if (turno['almocoInicio'] != '12:00' || turno['almocoFim'] != '13:00') ...[
                _buildInfoItem('Início do Almoço', turno['almocoInicio']),
                _buildInfoItem('Fim do Almoço', turno['almocoFim']),
              ] else
                _buildInfoItem('Almoço', 'Sem intervalo'),
              _buildInfoItem('Duração Total', turno['duracaoTotal']),
              _buildInfoItem('Horário Trabalhado', turno['horarioTrabalhado']),
              _buildInfoItem('Status', turno['status']),
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

  void _editarTurno(Map<String, dynamic> turno) {
    // Por enquanto, vamos apenas mostrar um aviso
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de edição será implementada em breve!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _inativarTurno(Map<String, dynamic> turno) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Inativação'),
        content: Text(
          'Tem certeza que deseja inativar o turno "${turno['nome']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                final index = _turnosCadastrados.indexWhere((t) => t['id'] == turno['id']);
                if (index != -1) {
                  _turnosCadastrados[index]['status'] = 'Inativo';
                }
              });
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Turno "${turno['nome']}" inativado com sucesso!'),
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

  void _ativarTurno(Map<String, dynamic> turno) {
    setState(() {
      final index = _turnosCadastrados.indexWhere((t) => t['id'] == turno['id']);
      if (index != -1) {
        _turnosCadastrados[index]['status'] = 'Ativo';
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Turno "${turno['nome']}" ativado com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_turnosCadastrados.isEmpty)
          _buildEmptyState()
        else
          Expanded(child: _buildShiftsList()),
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
              Icons.access_time_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum turno cadastrado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftsList() {
    return ListView.builder(
      itemCount: _turnosCadastrados.length,
      itemBuilder: (context, index) {
        final turno = _turnosCadastrados[index];
        final bool isAtivo = turno['status'] == 'Ativo';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              Icons.access_time_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              turno['nome'],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Código: ${turno['codigo']}'),
                Text('Horário: ${turno['entrada']} - ${turno['saida']}'),
                Text('Trabalhado: ${turno['horarioTrabalhado']}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.visibility_outlined,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () => _visualizarTurno(turno),
                  tooltip: 'Visualizar',
                ),
                IconButton(
                  icon: Icon(Icons.edit_outlined,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () => _editarTurno(turno),
                  tooltip: 'Editar',
                ),
                if (isAtivo)
                  IconButton(
                    icon: Icon(Icons.toggle_off_outlined,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () => _inativarTurno(turno),
                    tooltip: 'Inativar',
                  )
                else
                  IconButton(
                    icon: Icon(Icons.toggle_on_outlined,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () => _ativarTurno(turno),
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