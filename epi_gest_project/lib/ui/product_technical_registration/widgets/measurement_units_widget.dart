import 'package:flutter/material.dart';

class MeasurementUnitsWidget extends StatefulWidget {
  const MeasurementUnitsWidget({super.key});

  @override
  State<MeasurementUnitsWidget> createState() => MeasurementUnitsWidgetState();
}

class MeasurementUnitsWidgetState extends State<MeasurementUnitsWidget> {
  void showAddDrawer() {
    // Implementar drawer de adição
    print('Abrir drawer para Nova Unidade');
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Unidades de Medida Widget - Em desenvolvimento'),
    );
  }
}