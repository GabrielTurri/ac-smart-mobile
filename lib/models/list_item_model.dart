class EditableItem {
  String text;
  String field;
  bool isEditing;

  EditableItem({
    required this.text,
    required this.field,
    this.isEditing = false,
  });
}
