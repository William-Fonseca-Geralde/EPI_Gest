import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:epi_gest_project/domain/models/employee/employee_model.dart';

const String DATABASE_ID = '690e798d002b058839e3';
const String COLLETION_ID = '';

class EmployeeService {
  final Client _client;
  final TablesDB _tabela;
  final Databases _databases;

  EmployeeService(this._client)
    : _tabela = TablesDB(_client),
      _databases = Databases(_client);

  Future<void> createEmployee(Employee employee) async {
    try {
      await _tabela.createRow(
        databaseId: DATABASE_ID,
        tableId: 'funcionarios',
        rowId: ID.unique(),
        data: employee.toJson(),
      );
    } on AppwriteException catch(e) {
      throw Exception('Falha ao adicionar funcionário. $e');
    }
  }

  Future<List<Cargo>> getAllCargos() async {
    try {
      final response = await _tabela.listRows(
        databaseId: DATABASE_ID,
        tableId: 'cargo',
      );
      return response.rows.map((row) => Cargo.fromAppwrite(row)).toList();
    } on AppwriteException catch (e) {
      throw Exception('Falha ao carregar funcionários. $e');
    }
  }

  Future<List<Vinculo>> getAllVinculo() async {
    try {
      final response = await _tabela.listRows(
        databaseId: DATABASE_ID,
        tableId: 'vinculo',
      );
      return response.rows.map((row) => Vinculo.fromAppwrite(row)).toList();
    } on AppwriteException catch (e) {
      throw Exception('Falha ao carregar funcionários. $e');
    }
  }

  Future<List<Setor>> getAllSetores() async {
    try {
      final response = await _tabela.listRows(
        databaseId: DATABASE_ID,
        tableId: 'setor',
      );
      return response.rows.map((row) => Setor.fromAppwrite(row)).toList();
    } on AppwriteException catch (e) {
      throw Exception('Falha ao carregar funcionários. $e');
    }
  }

  Future<List<Turno>> getAllTurnos() async {
    try {
      final response = await _tabela.listRows(
        databaseId: DATABASE_ID,
        tableId: 'turno',
      );
      return response.rows.map((row) => Turno.fromAppwrite(row)).toList();
    } on AppwriteException catch (e) {
      throw Exception('Falha ao carregar funcionários. $e');
    }
  }

  Future<List<Employee>> getActiveEmployees() async {
    try {
      final response = await _tabela.listRows(
        databaseId: DATABASE_ID,
        tableId: 'funcionarios',
        queries: [
          Query.equal('ativo', true),
          Query.select(['*', 'cargo_id.*']),
          Query.select(['*', 'setor_id.*']),
          Query.select(['*', 'vinculo_id.*']),
          Query.select(['*', 'turno_id.*']),
        ],
      );
      return response.rows.map((row) => Employee.fromAppwrite(row)).toList();
    } on AppwriteException catch (e) {
      throw Exception('Falha ao carregar funcionários. $e');
    }
  }

  // Atualizar um funcionário existente
  Future<void> updateEmployee(String rowId, Map<String, dynamic> data) async {
    try {
      await _tabela.updateRow(
        databaseId: DATABASE_ID,
        tableId: 'funcionarios',
        rowId: rowId,
        data: data,
      );
    } catch (e) {
      throw Exception('Falha ao atualizar funcionário.');
    }
  }

  // Inativar um funcionário (Soft Delete)
  Future<void> inactivateEmployee(String rowId) async {
    try {
      await updateEmployee(rowId, {
        'isActive': false,
        'terminationDate': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Falha ao inativar funcionário.');
    }
  }

  // Reativar um funcionário
  Future<void> activateEmployee(String rowId) async {
    try {
      await updateEmployee(rowId, {
        'isActive': true,
        'terminationDate': null,
        'terminationReason': null,
      });
    } catch (e) {
      throw Exception('Falha ao reativar funcionário.');
    }
  }
}
