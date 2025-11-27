import 'package:epi_gest_project/ui/widgets/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BasicInfoSection extends StatelessWidget {
  final TextEditingController codigoController;
  final TextEditingController caController;
  final TextEditingController validadeController;
  final TextEditingController nomeController;
  final VoidCallback onSelectDate;

  const BasicInfoSection({
    super.key,
    required this.codigoController,
    required this.caController,
    required this.validadeController,
    required this.nomeController,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: codigoController,
                label: 'Código/ID',
                hint: 'hint',
                icon: Icons.qr_code_2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Obrigatório';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: caController,
                label: 'CA',
                hint: '',
                icon: Icons.verified_user_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CustomDateField(
          controller: validadeController,
          label: 'Validade do CA',
          hint: 'dd/mm/aaaa',
          icon: Icons.calendar_today_outlined,
          onTap: onSelectDate,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: nomeController,
          label: 'Nome do Produto',
          icon: Icons.label_outline,
          hint: '',
          validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
        ),
      ],
    );
  }
}

class StockSection extends StatelessWidget {
  final TextEditingController quantidadeController;
  final TextEditingController valorController;
  final TextEditingController estoqueMinController;
  final TextEditingController estoqueMaxController;
  final TextEditingController unidadeController;
  final List<String> unidadesSugeridas;
  final GlobalKey unidadeButtonKey;
  final VoidCallback onAddUnidade;

  const StockSection({
    super.key,
    required this.quantidadeController,
    required this.valorController,
    required this.estoqueMinController,
    required this.estoqueMaxController,
    required this.unidadeController,
    required this.unidadesSugeridas,
    required this.unidadeButtonKey,
    required this.onAddUnidade,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: quantidadeController,
                label: 'Quantidade Atual',
                hint: '',
                icon: Icons.inventory_2_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: valorController,
                label: 'Valor Unitário',
                hint: '',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: estoqueMinController,
                label: 'Estoque Mínimo',
                hint: '',
                icon: Icons.arrow_downward_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: estoqueMaxController,
                label: 'Estoque Máximo',
                hint: '',
                icon: Icons.arrow_upward_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomAutocompleteField(
          controller: unidadeController,
          label: 'Unidade de Medida',
          hint: '',
          showAddButton: true,
          icon: Icons.scale_outlined,
          suggestions: unidadesSugeridas,
          addButtonKey: unidadeButtonKey,
          onAddPressed: onAddUnidade,
        ),
      ],
    );
  }
}

class DetailsSection extends StatelessWidget {
  final TextEditingController periodicidadeController;
  final TextEditingController observacoesController;

  const DetailsSection({
    super.key,
    required this.periodicidadeController,
    required this.observacoesController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: periodicidadeController,
          label: 'Periodicidade de Troca (dias)',
          hint: '',
          icon: Icons.update_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: observacoesController,
          label: 'Observações',
          hint: '',
          icon: Icons.description_outlined,
          maxLines: 3,
        ),
      ],
    );
  }
}

class StatusSection extends StatelessWidget {
  final bool statusAtivo;
  final ValueChanged<bool> onStatusChanged;

  const StatusSection({
    super.key,
    required this.statusAtivo,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.toggle_on_outlined,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status do Produto', style: theme.textTheme.bodyLarge),
                Text(
                  statusAtivo ? 'Ativo no sistema' : 'Inativo no sistema',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: statusAtivo, onChanged: onStatusChanged),
        ],
      ),
    );
  }
}

class CategorySupplierSection extends StatelessWidget {
  final TextEditingController categoriaController;
  final TextEditingController marcaController;
  final TextEditingController fornecedorController;
  final TextEditingController localizacaoController;
  final List<String> categoriasSugeridas;
  final List<String> marcasSugeridas;
  final List<String> fornecedoresSugeridos;
  final List<String> localizacoesSugeridas;
  final GlobalKey categoriaButtonKey;
  final GlobalKey marcaButtonKey;
  final GlobalKey fornecedorButtonKey;
  final GlobalKey localizacaoButtonKey;
  final VoidCallback onAddCategoria;
  final VoidCallback onAddMarca;
  final VoidCallback onAddFornecedor;
  final VoidCallback onAddLocalizacao;

  const CategorySupplierSection({
    super.key,
    required this.categoriaController,
    required this.marcaController,
    required this.fornecedorController,
    required this.localizacaoController,
    required this.categoriasSugeridas,
    required this.marcasSugeridas,
    required this.fornecedoresSugeridos,
    required this.localizacoesSugeridas,
    required this.categoriaButtonKey,
    required this.marcaButtonKey,
    required this.fornecedorButtonKey,
    required this.localizacaoButtonKey,
    required this.onAddCategoria,
    required this.onAddMarca,
    required this.onAddFornecedor,
    required this.onAddLocalizacao,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAutocompleteField(
          controller: categoriaController,
          label: 'Categoria/Grupo',
          hint: '',
          showAddButton: true,
          icon: Icons.category_outlined,
          suggestions: categoriasSugeridas,
          addButtonKey: categoriaButtonKey,
          onAddPressed: onAddCategoria,
        ),
        const SizedBox(height: 16),
        CustomAutocompleteField(
          controller: marcaController,
          label: 'Marca',
          hint: '',
          showAddButton: true,
          icon: Icons.branding_watermark_outlined,
          suggestions: marcasSugeridas,
          addButtonKey: marcaButtonKey,
          onAddPressed: onAddMarca,
        ),
        const SizedBox(height: 16),
        CustomAutocompleteField(
          controller: fornecedorController,
          label: 'Fornecedor',
          hint: '',
          showAddButton: true,
          icon: Icons.store_outlined,
          suggestions: fornecedoresSugeridos,
          addButtonKey: fornecedorButtonKey,
          onAddPressed: onAddFornecedor,
        ),
        const SizedBox(height: 16),
        CustomAutocompleteField(
          controller: localizacaoController,
          label: 'Localização Física',
          hint: '',
          showAddButton: true,
          icon: Icons.location_on_outlined,
          suggestions: localizacoesSugeridas,
          addButtonKey: localizacaoButtonKey,
          onAddPressed: onAddLocalizacao,
        ),
      ],
    );
  }
}