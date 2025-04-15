// import 'package:ac_smart/models/activity.dart';

import 'package:provider/provider.dart';
import 'package:ac_smart/pages/ui/app_bar.dart';
import 'package:ac_smart/pages/ui/button.dart';
import 'package:ac_smart/pages/view_model/vm_activities.dart';
import 'package:flutter/material.dart';

class ActivityDetails extends StatelessWidget {
  const ActivityDetails({super.key, this.id = ''});
  final String id;

  @override
  Widget build(BuildContext context) {
    return (id.isEmpty) ? const InserirAtividade() : EditarAtividade(id: id);
  }
}

class InserirAtividade extends StatefulWidget {
  const InserirAtividade({super.key});

  @override
  State<InserirAtividade> createState() => _InserirAtividadeState();
}

class _InserirAtividadeState extends State<InserirAtividade> {
  final _descricaoController = TextEditingController();
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
                  if (_descricaoController.text.isNotEmpty) {
                    _anexo = 'path';
                    _data = DateTime.now();
                    debugPrint('teste');

                    atividadeProvider.salvar(
                      arquivoPath: _anexo,
                      dataSelecionada: _data,
                      descricao: _descricaoController.text,
                      statusSelecionado: atividadeProvider.statusSelecionado,
                    );
                  } else {
                    // Exibir mensagem de erro
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Preencha todos os campos')));
                  }
                },
                style: FilledButton.styleFrom(
                    backgroundColor: Color(0xff043565),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: Text('Enviar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditarAtividade extends StatelessWidget {
  EditarAtividade({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    final atividade = context.read<AtividadeProvider>().consultarAtividade(id);

    TextEditingController descricaoController =
        TextEditingController(text: atividade.descricao);
    DateTime dataAtividade = atividade.dataAtividade;
    TextEditingController horasSolicitadasController = TextEditingController();

    return Scaffold(
      appBar: const ACSmartAppBar(title: 'Editar Atividade'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 8,
          children: [
            Text(
              'Consultando: ${atividade.descricao}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(
                  labelText: 'Descrição', border: OutlineInputBorder()),
            ),
            const TextField(
              decoration: InputDecoration(
                  labelText: 'Anexos', border: OutlineInputBorder()),
            ),
            CalendarioInput(dataAtividade),
            TextField(
              controller: horasSolicitadasController,
              decoration: const InputDecoration(
                  labelText: 'Horas Solicitadas', border: OutlineInputBorder()),
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
