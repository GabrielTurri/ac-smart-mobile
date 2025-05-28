import 'package:ac_smart/models/activity_model.dart';
import 'package:ac_smart/services/atividade_service.dart';
import 'package:ac_smart/services/service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AtividadeProvider with ChangeNotifier {
  // ignore: prefer_final_fields
  final AtividadeService _service = AtividadeService();
  final String baseUrl = Service().url;
  List<Activity> _atividades = [];

  List<Activity> get atividades => _atividades;

  bool _carregando = false;
  bool get carregando => _carregando;

  setAtividades(List<Activity> atividades) {
    _atividades = atividades;
  }

  Future<void> carregarAtividades() async {
    _carregando = true;
    try {
      debugPrint('Iniciando carregamento de atividades...');
      var prefs = await SharedPreferences.getInstance();
      debugPrint('userId: ${prefs.getString('userId')}');
      debugPrint(
          'token: ${prefs.getString('token')?.substring(0, 10)}...'); // Exibe só parte do token

      _atividades = await _service.fetchAtividades();
      debugPrint('Atividades carregadas: ${_atividades.length}');
    } catch (e) {
      debugPrint('Erro detalhado: $e');
      debugPrint('StackTrace: ${StackTrace.current}');
      _atividades = [];
    }
    _carregando = false;
    notifyListeners();
  }

  String? _arquivoPath;
  String? get arquivoPath => _arquivoPath;

  Future<String?> selecionarArquivo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      _arquivoPath = result.files.single.path!;
      notifyListeners();
      return _arquivoPath;
    }
    return null;
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

  // void salvar({
  //   descricao,
  //   statusSelecionado,
  //   dataSelecionada,
  //   arquivoPath,
  //   horasSolicitadas,
  // }) {
  //   Activity novaAtividade = Activity(
  //     titulo: descricao,
  //     dataAtividade: dataSelecionada,
  //     horasSolicitadas: horasSolicitadas,
  //     alunoId: '',
  //     descricao: '',
  //   );
  //   adicionarAtividade(novaAtividade);
  // }
  Future<void> incluirAtividade({
    required String titulo,
    required String descricao,
    required DateTime dataAtividade,
    required int horasSolicitadas,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    Activity novaAtividade = Activity(
      titulo: titulo,
      dataAtividade: '2025-05-18',
      alunoId: prefs.getString('userId')!,
      descricao: descricao,
      horasSolicitadas: horasSolicitadas,
    );
    // dataAtividade: formatDateToHttp(dataAtividade),

    _service.includeAtividade(novaAtividade);
    notifyListeners();
  }

  Future<void> atualizar() {
    carregarAtividades();
    return Future.delayed(const Duration(seconds: 1));
  }

  Future<void> alterarAtividade({
    required id,
    titulo,
    descricao,
    dataSelecionada,
    // arquivoPath,
    horasSolicitadas,
  }) async {
    // Activity atividade = _atividades.firstWhere((a) => a.id == id);
    Activity atividade = await _service.fetchAtividade(id);
    if (titulo != null) {
      atividade.titulo = titulo;
    }
    if (descricao != null) {
      atividade.descricao = descricao;
    }
    if (dataSelecionada != null) {
      atividade.dataAtividade = dataSelecionada;
    }
    if (horasSolicitadas != null) {
      horasSolicitadas = int.tryParse(horasSolicitadas) ?? 0;
      atividade.horasSolicitadas = horasSolicitadas;
    }
    _service.updateAtividade(atividade);

    int indexAtividade = _atividades.indexWhere((a) => a.id == id);
    if (indexAtividade != -1) {
      _atividades[indexAtividade] = atividade;
    }
    notifyListeners();
  }
}
