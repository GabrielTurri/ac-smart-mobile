import 'package:ac_smart/models/activity_model.dart';
import 'package:ac_smart/services/atividade_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AtividadeProvider with ChangeNotifier {
  // ignore: prefer_final_fields
  final AtividadeService _service = AtividadeService();
  List<Activity> _atividades = [];
  int _horasPedentes = 0;
  int _horasAprovadas = 0;
  int _horasReprovadas = 0;

  List<Activity> get atividades => _atividades;
  int get horasPedentes => _horasPedentes;
  int get horasAprovadas => _horasAprovadas;
  int get horasReprovadas => _horasReprovadas;

  bool _carregando = false;
  bool get carregando => _carregando;

  setAtividades(List<Activity> atividades) {
    _atividades = atividades;
    // Calcular horas pendentes com tratamento para lista vazia
    var atividadesPendentes = atividades
        .where((atividade) => atividade.status == 'Pendente')
        .map((atividade) => atividade.horasSolicitadas);
    _horasPedentes = atividadesPendentes.isEmpty
        ? 0
        : atividadesPendentes.reduce((a, b) => a + b);

    // Calcular horas aprovadas com tratamento para lista vazia
    var atividadesAprovadas = atividades
        .where((atividade) => atividade.status == 'Aprovado')
        .map((atividade) => atividade.horasAprovadas);
    _horasAprovadas = atividadesAprovadas.isEmpty
        ? 0
        : atividadesAprovadas.reduce((a, b) => a + b);

    // Calcular horas reprovadas com tratamento para lista vazia
    var atividadesReprovadas = atividades
        .where((atividade) => atividade.status == 'Reprovado')
        .map((atividade) => atividade.horasSolicitadas);
    _horasReprovadas = atividadesReprovadas.isEmpty
        ? 0
        : atividadesReprovadas.reduce((a, b) => a + b);

    notifyListeners();
  }

  Future<void> carregarAtividades() async {
    _carregando = true;
    try {
      _atividades = await _service.fetchAtividades();
      setAtividades(_atividades);
    } catch (e) {
      debugPrint('Erro detalhado: $e');
      debugPrint('StackTrace: ${StackTrace.current}');
      _atividades = [];
    }
    _carregando = false;
    notifyListeners();
  }

  String? _arquivoPath;
  DateTime? _dataSelecionada;

  String? get arquivoPath => _arquivoPath;
  DateTime? get dataSelecionada => _dataSelecionada;

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

  Future<void> selecionarData(BuildContext context) async {
    final DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (dataEscolhida != null) {
      _dataSelecionada = dataEscolhida;
      notifyListeners();
    }
  }

  Future<void> incluirAtividade({
    required String titulo,
    required String descricao,
    required DateTime dataAtividade,
    required int horasSolicitadas,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    Activity novaAtividade = Activity(
      titulo: titulo,
      dataAtividade: formatDateToHttp(dataAtividade),
      alunoId: prefs.getString('userId')!,
      descricao: descricao,
      horasSolicitadas: horasSolicitadas,
    );
    // dataAtividade: formatDateToHttp(dataAtividade),
    try {
      _service.includeAtividade(novaAtividade);
      atividades.add(novaAtividade);
      setAtividades(atividades);
    } catch (e) {
      debugPrint('Erro ao incluir atividade: $e');
    }
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
