// lib/features/home/presentation/widgets/company_selector_widget.dart
import 'package:flutter/material.dart';

class CompanySelectorWidget extends StatelessWidget {
  final String currentCompany;
  final String currentCompanyType;
  final VoidCallback? onCompanyChanged;

  const CompanySelectorWidget({
    super.key,
    required this.currentCompany,
    required this.currentCompanyType,
    this.onCompanyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentCompany,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        currentCompanyType,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          );
        },
        menuChildren: [
          // Matriz
          MenuItemButton(
            leadingIcon: Icon(
              Icons.apartment,
              color: Theme.of(context).colorScheme.primary,
            ),
            trailingIcon: currentCompanyType == 'Matriz'
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Empresa Principal',
                  style: TextStyle(
                    fontWeight: currentCompanyType == 'Matriz'
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                Text(
                  'Matriz',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            onPressed: () {
              // Implementar troca para matriz
              onCompanyChanged?.call();
            },
          ),
          const Divider(),
          // Filiais
          MenuItemButton(
            leadingIcon: Icon(
              Icons.store_outlined,
              color: Colors.blue.shade700,
            ),
            trailingIcon: currentCompany == 'Filial São Paulo'
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filial São Paulo',
                  style: TextStyle(
                    fontWeight: currentCompany == 'Filial São Paulo'
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                Text(
                  'Filial - SP',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            onPressed: () {
              // Implementar troca para Filial SP
              onCompanyChanged?.call();
            },
          ),
          MenuItemButton(
            leadingIcon: Icon(
              Icons.store_outlined,
              color: Colors.green.shade700,
            ),
            trailingIcon: currentCompany == 'Filial Rio de Janeiro'
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filial Rio de Janeiro',
                  style: TextStyle(
                    fontWeight: currentCompany == 'Filial Rio de Janeiro'
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                Text(
                  'Filial - RJ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            onPressed: () {
              // Implementar troca para Filial RJ
              onCompanyChanged?.call();
            },
          ),
          MenuItemButton(
            leadingIcon: Icon(
              Icons.store_outlined,
              color: Colors.orange.shade700,
            ),
            trailingIcon: currentCompany == 'Filial Belo Horizonte'
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filial Belo Horizonte',
                  style: TextStyle(
                    fontWeight: currentCompany == 'Filial Belo Horizonte'
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                Text(
                  'Filial - MG',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            onPressed: () {
              // Implementar troca para Filial MG
              onCompanyChanged?.call();
            },
          ),
          MenuItemButton(
            leadingIcon: Icon(
              Icons.analytics_outlined, // ou Icons.bar_chart_outlined
              color: Colors.purple.shade700, // Roxo para análise/dados
            ),
            trailingIcon: currentCompany == 'Análise Geral'
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Análise Geral', // Corrigi "Analise" para "Análise"
                  style: TextStyle(
                    fontWeight: currentCompany == 'Análise Geral'
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                Text(
                  'União de todas as Unidades',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            onPressed: () {
              onCompanyChanged?.call();
            },
          ),
        ],
      ),
    );
  }
}
