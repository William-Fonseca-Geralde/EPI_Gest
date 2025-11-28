import 'package:appwrite/appwrite.dart';
import 'package:epi_gest_project/core/constants/appwrite_constants.dart';
import 'package:epi_gest_project/data/services/base_repository.dart';
import 'package:epi_gest_project/domain/models/entradas_model.dart';
import 'package:epi_gest_project/domain/models/entradas_epi_model.dart';
import 'package:epi_gest_project/data/services/epi_repository.dart';
import 'package:epi_gest_project/data/services/entradas_epi_repository.dart';

class EntradasRepository extends BaseRepository<EntradasModel> {
  final EpiRepository _epiRepository;
  final EntradasEpiRepository _entradasEpiRepository;

  EntradasRepository(
    TablesDB databases, 
    this._epiRepository, 
    this._entradasEpiRepository
  ) : super(databases, AppwriteConstants.databaseEntradas);

  @override
  EntradasModel fromMap(Map<String, dynamic> map) {
    return EntradasModel.fromMap(map);
  }

  Future<List<EntradasModel>> getAllEntradas() async {
    return await getAll([
      Query.orderDesc('\$createdAt'),
      Query.select(['*', 'fornecedor_id.*', 'entradas_epi_id.*']) // Expande relacionamentos
    ]);
  }

  Future<void> registrarEntradaCompleta({
    required EntradasModel entradaHeader,
    required List<EntradasEpiModel> itens,
  }) async {
    List<String> idsItensSalvos = [];

    try {
      for (var item in itens) {
        final epiAtual = await _epiRepository.get(item.epi.id!);
        
        final double valorTotalEstoqueAtual = epiAtual.estoque * epiAtual.valor;
        final double valorTotalEntrada = item.quantidade * item.valor;
        final double novoEstoque = epiAtual.estoque + item.quantidade;
        
        double novoValorUnitario = 0.0;
        if (novoEstoque > 0) {
          novoValorUnitario = (valorTotalEstoqueAtual + valorTotalEntrada) / novoEstoque;
        }

        final itemSalvo = await _entradasEpiRepository.create(item);
        idsItensSalvos.add(itemSalvo.id!);

        await _epiRepository.updateEstoqueEValor(epiAtual.id!, novoEstoque, novoValorUnitario);
      }

      final mapHeader = entradaHeader.toMap();
      mapHeader['entradas_epi_id'] = idsItensSalvos;

      await databases.createRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: tableId,
        rowId: ID.unique(),
        data: mapHeader,
      );

    } catch (e) {
      throw Exception('Erro ao registrar entrada: $e');
    }
  }
}