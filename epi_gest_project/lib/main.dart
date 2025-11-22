import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/config/theme_notifier.dart';
import 'package:epi_gest_project/data/services/employee_service.dart';
import 'package:epi_gest_project/data/services/funcionario_repository.dart';
import 'package:epi_gest_project/data/services/turno_repository.dart';
import 'package:epi_gest_project/data/services/vinculo_repository.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:epi_gest_project/ui/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  Client client = Client();
  client
      .setEndpoint('https://nyc.cloud.appwrite.io/v1')
      .setProject('68ac56f3001bcef1296e')
      .setLocale('pt_BR');
  runApp(
    MultiProvider(
      providers: [
        Provider<FuncionarioRepository>(
          create: (_) => FuncionarioRepository(TablesDB(client)),
        ),
        Provider<VinculoRepository>(
          create: (_) => VinculoRepository(TablesDB(client)),
        ),
        Provider<TurnoRepository>(
          create: (_) => TurnoRepository(TablesDB(client)),
        ),
        Provider<EmployeeService>(create: (_) => EmployeeService(client)),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          title: 'EPI Gest',
          debugShowCheckedModeBanner: false,
          themeMode: themeNotifier.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          home: const HomePage(),
        );
      },
    );
  }
}
