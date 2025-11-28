import 'package:epi_gest_project/ui/dashboard/dashboard_page.dart';
import 'package:epi_gest_project/ui/employees/employees_page.dart';
import 'package:epi_gest_project/ui/gestao_epi/exchange_page.dart';
import 'package:epi_gest_project/ui/home/widgets/company_selector_widget.dart';
import 'package:epi_gest_project/ui/home/widgets/perfil_widget.dart';
import 'package:epi_gest_project/ui/epis/epi_page.dart';
import 'package:epi_gest_project/ui/organizational_structure/organizational_structure_page.dart';
import 'package:epi_gest_project/ui/product_technical_registration/product_technical_registration_page.dart'; // NOVA IMPORT
import 'package:epi_gest_project/ui/reports/reports_page.dart';
import 'package:epi_gest_project/ui/settings/settings_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isRailExtended = true;
  final int _pendingExchanges = 5;

  final List<Widget> _pages = [
    const DashboardPage(),
    const EmployeesPage(),
    const EpiPage(),
    const ExchangePage(),
    const OrganizationalStructurePage(),
    const ProductTechnicalRegistrationPage(),
    const ReportsPage(),
    const SettingsPage(),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleRail() {
    setState(() {
      _isRailExtended = !_isRailExtended;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EPI Gest',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(_isRailExtended ? Icons.menu_open : Icons.menu),
          onPressed: _toggleRail,
          tooltip: _isRailExtended ? 'Retrair menu' : 'Expandir menu',
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 16),
        actions: [
          Row(
            spacing: 8,
            children: [
              CompanySelectorWidget(
                currentCompany: 'Empresa Principal',
                currentCompanyType: 'Matriz',
                onCompanyChanged: () {
                  setState(() {
                    
                  });
                },
              ),
              PerfilWidget(),
            ],
          ),
        ],
      ),
      body: Row(
        children: [
          Column(
            children: [
              Expanded(
                child: NavigationRail(
                  extended: _isRailExtended,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onDestinationSelected,
                  labelType: _isRailExtended
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.selected,
                  destinations: [
                    const NavigationRailDestination(
                      icon: Icon(Icons.analytics_outlined),
                      selectedIcon: Icon(Icons.analytics),
                      label: Text('Dashboard'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.people_outline),
                      selectedIcon: Icon(Icons.people),
                      label: Text('Funcionários'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.inventory_2_outlined),
                      selectedIcon: Icon(Icons.inventory_2),
                      label: Text('Estoque'),
                    ),
                    NavigationRailDestination(
                      icon: Badge(
                        label: Text(_pendingExchanges.toString()),
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.swap_horiz_outlined),
                      ),
                      selectedIcon: Badge(
                        label: Text(_pendingExchanges.toString()),
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.swap_horiz),
                      ),
                      label: const Text('Entrega de EPIs'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.account_tree_outlined),
                      selectedIcon: Icon(Icons.account_tree),
                      label: Column(
                        spacing: 1,
                        crossAxisAlignment: _isRailExtended ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                        children: [
                          Text('Estrutura'),
                          Text('Organizacional'),
                        ],
                      ),
                    ),
                    NavigationRailDestination( // NOVO DESTINO
                      icon: Icon(Icons.app_registration_outlined),
                      selectedIcon: Icon(Icons.app_registration),
                      label: Column(
                        spacing: 1,
                        crossAxisAlignment: _isRailExtended ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                        children: [
                          Text('Cadastros'),
                          Text('Técnicos'),
                        ],
                      ),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.assessment_outlined),
                      selectedIcon: Icon(Icons.assessment),
                      label: Text('Relatórios'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Configurações'),
                    ),
                  ],
                ),
              ),
              Container(
                width: _isRailExtended ? 256 : 72,
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Card.outlined(
                  child: MenuAnchor(
                    builder: (context, controller, child) {
                      return InkWell(
                        onTap: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                        borderRadius: BorderRadius.circular(11),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: _isRailExtended
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.headset_mic_outlined,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Suporte',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 32),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Entre em contato conosco',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 11,
                                                ),
                                          ),
                                          Text(
                                            'Chat 24/7 disponível',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 11,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Icon(
                                    Icons.headset_mic_outlined,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                        ),
                      );
                    },
                    menuChildren: [
                      MenuItemButton(
                        leadingIcon: const Icon(Icons.email_outlined),
                        child: const Text('suporte@epigest.com'),
                        onPressed: () {
                          // Abrir cliente de email
                        },
                      ),
                      MenuItemButton(
                        leadingIcon: const Icon(Icons.phone_outlined),
                        child: const Text('(11) 1234-5678'),
                        onPressed: () {
                          // Discar telefone
                        },
                      ),
                      MenuItemButton(
                        leadingIcon: const Icon(Icons.chat_outlined),
                        child: const Text('Chat ao vivo'),
                        onPressed: () {
                          // Abrir chat
                        },
                      ),
                      MenuItemButton(
                        leadingIcon: const Icon(Icons.help_outline),
                        child: const Text('Central de Ajuda'),
                        onPressed: () {
                          // Abrir central de ajuda
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Card.outlined(
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: _pages[_selectedIndex],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}