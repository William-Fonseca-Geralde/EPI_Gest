import 'package:flutter/material.dart';
import 'package:epi_gest_project/ui/organizational_structure/widgets/epi_mapping_drawer.dart';

class EpiMapingWidget extends StatefulWidget {
  const EpiMapingWidget({super.key});

  @override
  State<EpiMapingWidget> createState() => EpiMapingWidgetState();
}

class EpiMapingWidgetState extends State<EpiMapingWidget> {
  void showAddDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Novo Mapeamento de EPI',
      pageBuilder: (context, _, __) => EpiMappingDrawer(
        onClose: () => Navigator.of(context).pop(),
        onSave: () {
          // Recarrega os dados após salvar
          _loadMapeamentos();
        },
      ),
    );
  }

  void _loadMapeamentos() {
    // Implemente aqui a lógica para carregar os mapeamentos existentes
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_turned_in_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Nenhum mapeamento cadastrado ainda',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}