import 'package:epi_gest_project/data/services/epi_repository.dart';
import 'package:epi_gest_project/data/services/mapeamento_funcionario_repository.dart';
import 'package:epi_gest_project/domain/models/epi_model.dart';
import 'package:epi_gest_project/domain/models/ficha_epi_model.dart';
import 'package:epi_gest_project/domain/models/funcionario_model.dart';
import 'package:epi_gest_project/domain/models/mapeamento_funcionario_model.dart';
import 'package:epi_gest_project/ui/widgets/base_drawer.dart';
import 'package:epi_gest_project/ui/widgets/form_fields.dart';
import 'package:epi_gest_project/ui/widgets/info_section.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FichaEpiDrawer extends StatefulWidget {
  final FuncionarioModel funcionario;
  final VoidCallback onClose;
  final Function onSave;

  const FichaEpiDrawer({
    super.key,
    required this.funcionario,
    required this.onClose,
    required this.onSave,
  });

  @override
  State<FichaEpiDrawer> createState() => _FichaEpiDrawerState();
}

class _FichaEpiDrawerState extends State<FichaEpiDrawer> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _mapeamentoController = TextEditingController();
  final _epiController = TextEditingController();
  final _validadeCaController = TextEditingController();
  final _estoqueController = TextEditingController();
  final _dataEntregaController = TextEditingController();
  final _previsaoTrocaController = TextEditingController();

  // State Data
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  
  List<EpiModel> _availableEpis = [];
  EpiModel? _selectedEpi;
  MapeamentoFuncionarioModel? _mapeamentoFuncionario;
  
  final DateTime _dataEntrega = DateTime.now();
  DateTime? _dataPrevisaoTroca;

  @override
  void initState() {
    super.initState();
    _dataEntregaController.text = DateFormat('dd/MM/yyyy').format(_dataEntrega);
    _loadData();
  }

  @override
  void dispose() {
    _mapeamentoController.dispose();
    _epiController.dispose();
    _validadeCaController.dispose();
    _estoqueController.dispose();
    _dataEntregaController.dispose();
    _previsaoTrocaController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final mapFuncRepo = Provider.of<MapeamentoFuncionarioRepository>(context, listen: false);
      final epiRepo = Provider.of<EpiRepository>(context, listen: false);

      // Carrega o mapeamento do funcionário e a lista de EPIs em paralelo
      final results = await Future.wait([
        mapFuncRepo.getByFuncionarioId(widget.funcionario.id!),
        epiRepo.getAllEpis(),
      ]);

      _mapeamentoFuncionario = results[0] as MapeamentoFuncionarioModel?;
      final epis = results[1] as List<EpiModel>;

      if (mounted) {
        setState(() {
          _availableEpis = epis.where((e) => e.status && e.estoque > 0).toList();
          
          if (_mapeamentoFuncionario != null) {
            _mapeamentoController.text = _mapeamentoFuncionario!.mapeamento.nomeMapeamento;
          } else {
            _mapeamentoController.text = "Funcionário sem mapeamento vinculado";
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = "Erro ao carregar dados: $e";
        });
      }
    }
  }

  void _onEpiSelected(String epiName) {
    final epi = _availableEpis.firstWhere(
      (e) => e.nomeProduto == epiName,
      orElse: () => _availableEpis.first, // Fallback seguro
    );

    setState(() {
      _selectedEpi = epi;
      _validadeCaController.text = DateFormat('dd/MM/yyyy').format(epi.validadeCa);
      _estoqueController.text = '${epi.estoque.toInt()} ${epi.medida.nomeMedida}';
      
      // Lógica de Projeção de Validade
      // Data Entrega + Periodicidade (dias) = Data Validade do EPI
      _dataPrevisaoTroca = _dataEntrega.add(Duration(days: epi.periodicidade));
      _previsaoTrocaController.text = DateFormat('dd/MM/yyyy').format(_dataPrevisaoTroca!);
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_mapeamentoFuncionario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Funcionário não possui mapeamento de risco vinculado.')),
      );
      return;
    }

    if (_selectedEpi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um EPI para entrega.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Cria o modelo da ficha de entrega
      final novaFicha = FichaEpiModel(
        mapeamentoFuncionario: _mapeamentoFuncionario!,
        epi: _selectedEpi!,
        validadeEpi: _dataPrevisaoTroca!,
        status: true,
      );

      // Aqui chamaria o repositório para salvar a Ficha (ex: FichaEpiRepository)
      // Como o repository específico não foi listado, simulamos a passagem para o callback
      await Future.delayed(const Duration(milliseconds: 500)); // Simulação de rede
      
      widget.onSave(novaFicha);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('EPI entregue com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onClose();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao registrar entrega: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseAddDrawer(
      title: 'Entrega de EPI',
      subtitle: 'Registrar ficha para ${widget.funcionario.nomeFunc}',
      icon: Icons.assignment_returned_outlined,
      onClose: widget.onClose,
      onSave: _handleSave,
      formKey: _formKey,
      isSaving: _isSaving,
      isEditing: false,
      widthFactor: 0.45,
      child: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _error != null 
          ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
          : _buildForm(Theme.of(context)),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          // Seção: Vínculo Organizacional (Read-Only)
          InfoSection(
            title: 'Dados do Vínculo',
            icon: Icons.badge_outlined,
            child: Column(
              children: [
                CustomTextField(
                  controller: _mapeamentoController,
                  label: 'Mapeamento de Riscos (Atual)',
                  hint: '',
                  icon: Icons.fact_check_outlined,
                  enabled: false, // Não modificável conforme requisito
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: TextEditingController(text: widget.funcionario.matricula),
                        label: 'Matrícula',
                        hint: '',
                        icon: Icons.confirmation_number_outlined,
                        enabled: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: TextEditingController(text: widget.funcionario.vinculo.nomeVinculo),
                        label: 'Tipo de Vínculo',
                        hint: '',
                        icon: Icons.work_outline,
                        enabled: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Seção: Seleção e Detalhes do EPI
          InfoSection(
            title: 'Dados da Entrega',
            icon: Icons.medical_services_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAutocompleteField(
                  controller: _epiController,
                  label: 'Selecionar EPI',
                  hint: 'Busque pelo nome ou CA',
                  icon: Icons.search,
                  suggestions: _availableEpis.map((e) => e.nomeProduto).toList(),
                  // Ao selecionar, preenchemos os dados calculados
                  enabled: true,
                ),
                // Listener para detectar mudança no texto do controller e atualizar estado
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _epiController,
                  builder: (context, value, child) {
                    // Pequeno delay ou verificação para evitar rebuilds excessivos
                    if (_availableEpis.any((e) => e.nomeProduto == value.text) && 
                        _selectedEpi?.nomeProduto != value.text) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _onEpiSelected(value.text);
                      });
                    }
                    return const SizedBox.shrink();
                  },
                ),
                
                if (_selectedEpi != null) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Detalhes do Estoque e CA
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _estoqueController,
                          label: 'Estoque Disponível',
                          hint: '0',
                          icon: Icons.inventory_2_outlined,
                          enabled: false,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          controller: _validadeCaController,
                          label: 'Validade do C.A.',
                          hint: 'dd/mm/aaaa',
                          icon: Icons.verified_user_outlined,
                          enabled: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Detalhes da Projeção
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.date_range, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              "Projeção de Validade (Periodicidade: ${_selectedEpi!.periodicidade} dias)",
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _dataEntregaController,
                                label: 'Data da Entrega',
                                hint: '',
                                icon: Icons.today,
                                enabled: false, // Data atual fixa
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(Icons.arrow_forward),
                            ),
                            Expanded(
                              child: CustomTextField(
                                controller: _previsaoTrocaController,
                                label: 'Próxima Troca',
                                hint: 'dd/mm/aaaa',
                                icon: Icons.event_repeat,
                                enabled: false, // Calculado automaticamente
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}