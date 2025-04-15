import 'package:ac_smart/models/activity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AtividadeProvider with ChangeNotifier {
  // ignore: prefer_final_fields
  List<Activity> _atividades = [
    Activity(
        descricao: 'Palestra Python',
        horasSolicitadas: 4,
        dataAtividade: DateTime(2025, 04)),
    Activity(
      descricao: 'Palestra Machine Learning',
      horasSolicitadas: 8,
      status: 'Reprovada',
      dataAtividade: DateTime(2025, 04),
    ),
    Activity(
      descricao: 'Certificado: HTML Básico',
      horasSolicitadas: 4,
      status: 'Aprovada',
      dataAtividade: DateTime(2025, 04),
    ),
  ];

  List<Activity> get atividades => _atividades;

  Activity consultarAtividade(id) {
    return _atividades.firstWhere((a) => a.id == id);
  }

  Future<void> selecionarArquivo({String arquivoPath = ''}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      arquivoPath = result.files.single.path!;
    }
  }

  String _statusSelecionado = 'Aprovada';

  String get statusSelecionado => _statusSelecionado;
  Future<void> selecionarStatus({required String statusSelecionado}) async {
    _statusSelecionado = statusSelecionado;
    notifyListeners();
  }

  Future<void> selecionarData(context) async {
    DateTime dataSelecionada = DateTime.now();
    final DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate: dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (dataEscolhida != null) {
      dataSelecionada = dataEscolhida;
    }
  }
// Future<void> _selecionarData(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _data ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != _data) {
//       setState(() {
//         _data = picked;
//       });
//     }
//   }

  void salvar({descricao, statusSelecionado, dataSelecionada, arquivoPath}) {
    Activity novaAtividade = Activity(
      descricao: descricao,
      arquivoPath: arquivoPath,
      dataAtividade: dataSelecionada,
      status: statusSelecionado,
      horasSolicitadas: 4,
    );
    adicionarAtividade(novaAtividade);
  }

  void adicionarAtividade(Activity atividade) {
    _atividades.add(atividade);
    notifyListeners();
  }
}
