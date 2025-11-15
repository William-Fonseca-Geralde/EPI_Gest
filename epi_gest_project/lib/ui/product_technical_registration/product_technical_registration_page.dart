import 'package:flutter/material.dart';
import 'widgets/measurement_units_widget.dart';
import 'widgets/product_categories_widget.dart';
import 'widgets/storage_locations_widget.dart';
import 'widgets/supplier_registration_widget.dart';
import 'widgets/brands_registration_widget.dart'; // NOVA IMPORT

class ProductTechnicalRegistrationPage extends StatefulWidget {
  const ProductTechnicalRegistrationPage({super.key});

  @override
  State<ProductTechnicalRegistrationPage> createState() =>
      _ProductTechnicalRegistrationPageState();
}

class _ProductTechnicalRegistrationPageState
    extends State<ProductTechnicalRegistrationPage> {
  int? _selectedSection;

  // Keys para controlar cada widget - ATUALIZADO
  final GlobalKey<MeasurementUnitsWidgetState> _measurementUnitsKey = GlobalKey();
  final GlobalKey<ProductCategoriesWidgetState> _productCategoriesKey = GlobalKey();
  final GlobalKey<StorageLocationsWidgetState> _storageLocationsKey = GlobalKey();
  final GlobalKey<SupplierRegistrationWidgetState> _supplierRegistrationKey = GlobalKey();
  final GlobalKey<BrandsRegistrationWidgetState> _brandsRegistrationKey = GlobalKey(); // NOVO

  final List<Map<String, dynamic>> _sections = [
    {
      'title': 'Unidades de Medida',
      'icon': Icons.straighten_outlined,
      'description': 'Gerencie unidades como Unidade, Caixa, Par',
      'index': 0,
    },
    {
      'title': 'Categorias de Produtos',
      'icon': Icons.category_outlined,
      'description': 'Configure categorias como Luvas, Capacetes, Botinas',
      'index': 1,
    },
    {
      'title': 'Locais de Armazenamento',
      'icon': Icons.place_outlined,
      'description': 'Gerencie endereços e locais de estoque',
      'index': 2,
    },
    {
      'title': 'Fornecedores',
      'icon': Icons.business_outlined,
      'description': 'Cadastre fornecedores e seus CNPJs',
      'index': 3,
    },
    { // NOVA SEÇÃO
      'title': 'Marcas',
      'icon': Icons.branding_watermark_outlined,
      'description': 'Gerencie marcas de produtos',
      'index': 4,
    },
  ];

  void _onSectionSelected(int index) {
    setState(() {
      _selectedSection = index;
    });
  }

  Widget _getSectionWidget(int index) {
    switch (index) {
      case 0:
        return MeasurementUnitsWidget(key: _measurementUnitsKey);
      case 1:
        return ProductCategoriesWidget(key: _productCategoriesKey);
      case 2:
        return StorageLocationsWidget(key: _storageLocationsKey);
      case 3:
        return SupplierRegistrationWidget(key: _supplierRegistrationKey);
      case 4: // NOVO
        return BrandsRegistrationWidget(key: _brandsRegistrationKey);
      default:
        return const Center(child: Text('Seção não encontrada'));
    }
  }

  String _getAddButtonText(int sectionIndex) {
    switch (sectionIndex) {
      case 0:
        return 'Nova Unidade';
      case 1:
        return 'Nova Categoria';
      case 2:
        return 'Novo Local';
      case 3:
        return 'Novo Fornecedor';
      case 4: // NOVO
        return 'Nova Marca';
      default:
        return 'Adicionar';
    }
  }

  void _triggerAddAction(int sectionIndex) {
    switch (sectionIndex) {
      case 0:
        _measurementUnitsKey.currentState?.showAddDrawer();
        break;
      case 1:
        _productCategoriesKey.currentState?.showAddDrawer();
        break;
      case 2:
        _storageLocationsKey.currentState?.showAddDrawer();
        break;
      case 3:
        _supplierRegistrationKey.currentState?.showAddDrawer();
        break;
      case 4: // NOVO
        _brandsRegistrationKey.currentState?.showAddDrawer();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(flex: 2, child: _buildSelectionPanel()),
          const VerticalDivider(width: 1),
          Expanded(flex: 3, child: _buildConfigurationPanel()),
        ],
      ),
    );
  }

  Widget _buildSelectionPanel() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12)),
          ),
          child: Row(
            spacing: 16,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.app_registration,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 40,
                ),
              ),
              Column(
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cadastros Técnicos',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    '${_sections.length} seções de cadastro',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            itemCount: _sections.length,
            itemBuilder: (context, index) {
              final section = _sections[index];
              final isSelected = _selectedSection == index;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSectionCard(
                  icon: section['icon'],
                  title: section['title'],
                  description: section['description'],
                  isSelected: isSelected,
                  onTap: () => _onSectionSelected(index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: isSelected
          ? colorScheme.primaryContainer
          : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimaryContainer.withOpacity(0.8)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: colorScheme.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigurationPanel() {
    if (_selectedSection == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.app_registration_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Selecione um tipo de Cadastro',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha uma seção no painel lateral para começar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  spacing: 16,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        _sections[_selectedSection!]['icon'],
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 40,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        spacing: 4,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _sections[_selectedSection!]['title'],
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.8,
                                  height: 1.1,
                                ),
                          ),
                          Text(
                            _sections[_selectedSection!]['description'],
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  _triggerAddAction(_selectedSection!);
                },
                icon: const Icon(Icons.add),
                label: Text(_getAddButtonText(_selectedSection!)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _getSectionWidget(_selectedSection!),
          ),
        ),
      ],
    );
  }
}