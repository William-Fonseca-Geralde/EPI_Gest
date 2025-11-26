import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/config/theme_notifier.dart';
import 'package:epi_gest_project/data/services/epi_repository.dart';
import 'package:epi_gest_project/data/services/organizational_structure/cargo_repository.dart';
import 'package:epi_gest_project/data/services/product_technical_registration/armazem_repository.dart';
import 'package:epi_gest_project/data/services/product_technical_registration/categoria_repository.dart';
import 'package:epi_gest_project/data/services/funcionario_repository.dart';
import 'package:epi_gest_project/data/services/organizational_structure/mapeamento_epi_repository.dart';
import 'package:epi_gest_project/data/services/mapeamento_funcionario_repository.dart';
import 'package:epi_gest_project/data/services/organizational_structure/turno_repository.dart';
import 'package:epi_gest_project/data/services/organizational_structure/riscos_repository.dart';
import 'package:epi_gest_project/data/services/organizational_structure/setor_repository.dart';
import 'package:epi_gest_project/data/services/organizational_structure/unidade_repository.dart';
import 'package:epi_gest_project/data/services/organizational_structure/vinculo_repository.dart';
import 'package:epi_gest_project/data/services/product_technical_registration/fornecedor_repository.dart';
import 'package:epi_gest_project/data/services/product_technical_registration/marcas_repository.dart';
import 'package:epi_gest_project/data/services/product_technical_registration/medida_repository.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:epi_gest_project/ui/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  Client client = Client();
  final databases = TablesDB(client);
  client
      .setEndpoint('https://nyc.cloud.appwrite.io/v1')
      .setProject('68ac56f3001bcef1296e')
      .setLocale('pt_BR');
  runApp(
    MultiProvider(
      providers: [
        Provider<FuncionarioRepository>(create: (_) => FuncionarioRepository(databases)),
        Provider<VinculoRepository>(create: (_) => VinculoRepository(databases)),
        Provider<TurnoRepository>(create: (_) => TurnoRepository(databases)),
        Provider<MapeamentoFuncionarioRepository>(create: (_) => MapeamentoFuncionarioRepository(databases)),
        Provider<EpiRepository>(create: (_) => EpiRepository(databases)),

        // Repositórios da Estrutura Organizacional
        Provider<UnidadeRepository>(create: (_) => UnidadeRepository(databases)),
        Provider<SetorRepository>(create: (_) => SetorRepository(databases)),
        Provider<CargoRepository>(create: (_) => CargoRepository(databases)),
        Provider<RiscosRepository>(create: (_) => RiscosRepository(databases)),
        Provider<MapeamentoEpiRepository>(create: (_) => MapeamentoEpiRepository(databases)),
        Provider<CategoriaRepository>(create: (_) => CategoriaRepository(databases)),

        Provider<MarcasRepository>(create: (_) => MarcasRepository(databases)),
        Provider<MedidaRepository>(create: (_) => MedidaRepository(databases)),
        Provider<FornecedorRepository>(create: (_) => FornecedorRepository(databases)),
        Provider<ArmazemRepository>(create: (_) => ArmazemRepository(databases)),

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
