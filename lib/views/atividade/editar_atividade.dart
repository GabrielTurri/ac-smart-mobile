import 'package:ac_smart/viewmodels/activity_details_viewmodel.dart';
import 'package:ac_smart/viewmodels/atividades_viewmodel.dart';
import 'package:ac_smart/widgets/activity_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditarAtividade extends StatelessWidget {
  const EditarAtividade({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    var atividade = context.read<AtividadeProvider>().consultarAtividade(id);
    final itemAtividade = context.read<AtividadeProvider>();

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
              actions:
                  // const <Widget>[ActivityMenu()],

                  [
                IconButton(
                  onPressed: (atividade.status == 'Aprovada') ? null : () {},
                  icon: const Icon(Icons.delete),
                  color: Colors.white,
                )
              ]
              // [
              //   IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
              // ],
              ),
          body: Consumer<ActivityListItemProvider>(
              builder: (context, provider, child) {
            if (isEditable) {
              final tituloController =
                  TextEditingController(text: atividade.titulo);
              final descricaoController =
                  TextEditingController(text: atividade.descricao);
              final arquivoPathController =
                  TextEditingController(text: atividade.arquivoPath);
              final dataAtividadeController = TextEditingController(
                  text: atividade.dataAtividade.toString());
              final statusController =
                  TextEditingController(text: atividade.status);
              final horasSolicitadasController = TextEditingController(
                  text: atividade.horasSolicitadas.toString());
              return ListView(
                children: [
                  ListTile(
                    title: const Text('Título'),
                    subtitle: provider.items[0].isEditing
                        ? TextField(
                            controller: tituloController,
                            autofocus: true,
                            onSubmitted: (newValue) =>
                                provider.saveEditing(0, id, newValue),
                            onEditingComplete: () => provider.saveEditing(
                                0, id, tituloController.text),
                          )
                        : Text(atividade.titulo),
                    onTap: () {
                      if (!provider.items[0].isEditing) {
                        provider.startEditing(0);
                      }
                    },
                    trailing: provider.items[0].isEditing
                        ? IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () {
                              atividade.titulo = tituloController.text;
                              provider.items[0].isEditing = false;
                              provider.saveEditing(
                                  0, id, tituloController.text);
                            },
                          )
                        : const Icon(Icons.edit),
                  ),
                  ListTile(
                    title: const Text('Descrição'),
                    subtitle: provider.items[1].isEditing
                        ? TextField(
                            controller: descricaoController,
                            autofocus: true,
                            onSubmitted: (newValue) =>
                                provider.saveEditing(1, id, newValue),
                            onEditingComplete: () => provider.saveEditing(
                                1, id, descricaoController.text),
                          )
                        : Text(atividade.descricao),
                    onTap: () {
                      if (!provider.items[1].isEditing) {
                        provider.startEditing(1);
                      }
                    },
                    trailing: provider.items[1].isEditing
                        ? IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () {
                              atividade.descricao = descricaoController.text;
                              provider.items[1].isEditing = false;
                              provider.saveEditing(
                                  1, id, descricaoController.text);
                            },
                          )
                        : const Icon(Icons.edit),
                  ),
                  ListTile(
                    title: const Text('Anexo'),
                    subtitle: provider.items[2].isEditing
                        ? TextField(
                            controller: arquivoPathController,
                            autofocus: true,
                            onSubmitted: (newValue) =>
                                provider.saveEditing(2, id, newValue),
                            onEditingComplete: () => provider.saveEditing(
                                2, id, arquivoPathController.text),
                          )
                        : Text(atividade.arquivoPath),
                    onTap: () {
                      if (!provider.items[2].isEditing) {
                        provider.startEditing(2);
                      }
                    },
                    trailing: provider.items[2].isEditing
                        ? IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () {
                              atividade.arquivoPath =
                                  arquivoPathController.text;
                              provider.items[2].isEditing = false;
                              provider.saveEditing(
                                  2, id, arquivoPathController.text);
                            },
                          )
                        : const Icon(Icons.edit),
                  ),
                  ListTile(
                    title: const Text('Status'),
                    subtitle: provider.items[3].isEditing
                        ? TextField(
                            controller: statusController,
                            autofocus: true,
                            onSubmitted: (newValue) =>
                                provider.saveEditing(3, id, newValue),
                            onEditingComplete: () => provider.saveEditing(
                                3, id, statusController.text),
                          )
                        : Text(atividade.status),
                    onTap: () {
                      if (!provider.items[3].isEditing) {
                        provider.startEditing(3);
                      }
                    },
                    trailing: provider.items[3].isEditing
                        ? IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () {
                              atividade.status = statusController.text;
                              provider.items[3].isEditing = false;
                              provider.saveEditing(
                                  2, id, statusController.text);
                            },
                          )
                        : const Icon(Icons.edit),
                  ),
                  // _buildListTile(
                  //     context, provider, atividade.dataAtividade.toString(), 3),
                  // _buildListTile(context, provider,
                  //     atividade.horasSolicitadas.toString(), 4),
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
    final controller = TextEditingController(text: field);

    return ListTile(
      title: Text(item.text),
      subtitle: item.isEditing
          ? TextField(
              controller: controller,
              autofocus: true,
              onSubmitted: (newValue) =>
                  provider.saveEditing(index, id, newValue),
              onEditingComplete: () =>
                  provider.saveEditing(index, id, controller.text),
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
              onPressed: () => provider.saveEditing(index, id, controller.text),
            )
          : Icon(Icons.edit),
    );
  }
}
