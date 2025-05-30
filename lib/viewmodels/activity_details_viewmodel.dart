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
  // List.generate(
  //   5,
  //   (index) => EditableItem(text: "Item ${index + 1}"),
  // );

  List<EditableItem> get items => _items;

  void startEditing(int index) {
    _items[index].isEditing = true;
    notifyListeners();
  }

  void saveEditing(int index, String idAtividade, String newText) {
    String field = _items[index].field;

    switch (field) {
      case 'titulo':
        AtividadeProvider().alterarAtividade(id: idAtividade, titulo: newText);
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
