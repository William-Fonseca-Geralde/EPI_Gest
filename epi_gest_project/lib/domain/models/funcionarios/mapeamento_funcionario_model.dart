import 'package:epi_gest_project/domain/models/appwrite_model.dart';
import 'package:epi_gest_project/domain/models/organizational_structure/cargo_model.dart';
import 'package:epi_gest_project/domain/models/funcionarios/funcionario_model.dart';
import 'package:epi_gest_project/domain/models/organizational_structure/mapeamento_epi_model.dart';
import 'package:epi_gest_project/domain/models/organizational_structure/setor_model.dart';
import 'package:epi_gest_project/domain/models/organizational_structure/turno_model.dart';
import 'package:epi_gest_project/domain/models/organizational_structure/unidade_model.dart';
import 'package:epi_gest_project/domain/models/organizational_structure/vinculo_model.dart';

class MapeamentoFuncionarioModel extends AppWriteModel {
  final FuncionarioModel funcionario;
  final MapeamentoEpiModel mapeamento;
  final UnidadeModel unidade;

  MapeamentoFuncionarioModel({
    super.id,
    required this.funcionario,
    required this.mapeamento,
    required this.unidade,
  });

  factory MapeamentoFuncionarioModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? getData(dynamic data) {
      if (data == null) return null;
      if (data is Map<String, dynamic>) return data;
      if (data is List && data.isNotEmpty)
        return data.first as Map<String, dynamic>;
      return null;
    }

    final funcionarioData = getData(map['funcionario_id']);
    final mapeamentoData = getData(map['mapeamento_id']);
    final unidadeData = getData(map['unidade_id']);

    final funcionarioObj = funcionarioData != null
        ? FuncionarioModel.fromMap(funcionarioData)
        : FuncionarioModel(
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
          );

    final mapeamentoObj = mapeamentoData != null
        ? MapeamentoEpiModel.fromMap(mapeamentoData)
        : MapeamentoEpiModel(
            codigoMapeamento: '',
            nomeMapeamento: '',
            cargo: CargoModel(codigoCargo: '', nomeCargo: ''),
            setor: SetorModel(codigoSetor: '', nomeSetor: ''),
            riscos: List.empty(),
            epis: List.empty(),
          );
    final unidadeObj = unidadeData != null
        ? UnidadeModel.fromMap(unidadeData)
        : UnidadeModel(
            nomeUnidade: '',
            cnpj: '',
            endereco: '',
            tipoUnidade: '',
            status: false
          );

    return MapeamentoFuncionarioModel(
      id: map['\$id'],
      funcionario: funcionarioObj,
      mapeamento: mapeamentoObj,
      unidade: unidadeObj,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'funcionario_id': funcionario.id,
      'mapeamento_id': mapeamento.id,
      'unidade_id': unidade.id,
    };
  }
}
