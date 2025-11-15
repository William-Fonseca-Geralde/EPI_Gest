import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SupplierRegistrationWidget extends StatefulWidget {
  const SupplierRegistrationWidget({super.key});

  @override
  State<SupplierRegistrationWidget> createState() => SupplierRegistrationWidgetState();
}

class SupplierRegistrationWidgetState extends State<SupplierRegistrationWidget> {
  final List<Map<String, dynamic>> _suppliers = [];
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _cnpjController = TextEditingController();
  bool _statusAtiva = true; // STATUS NO PADRÃO

  void showAddDrawer() {
    _companyNameController.clear();
    _cnpjController.clear();
    _statusAtiva = true;

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

  void _saveSupplier() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _suppliers.add({
          'companyName': _companyNameController.text,
          'cnpj': _cnpjController.text,
          'statusAtiva': _statusAtiva, // STATUS NO PADRÃO
        });
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fornecedor ${_companyNameController.text} cadastrado!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _deleteSupplier(int index) {
    setState(() {
      _suppliers.removeAt(index);
    });
  }

  void _toggleSupplierStatus(int index) {
    setState(() {
      _suppliers[index]['statusAtiva'] = !_suppliers[index]['statusAtiva'];
    });
  }

  String? _validateCNPJ(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o CNPJ';
    }
    
    final cleanedCNPJ = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanedCNPJ.length != 14) {
      return 'CNPJ deve ter 14 dígitos';
    }
    
    if (_suppliers.any((supplier) => supplier['cnpj'] == cleanedCNPJ)) {
      return 'CNPJ já cadastrado';
    }
    
    return null;
  }

  String _formatCNPJ(String cnpj) {
    final cleanedCNPJ = cnpj.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanedCNPJ.length != 14) return cnpj;
    
    return '${cleanedCNPJ.substring(0, 2)}.${cleanedCNPJ.substring(2, 5)}.${cleanedCNPJ.substring(5, 8)}/${cleanedCNPJ.substring(8, 12)}-${cleanedCNPJ.substring(12)}';
  }

  Widget _buildAddDrawer() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  Icons.business_outlined,
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
                      'Novo Fornecedor',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cadastre um novo fornecedor',
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

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Campo Razão Social
                  _buildModernTextField(
                    controller: _companyNameController,
                    label: 'Razão Social*',
                    hint: 'Ex: Empresa XYZ Ltda',
                    icon: Icons.business_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a razão social';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Campo CNPJ
                  _buildModernTextField(
                    controller: _cnpjController,
                    label: 'CNPJ*',
                    hint: 'Ex: 12.345.678/0001-90',
                    icon: Icons.badge_outlined,
                    validator: _validateCNPJ,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(14),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Switch Status - PADRÃO IDÊNTICO
                  _buildModernSwitch(
                    value: _statusAtiva,
                    onChanged: (v) => setState(() => _statusAtiva = v),
                    label: 'Status do Fornecedor',
                    activeText: 'Ativo',
                    inactiveText: 'Inativo',
                  ),
                ],
              ),
            ),
          ),
        ),

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
              
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: _saveSupplier,
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
                          "Adicionar Fornecedor",
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

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?)? validator,
    String? helperText,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
          ),
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            hintText: hint,
            helperText: helperText,
            helperStyle: TextStyle(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: validator,
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }

  // SWITCH NO PADRÃO IDÊNTICO
  Widget _buildModernSwitch({
    required bool value,
    required void Function(bool)? onChanged,
    required String label,
    required String activeText,
    required String inactiveText,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.toggle_on_outlined,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: MaterialStateProperty.all(theme.colorScheme.onPrimary),
            trackColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return theme.colorScheme.primary;
              }
              return theme.colorScheme.surfaceVariant;
            }),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: value 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value ? activeText : inactiveText,
              style: TextStyle(
                color: value ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(24),
      child: _suppliers.isEmpty
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
                    Icons.business_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Nenhum fornecedor cadastrado',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Clique em "Novo Fornecedor" para começar',
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
                      'Novo Fornecedor',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fornecedores Cadastrados',
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
                        'Novo Fornecedor',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Expanded(
                  child: ListView.builder(
                    itemCount: _suppliers.length,
                    itemBuilder: (context, index) {
                      final supplier = _suppliers[index];
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
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.business,
                              color: theme.colorScheme.onPrimaryContainer,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            supplier['companyName']!,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CNPJ: ${_formatCNPJ(supplier['cnpj']!)}',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: supplier['statusAtiva'] 
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  supplier['statusAtiva'] ? 'Ativo' : 'Inativo',
                                  style: TextStyle(
                                    color: supplier['statusAtiva'] ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  supplier['statusAtiva'] ? Icons.toggle_on : Icons.toggle_off,
                                  color: supplier['statusAtiva'] 
                                      ? theme.colorScheme.primary 
                                      : theme.colorScheme.outline,
                                ),
                                onPressed: () => _toggleSupplierStatus(index),
                                tooltip: supplier['statusAtiva'] ? 'Desativar' : 'Ativar',
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: theme.colorScheme.error,
                                ),
                                onPressed: () => _deleteSupplier(index),
                                tooltip: 'Excluir fornecedor',
                              ),
                            ],
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
    _companyNameController.dispose();
    _cnpjController.dispose();
    super.dispose();
  }
}