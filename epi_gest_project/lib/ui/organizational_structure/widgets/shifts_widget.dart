import 'package:flutter/material.dart';
import 'organizational_structure_drawer.dart';

class ShiftsWidget extends StatefulWidget {
  const ShiftsWidget({super.key});

  @override
  State<ShiftsWidget> createState() => ShiftsWidgetState();
}

class ShiftsWidgetState extends State<ShiftsWidget> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _nomeController = TextEditingController();
  TimeOfDay _entrada = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _saida = const TimeOfDay(hour: 17, minute: 0);

  // LISTA DE TURNOS CADASTRADOS
  final List<Map<String, dynamic>> _turnosCadastrados = [
    {
      'codigo': 'TUR001',
      'nome': 'Manhã',
      'entrada': '06:00',
      'saida': '14:00',
    },
    {
      'codigo': 'TUR002',
      'nome': 'Tarde',
      'entrada': '14:00', 
      'saida': '22:00',
    },
  ];

  @override
  void dispose() {
    _codigoController.dispose();
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isEntrada) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isEntrada ? _entrada : _saida,
    );
    
    if (picked != null) {
      setState(() {
        if (isEntrada) {
          _entrada = picked;
        } else {
          _saida = picked;
        }
      });
    }
  }

  void showAddDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Novo Turno',
      pageBuilder: (context, _, __) => OrganizationalStructureDrawer(
        title: 'Novo Turno de Trabalho',
        onClose: () => Navigator.of(context).pop(),
        onSave: _salvarTurno,
        child: _buildShiftForm(),
      ),
    );
  }

  Widget _buildShiftForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Informações do Turno'),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _codigoController,
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
            controller: _nomeController,
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
                    title: const Text('Horário de Entrada'),
                    subtitle: Text(_entrada.format(context)),
                    onTap: () => _selectTime(context, true),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Horário de Saída'),
                    subtitle: Text(_saida.format(context)),
                    onTap: () => _selectTime(context, false),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          Center(
            child: Text(
              'Duração: ${_calcularDuracao()}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calcularDuracao() {
    final entradaMinutos = _entrada.hour * 60 + _entrada.minute;
    final saidaMinutos = _saida.hour * 60 + _saida.minute;
    var duracaoMinutos = saidaMinutos - entradaMinutos;
    
    // Se a saída for no dia seguinte (turno da noite)
    if (duracaoMinutos < 0) {
      duracaoMinutos += 24 * 60;
    }
    
    final horas = duracaoMinutos ~/ 60;
    final minutos = duracaoMinutos % 60;
    
    return '${horas}h ${minutos.toString().padLeft(2, '0')}min';
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  void _salvarTurno() {
    if (_formKey.currentState!.validate()) {
      final novoTurno = {
        'codigo': _codigoController.text,
        'nome': _nomeController.text,
        'entrada': '${_entrada.hour}:${_entrada.minute.toString().padLeft(2, '0')}',
        'saida': '${_saida.hour}:${_saida.minute.toString().padLeft(2, '0')}',
        'duracao': _calcularDuracao(),
      };
      
      setState(() {
        _turnosCadastrados.add(novoTurno);
      });
      
      _limparCampos();
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turno cadastrado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _limparCampos() {
    _codigoController.clear();
    _nomeController.clear();
    _entrada = const TimeOfDay(hour: 8, minute: 0);
    _saida = const TimeOfDay(hour: 17, minute: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Turnos de Trabalho',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Configure os turnos e jornadas de trabalho',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),
        
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
                Text('Duração: ${turno['duracao']}'),
              ],
            ),
            onTap: () {
              // TODO: Implementar edição
            },
          ),
        );
      },
    );
  }
}