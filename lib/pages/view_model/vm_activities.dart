import 'package:ac_smart/models/activity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

Future<void> selecionarArquivo({String arquivoPath = ''}) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
  );

  if (result != null && result.files.single.path != null) {
    arquivoPath = result.files.single.path!;
  }
}

Future<void> selecionarStatus({required statusSelecionado}) async {}

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

void salvar(nome, statusSelecionado, dataSelecionada, arquivoPath, formKey) {
  if (formKey.currentState!.validate()) {
    formKey.currentState!.save();

    incluirAtividade(
      descricao: nome,
      arquivoPath: arquivoPath,
      dataAtividade: dataSelecionada,
      statusSelecionado: statusSelecionado,
    );
  }
}
