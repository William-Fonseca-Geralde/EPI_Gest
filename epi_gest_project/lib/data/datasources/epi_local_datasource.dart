import 'package:epi_gest_project/domain/models/epi/epi_model.dart';

class EpiLocalDataSource {
  // Dados mockados (posteriormente será substituído por banco de dados)
  final List<EpiModel> _epis = [
    EpiModel(
      id: '1',
      nome: 'Capacete de Segurança',
      ca: '12345',
      categoria: 'Proteção de Cabeça',
      quantidadeEstoque: 50,
      valorUnitario: 45.90,
      dataValidade: DateTime(2025, 12, 31),
      fornecedor: 'EPI Tech Ltda',
      descricao: 'Capacete classe A com carneira',
    ),
    EpiModel(
      id: '2',
      nome: 'Luva de Segurança',
      ca: '23456',
      categoria: 'Proteção de Mãos',
      quantidadeEstoque: 120,
      valorUnitario: 12.50,
      dataValidade: DateTime(2024, 11, 15),
      fornecedor: 'Segurança Total',
      descricao: 'Luva de raspa com reforço',
    ),
    EpiModel(
      id: '3',
      nome: 'Óculos de Proteção',
      ca: '34567',
      categoria: 'Proteção Ocular',
      quantidadeEstoque: 80,
      valorUnitario: 25.00,
      dataValidade: DateTime(2026, 6, 30),
      fornecedor: 'Vision Safe',
      descricao: 'Óculos antiembaçante com proteção UV',
    ),
    EpiModel(
      id: '4',
      nome: 'Botina de Segurança',
      ca: '45678',
      categoria: 'Proteção de Pés',
      quantidadeEstoque: 35,
      valorUnitario: 89.90,
      dataValidade: DateTime(2024, 10, 20),
      fornecedor: 'Boot Safety',
      descricao: 'Botina com biqueira de aço',
    ),
    EpiModel(
      id: '5',
      nome: 'Protetor Auricular',
      ca: '56789',
      categoria: 'Proteção Auditiva',
      quantidadeEstoque: 200,
      valorUnitario: 8.75,
      dataValidade: DateTime(2025, 3, 15),
      fornecedor: 'Sound Block',
      descricao: 'Protetor tipo plug de silicone',
    ),
    EpiModel(
      id: '6',
      nome: 'Máscara PFF2',
      ca: '67890',
      categoria: 'Proteção Respiratória',
      quantidadeEstoque: 300,
      valorUnitario: 3.50,
      dataValidade: DateTime(2024, 12, 31),
      fornecedor: 'Respirar Bem',
      descricao: 'Máscara descartável com válvula',
    ),
    EpiModel(
      id: '7',
      nome: 'Cinto de Segurança',
      ca: '78901',
      categoria: 'Proteção contra Quedas',
      quantidadeEstoque: 25,
      valorUnitario: 150.00,
      dataValidade: DateTime(2026, 8, 20),
      fornecedor: 'Altura Segura',
      descricao: 'Cinto paraquedista com 3 pontos de ancoragem',
    ),
    EpiModel(
      id: '8',
      nome: 'Avental de Raspa',
      ca: '89012',
      categoria: 'Proteção do Tronco',
      quantidadeEstoque: 40,
      valorUnitario: 65.00,
      dataValidade: DateTime(2025, 5, 10),
      fornecedor: 'Proteção Industrial',
      descricao: 'Avental de raspa para soldador',
    ),
    EpiModel(
      id: '9',
      nome: 'Respirador Semifacial',
      ca: '90123',
      categoria: 'Proteção Respiratória',
      quantidadeEstoque: 15,
      valorUnitario: 85.50,
      dataValidade: DateTime(2024, 11, 5),
      fornecedor: 'Respirar Bem',
      descricao: 'Respirador com filtro químico',
    ),
    EpiModel(
      id: '10',
      nome: 'Protetor Facial',
      ca: '01234',
      categoria: 'Proteção Facial',
      quantidadeEstoque: 60,
      valorUnitario: 42.00,
      dataValidade: DateTime(2025, 9, 25),
      fornecedor: 'Vision Safe',
      descricao: 'Protetor facial com visor de policarbonato',
    ),
  ];

  Future<List<EpiModel>> getAllEpis() async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_epis);
  }

  Future<EpiModel?> getEpiById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _epis.firstWhere((epi) => epi.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addEpi(EpiModel epi) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _epis.add(epi);
  }

  Future<void> updateEpi(EpiModel epi) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _epis.indexWhere((e) => e.id == epi.id);
    if (index != -1) {
      _epis[index] = epi;
    }
  }

  Future<void> deleteEpi(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _epis.removeWhere((epi) => epi.id == id);
  }
}
