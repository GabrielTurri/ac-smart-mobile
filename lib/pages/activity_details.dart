// import 'package:ac_smart/models/activity.dart';
import 'package:ac_smart/models/activity.dart';
import 'package:ac_smart/pages/ui/app_bar.dart';
import 'package:ac_smart/pages/ui/button.dart';
import 'package:ac_smart/pages/view_model/vm_activities.dart';
import 'package:flutter/material.dart';

class ActivityDetails extends StatelessWidget {
  const ActivityDetails({super.key, this.id});
  final int? id;

  @override
  Widget build(BuildContext context) {
    return (id == null) ? InserirAtividade() : EditarAtividade(id: id!);
  }
}

class InserirAtividade extends StatelessWidget {
  const InserirAtividade({super.key});

  final String _statusSelecionado = "Aprovada";

  @override
  Widget build(BuildContext context) {
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
                  const TextField(
                    decoration: InputDecoration(
                        labelText: 'Descrição', border: OutlineInputBorder()),
                  ),
                  const TextField(
                    decoration: InputDecoration(
                        labelText: 'Anexos', border: OutlineInputBorder()),
                  ),
                  CalendarioInput(DateTime.now()),
                  const Divider(),
                  Column(
                    children: <Widget>[
                      ListTile(
                        title: const Text('Aprovada'),
                        leading: Radio<String>(
                          value: 'Aprovada',
                          groupValue: _statusSelecionado,
                          onChanged: (String? value) {
                            selecionarStatus(statusSelecionado: value);
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Pendente'),
                        leading: Radio<String>(
                          value: 'Pendente',
                          groupValue: _statusSelecionado,
                          onChanged: (String? value) {
                            selecionarStatus(statusSelecionado: value);
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Reprovada'),
                        leading: Radio<String>(
                          value: 'Reprovada',
                          groupValue: _statusSelecionado,
                          onChanged: (String? value) {
                            selecionarStatus(statusSelecionado: value);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ACSmartButton(onPressed: () {}, text: 'Enviar')
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

  final int id;

  @override
  Widget build(BuildContext context) {
    final atividade = consultarAtividade(id);

    TextEditingController descricaoController =
        TextEditingController(text: atividade.descricao);
    DateTime dataAtividade = atividade.dataAtividade;
    TextEditingController horasSolicitadasController;

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
            const TextField(
              decoration: InputDecoration(
                  labelText: 'Descrição', border: OutlineInputBorder()),
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
