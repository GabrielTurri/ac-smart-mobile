import 'package:flutter/material.dart';
import 'package:ac_smart/models/list_item_model.dart';

class ActivityListItemProvider with ChangeNotifier {
  final List<EditableItem> _items = [
    EditableItem(text: 'Título', field: 'titulo'),
    EditableItem(text: 'Descrição', field: 'descricao'),
    EditableItem(text: 'Anexo', field: 'arquivoPath'),
    EditableItem(text: 'Data da atividade', field: 'dataAtividade'),
    EditableItem(text: 'Horas solicitadas', field: 'horasSolicitadas'),
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
    // _items[index].text = newText;
    // atividades.firstWhere((a) => a.id == idAtividade);
    _items[index].isEditing = false;
    notifyListeners();
  }
}
