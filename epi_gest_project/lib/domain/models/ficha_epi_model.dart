import 'package:epi_gest_project/domain/models/appwrite_model.dart';
import 'package:epi_gest_project/domain/models/organizational_structure/cargo_model.dart';
import 'package:epi_gest_project/domain/models/funcionarios/funcionario_model.dart';
import 'package:epi_gest_project/domain/models/organizational_structure/mapeamento_epi_model.dart';
import 'package:epi_gest_project/domain/models/funcionarios/mapeamento_funcionario_model.dart';
import 'package:epi_gest_project/domain/models/organizational_structure/setor_model.dart';
import 'package:epi_gest_project/domain/models/organizational_structure/turno_model.dart';
import 'package:epi_gest_project/domain/models/organizational_structure/unidade_model.dart';
import 'package:epi_gest_project/domain/models/organizational_structure/vinculo_model.dart';

class FichaEpiModel extends AppWriteModel {
  final MapeamentoFuncionarioModel mapeamentoFuncionario;
  final DateTime validadeEpi;
  final bool status;

  FichaEpiModel({
    super.id,
    required this.mapeamentoFuncionario,
    required this.validadeEpi,
    this.status = true,
  });

  factory FichaEpiModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? getData(dynamic data) {
      if (data == null) return null;
      if (data is Map<String, dynamic>) return data;
      if (data is List && data.isNotEmpty)
        return data.first as Map<String, dynamic>;
      return null;
    }

    final mapeamentoFunciData = getData(map['mapeamentoFuncionario_id']);

    final mapeamentoFuncObj = mapeamentoFunciData != null
        ? MapeamentoFuncionarioModel.fromMap(mapeamentoFunciData)
        : MapeamentoFuncionarioModel(
            funcionario: FuncionarioModel(
              matricula: '',
              nomeFunc: '',
              dataEntrada: DateTime.now(),
              telefone: '',
              email: '',
              turno: TurnoModel(
                turno: '',
                horaEntrada: '',
                horaSaida: '',
                inicioAlmoco: '',
                fimAlomoco: '',
              ),
              vinculo: VinculoModel(nomeVinculo: ''),
              lider: '',
              gestor: '',
              statusAtivo: false,
              statusFerias: false,
            ),
            mapeamento: MapeamentoEpiModel(
              nomeMapeamento: '',
              codigoMapeamento: '',
              cargo: CargoModel(codigoCargo: '', nomeCargo: ''),
              setor: SetorModel(
                codigoSetor: '',
                nomeSetor: '',
              ),
              riscos: List.empty(),
              epis: List.empty(),
            ),
            unidade: UnidadeModel(
              nomeUnidade: '',
              cnpj: '',
              endereco: '',
              tipoUnidade: '',
              status: false
            ),
          );

    return FichaEpiModel(
      id: map['\$id'],
      mapeamentoFuncionario: mapeamentoFuncObj,
      validadeEpi: DateTime.parse(map['validade_epi']),
      status: map['status'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'mapeamentoFuncionario_id': mapeamentoFuncionario.id,
      'validade_epi': validadeEpi.toIso8601String(),
      'status': status,
    };
  }
}
