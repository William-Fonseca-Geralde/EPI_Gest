import 'package:flutter/material.dart';

class StorageLocationsWidget extends StatefulWidget {
  const StorageLocationsWidget({super.key});

  @override
  State<StorageLocationsWidget> createState() => StorageLocationsWidgetState();
}

class StorageLocationsWidgetState extends State<StorageLocationsWidget> {
  final List<Map<String, dynamic>> _locations = [];
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _productCodeController = TextEditingController();
  final _productDescriptionController = TextEditingController();

  // Lista mock de unidades (matriz/filial)
  final List<String> _units = ['Matriz', 'Filial SP', 'Filial RJ', 'Filial MG'];
  String? _selectedUnit;

  // Lista mock de produtos
  final Map<String, String> _products = {
    'EPI001': 'Luva de Proteção Nitrílica',
    'EPI002': 'Capacete de Segurança',
    'EPI003': 'Óculos de Proteção',
    'EPI004': 'Botina de Segurança',
    'EPI005': 'Protetor Auricular',
    'EPI006': 'Máscara Descartável',
    'EPI007': 'Avental Protetor',
    'EPI008': 'Luva de Latex',
    'EPI009': 'Protetor Facial',
    'EPI010': 'Cinto de Segurança',
  };

  // ------------------------------
  //  OPEN RIGHT SIDE DRAWER
  // ------------------------------
  void showAddDrawer() {
    _addressController.clear();
    _productCodeController.clear();
    _productDescriptionController.clear();
    _selectedUnit = null;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Fechar",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 500,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(-3, 0),
                  )
                ],
              ),
              child: _buildAddDrawer(),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, _, child) {
        final slide = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation);

        return SlideTransition(position: slide, child: child);
      },
    );
  }

  // ------------------------------
  // SAVE LOCATION
  // ------------------------------
  void _saveLocation() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _locations.add({
          'unit': _selectedUnit,
          'address': _addressController.text,
          'productCode': _productCodeController.text,
          'productDescription': _productDescriptionController.text,
        });
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Local ${_addressController.text} cadastrado!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _deleteLocation(int index) {
    setState(() {
      _locations.removeAt(index);
    });
  }

  void _updateProductDescription(String code) {
    if (_products.containsKey(code)) {
      setState(() {
        _productDescriptionController.text = _products[code]!;
      });
    } else {
      setState(() {
        _productDescriptionController.clear();
      });
    }
  }

  // ------------------------------
  // FUNÇÃO PARA ABRIR MODAL DE PESQUISA DE PRODUTOS
  // ------------------------------
  void _showProductSearch() {
    final theme = Theme.of(context);
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final filteredProducts = _products.entries.where((entry) {
              final query = searchQuery.toLowerCase();
              return entry.key.toLowerCase().contains(query) ||
                  entry.value.toLowerCase().contains(query);
            }).toList();

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 600,
                height: 500,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // HEADER DO MODAL
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Selecionar Produto',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // CAMPO DE PESQUISA
                    TextFormField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Pesquisar produto',
                        hintText: 'Digite o código ou descrição...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // LISTA DE PRODUTOS
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: filteredProducts.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 48,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Nenhum produto encontrado',
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = filteredProducts[index];
                                  return ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.inventory_2_outlined,
                                        color: theme.colorScheme.onPrimaryContainer,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(product.value),
                                    subtitle: Text('Código: ${product.key}'),
                                    trailing: FilledButton(
                                      onPressed: () {
                                        setState(() {
                                          _productCodeController.text = product.key;
                                          _productDescriptionController.text = product.value;
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Selecionar'),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  );
                                },
                              ),
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

  // ------------------------------
  // RIGHT DRAWER CONTENT - PADRÃO MODERNO
  // ------------------------------
  Widget _buildAddDrawer() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER - PADRÃO MODERNO
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            border: Border(
              bottom: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.place_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Novo Local de Armazenamento',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cadastre um novo local de armazenamento',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                tooltip: 'Fechar',
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),

        // FORM
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Dropdown Unidade - ESTILO MODERNO
                  _buildModernDropdown(
                    value: _selectedUnit,
                    label: 'Unidade Vinculada*',
                    hint: 'Selecione uma unidade',
                    icon: Icons.business_outlined,
                    items: _units,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedUnit = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, selecione uma unidade';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Campo Endereço - ESTILO MODERNO
                  _buildModernTextField(
                    controller: _addressController,
                    label: 'Endereço*',
                    hint: 'Ex: Rua A, 123 - Setor B, Prateleira 4',
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o endereço';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Campo Código do Produto - ESTILO MODERNO COM LUPINHA
                  TextFormField(
                    controller: _productCodeController,
                    onChanged: _updateProductDescription,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o código do produto';
                      }
                      if (!_products.containsKey(value)) {
                        return 'Código de produto não encontrado';
                      }
                      return null;
                    },
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Código do Produto*',
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      hintText: 'Ex: EPI001, EPI002, EPI003',
                      prefixIcon: Icon(
                        Icons.qr_code_outlined,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _showProductSearch,
                        tooltip: 'Pesquisar produtos',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Campo Descrição do Produto - ESTILO MODERNO
                  _buildModernTextField(
                    controller: _productDescriptionController,
                    label: 'Descrição do Produto',
                    hint: 'Descrição será preenchida automaticamente',
                    icon: Icons.description_outlined,
                    enabled: false,
                    readOnly: true,
                  ),
                ],
              ),
            ),
          ),
        ),

        // FOOTER - BOTÕES MODERNOS
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Botão Cancelar
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface,
                      side: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.5),
                      ),
                      backgroundColor: theme.colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.close, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "Cancelar",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Botão Salvar
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: _saveLocation,
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "Adicionar Local",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------
  // COMPONENTES MODERNOS
  // ------------------------------

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool enabled = true,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(
        color: enabled ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.6),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        enabled: enabled,
        filled: !enabled,
        fillColor: !enabled ? theme.colorScheme.surfaceVariant.withOpacity(0.3) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines > 1 ? 16 : 12,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildModernDropdown({
    required String? value,
    required String label,
    required String hint,
    required IconData icon,
    required List<String> items,
    required void Function(String?)? onChanged,
    required String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((String unit) {
        return DropdownMenuItem(
          value: unit,
          child: Text(unit),
        );
      }).toList(),
      onChanged: onChanged,
      style: TextStyle(
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      icon: Icon(
        Icons.arrow_drop_down_outlined,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      borderRadius: BorderRadius.circular(12),
      validator: validator,
    );
  }

  // ------------------------------
  // MAIN LIST SCREEN - MODERNIZADA
  // ------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(24),
      child: _locations.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.place_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Nenhum local cadastrado',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Clique em "Novo Local" para começar',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  child: FilledButton.icon(
                    onPressed: showAddDrawer,
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Novo Local',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER DA LISTA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Locais de Armazenamento',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: showAddDrawer,
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text(
                        'Novo Local',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // LISTA DE LOCAIS
                Expanded(
                  child: ListView.builder(
                    itemCount: _locations.length,
                    itemBuilder: (context, index) {
                      final location = _locations[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: theme.colorScheme.surface,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.place,
                              color: theme.colorScheme.onPrimaryContainer,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            'Unidade: ${location['unit']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Endereço: ${location['address']}',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Produto: ${location['productDescription']}',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Código: ${location['productCode']}',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: theme.colorScheme.error,
                            ),
                            onPressed: () => _deleteLocation(index),
                            tooltip: 'Excluir local',
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _productCodeController.dispose();
    _productDescriptionController.dispose();
    super.dispose();
  }
}