// import 'package:ac_smart/models/activity.dart';

import 'package:ac_smart/viewmodels/activity_details_viewmodel.dart';
import 'package:ac_smart/widgets/activity_menu.dart';

import 'package:provider/provider.dart';
import 'package:ac_smart/views/atividade/ui/app_bar.dart';
import 'package:ac_smart/viewmodels/atividades_viewmodel.dart';
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
                    debugPrint('teste');

                    atividadeProvider.salvar(
                      arquivoPath: _anexo,
                      dataSelecionada: _data,
                      descricao: _descricaoController.text,
                      statusSelecionado: atividadeProvider.statusSelecionado,
                      horasSolicitadas: horasSolicitadas,
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

class EditarAtividade extends StatelessWidget {
  const EditarAtividade({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    final atividade = context.read<AtividadeProvider>().consultarAtividade(id);
    final bool isEditable = (atividade.status == 'Aprovada') ? false : true;
    return ChangeNotifierProvider(
      create: (context) => ActivityListItemProvider(),
      child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Visualizar Atividade',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: const Color(0xff043565),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: const <Widget>[ActivityMenu()],
            // [
            //   IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
            // ],
          ),
          body: Consumer<ActivityListItemProvider>(
              builder: (context, provider, child) {
            if (isEditable) {
              return ListView(
                children: [
                  _buildListTile(context, provider, atividade.titulo, 0),
                  _buildListTile(context, provider, atividade.descricao, 1),
                  _buildListTile(context, provider, atividade.arquivoPath, 2),
                  _buildListTile(
                      context, provider, atividade.dataAtividade.toString(), 3),
                  _buildListTile(context, provider,
                      atividade.horasSolicitadas.toString(), 4),
                ],
              );
            } else {
              return Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Status: '),
                        Text(
                          atividade.status,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        ListTile(
                          title: const Text('Título'),
                          subtitle: Text(atividade.titulo),
                        ),
                        ListTile(
                          title: const Text('Descrição'),
                          subtitle: Text(atividade.descricao),
                        ),
                        ListTile(
                          title: const Text('Status'),
                          subtitle: Text(atividade.status),
                        ),
                        ListTile(
                          title: const Text('Data da atividade'),
                          subtitle: Text('${atividade.dataAtividade}'),
                        ),
                        ListTile(
                          title: const Text('Horas Solicitadas'),
                          subtitle: Text('${atividade.horasSolicitadas}'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          })),
    );
  }

  Widget _buildListTile(BuildContext context, ActivityListItemProvider provider,
      String field, int index) {
    final item = provider.items[index];
    final controller = TextEditingController(text: item.text);

    return ListTile(
      title: Text(item.text),
      subtitle: item.isEditing
          ? TextField(
              controller: controller,
              autofocus: true,
              onSubmitted: (newValue) => provider.saveEditing(index, newValue),
              onEditingComplete: () =>
                  provider.saveEditing(index, controller.text),
            )
          : Text(field),
      onTap: () {
        if (!item.isEditing) {
          provider.startEditing(index);
        }
      },
      trailing: item.isEditing
          ? IconButton(
              icon: Icon(Icons.check),
              onPressed: () => provider.saveEditing(index, controller.text),
            )
          : Icon(Icons.edit),
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
