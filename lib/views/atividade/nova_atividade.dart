// import 'package:ac_smart/models/activity.dart';

import 'package:ac_smart/views/atividade/editar_atividade.dart';
import 'package:ac_smart/views/atividade/ui/app_bar.dart';

import 'package:provider/provider.dart';

import 'package:ac_smart/viewmodels/atividades_viewmodel.dart';
import 'package:flutter/material.dart';

class InserirAtividade extends StatelessWidget {
  InserirAtividade({super.key});

  final _descricaoController = TextEditingController();
  final _tituloController = TextEditingController();
  final _horasSolicitadasController = TextEditingController();
  String? _anexo;
  DateTime? _data;

  @override
  Widget build(BuildContext context) {
    final atividadeProvider = context.read<AtividadeProvider>();
    final watchAtividadeProvider = context.watch<AtividadeProvider>();
    return Scaffold(
      appBar: const ACSmartAppBar(title: 'Inserir Nova Atividade'),
      body: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SingleChildScrollView(
              child: Column(
                spacing: 16,
                children: [
                  TextField(
                    controller: _tituloController,
                    decoration: const InputDecoration(
                        labelText: 'Título', border: OutlineInputBorder()),
                  ),
                  TextField(
                    controller: _descricaoController,
                    decoration: const InputDecoration(
                        labelText: 'Descrição', border: OutlineInputBorder()),
                  ),
                  ElevatedButton(
                    onPressed: atividadeProvider.selecionarArquivo,
                    child: const Text('Selecionar Anexo'),
                  ),
                  Text(_anexo != null
                      ? 'Anexo: $_anexo'
                      : 'Nenhum anexo selecionado'),
                  TextField(
                    controller: _horasSolicitadasController,
                    keyboardType: const TextInputType.numberWithOptions(),
                    decoration: const InputDecoration(
                        labelText: 'Horas Totais',
                        border: OutlineInputBorder()),
                  ),
                  CalendarioInput(DateTime.now()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_data != null
                          ? 'Data: ${_data!.toLocal()}'.split(' ')[0]
                          : 'Nenhuma data selecionada'),
                      ElevatedButton(
                        onPressed: () =>
                            atividadeProvider.selecionarData(context),
                        child: const Text('Selecionar Data'),
                      ),
                    ],
                  ),
                  const Divider(),
                  DropdownButton<String>(
                    padding: const EdgeInsets.all(8),
                    hint: const Text('Selecione o Status'),
                    value: watchAtividadeProvider.statusSelecionado,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        atividadeProvider.selecionarStatus(
                            statusSelecionado: newValue);
                      }
                    },
                    items: <String>['Reprovada', 'Pendente', 'Aprovada']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  int horasSolicitadas =
                      int.tryParse(_horasSolicitadasController.text) ?? 0;

                  if (_descricaoController.text.isNotEmpty &&
                      horasSolicitadas != 0) {
                    _anexo = 'path';
                    _data = DateTime.now();

                    atividadeProvider.incluirAtividade(
                      titulo: _tituloController.text,
                      descricao: _descricaoController.text,
                      horasSolicitadas: horasSolicitadas,
                      dataAtividade: DateTime(2025, 01, 01),
                    );
                  } else {
                    // Exibir mensagem de erro
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Preencha todos os campos')));
                  }
                },
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xff043565),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: const Text('Enviar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CalendarioInput extends StatelessWidget {
  CalendarioInput(this.dataAtividade, {super.key});
  DateTime dataAtividade;

  @override
  Widget build(BuildContext context) {
    TextEditingController dataAtividadeController = TextEditingController(
        text:
            '${dataAtividade.day.toString().padLeft(2, '0')}/${dataAtividade.month.toString().padLeft(2, '0')}/${dataAtividade.year.toString()}');

    return TextField(
      controller: dataAtividadeController,
      readOnly: true,
      onTap: () => showDatePicker(
        context: context,
        helpText: 'Selecione a data da atividade',
        initialDate: dataAtividade,
        firstDate: dataAtividade.subtract(const Duration(days: 365)),
        lastDate: DateTime.now(),
        onDatePickerModeChange: (value) {
          debugPrint(value.toString());
        },
      ),
      decoration: const InputDecoration(
          prefixIcon: Icon(Icons.calendar_month_outlined),
          suffixIcon: Icon(Icons.arrow_drop_down_outlined),
          labelText: 'Data da atividade',
          border: OutlineInputBorder()),
    );
  }
}
