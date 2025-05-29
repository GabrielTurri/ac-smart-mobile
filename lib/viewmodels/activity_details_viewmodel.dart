import 'package:ac_smart/services/atividade_service.dart';
import 'package:ac_smart/viewmodels/atividades_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:ac_smart/models/list_item_model.dart';

class ActivityListItemProvider with ChangeNotifier {
  final _service = AtividadeService();
  final List<EditableItem> _items = [
    EditableItem(text: 'Título', field: 'titulo'),
    EditableItem(text: 'Descrição', field: 'descricao'),
    EditableItem(text: 'Anexo', field: 'arquivoPath'),
    EditableItem(text: 'Horas solicitadas', field: 'horasSolicitadas'),
    EditableItem(text: 'Data da atividade', field: 'dataAtividade'),
  ];

  DateTime? _dataSelecionada;
  DateTime? get dataSelecionada => _dataSelecionada;

  Future<void> selecionarData(BuildContext context, {DateTime? initialDate}) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) {
      _dataSelecionada = selectedDate;
      notifyListeners();
    }
  }
  // List.generate(
  //   5,
  //   (index) => EditableItem(text: "Item ${index + 1}"),
  // );

  List<EditableItem> get items => _items;

  void startEditing(int index) {
    _items[index].isEditing = true;
    notifyListeners();
  }

  String formatarData(DateTime? data) {
    if (data == null) return '';
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  void saveEditing(int index, String idAtividade, String newText) {
    String field = _items[index].field;
    String value = newText;

    // Se for data da atividade, usa o valor selecionado
    if (field == 'dataAtividade' && _dataSelecionada != null) {
      value = formatarData(_dataSelecionada);
    }

    switch (field) {
      case 'titulo':
        AtividadeProvider().alterarAtividade(id: idAtividade, titulo: value);
        break;
      case 'descricao':
        AtividadeProvider()
            .alterarAtividade(id: idAtividade, descricao: newText);
        break;
      case 'dataAtividade':
        AtividadeProvider()
            .alterarAtividade(id: idAtividade, dataSelecionada: newText);
        break;
      case 'horasSolicitadas':
        AtividadeProvider()
            .alterarAtividade(id: idAtividade, horasSolicitadas: newText);
        break;
    }
    _items[index].isEditing = false;
    notifyListeners();
  }

  void deletarAtividade(id) {
    _service.deleteAtividade(id);
    notifyListeners();
  }
}
