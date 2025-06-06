import 'package:ac_smart/models/activity_model.dart';
import 'package:ac_smart/viewmodels/activity_details_viewmodel.dart';
import 'package:ac_smart/viewmodels/atividades_viewmodel.dart';
import 'package:ac_smart/views/atividade/nova_atividade.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EditarAtividade extends StatelessWidget {
  const EditarAtividade({
    super.key,
    required this.atividade,
  });

  final Activity atividade;

  @override
  Widget build(BuildContext context) {
    // ActivityListItemProvider atividadeProvider =
    //     context.read<ActivityListItemProvider>();

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
                  onPressed: (atividade.status == 'Aprovada')
                      ? null
                      : () {
                          ActivityListItemProvider()
                              .deletarAtividade(atividade.id);
                          context.pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Atividade excluída com sucesso!')));
                          context
                              .read<AtividadeProvider>()
                              .carregarAtividades();
                        },
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
              // final arquivoPathController =
              //     TextEditingController(text: atividade.arquivoPath);

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
                            onSubmitted: (newValue) => provider.saveEditing(
                                0, atividade.id!, newValue),
                            onEditingComplete: () => provider.saveEditing(
                                0, atividade.id!, tituloController.text),
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
                                  0, atividade.id!, tituloController.text);
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
                            onSubmitted: (newValue) => provider.saveEditing(
                                1, atividade.id!, newValue),
                            onEditingComplete: () => provider.saveEditing(
                                1, atividade.id!, descricaoController.text),
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
                                  1, atividade.id!, descricaoController.text);
                            },
                          )
                        : const Icon(Icons.edit),
                  ),
                  // ListTile(
                  //   title: const Text('Anexo'),
                  //   subtitle: provider.items[2].isEditing
                  //       ? TextField(
                  //           controller: arquivoPathController,
                  //           autofocus: true,
                  //           onSubmitted: (newValue) =>
                  //               provider.saveEditing(2, id, newValue),
                  //           onEditingComplete: () => provider.saveEditing(
                  //               2, id, arquivoPathController.text),
                  //         )
                  //       : Text(atividade.arquivoPath),
                  //   onTap: () {
                  //     if (!provider.items[2].isEditing) {
                  //       provider.startEditing(2);
                  //     }
                  //   },
                  //   trailing: provider.items[2].isEditing
                  //       ? IconButton(
                  //           icon: const Icon(Icons.check),
                  //           onPressed: () {
                  //             atividade.arquivoPath =
                  //                 arquivoPathController.text;
                  //             provider.items[2].isEditing = false;
                  //             provider.saveEditing(
                  //                 2, id, arquivoPathController.text);
                  //           },
                  //         )
                  //       : const Icon(Icons.edit),
                  // ),
                  ListTile(
                    title: const Text('Status'),
                    subtitle: Text(atividade.status),
                  ),
                  ListTile(
                    title: const Text('Horas solicitadas'),
                    subtitle: provider.items[3].isEditing
                        ? TextField(
                            controller: horasSolicitadasController,
                            autofocus: true,
                            onSubmitted: (newValue) => provider.saveEditing(
                                3, atividade.id!, newValue),
                            onEditingComplete: () => provider.saveEditing(3,
                                atividade.id!, horasSolicitadasController.text),
                          )
                        : Text('${atividade.horasSolicitadas}'),
                    onTap: () {
                      if (!provider.items[3].isEditing) {
                        provider.startEditing(3);
                      }
                    },
                    trailing: provider.items[3].isEditing
                        ? IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () {
                              atividade.horasSolicitadas =
                                  int.parse(horasSolicitadasController.text);
                              provider.items[3].isEditing = false;
                              provider.saveEditing(3, atividade.id!,
                                  horasSolicitadasController.text);
                            },
                          )
                        : const Icon(Icons.edit),
                  ),
                  ListTile(
                    title: const Text('Data da Atividade'),
                    subtitle: Text(provider.dataSelecionada != null
                        ? provider.formatarData(provider.dataSelecionada)
                        : atividade.dataAtividade),
                    onTap: () async {
                      if (!provider.items[4].isEditing) {
                        provider.startEditing(4);
                        // Parse the existing date string to DateTime
                        final dateParts = atividade.dataAtividade.split('-');
                        final initialDate = dateParts.length == 3
                            ? DateTime(
                                int.parse(dateParts[0]),
                                int.parse(dateParts[1]),
                                int.parse(dateParts[2]),
                              )
                            : null;
                        debugPrint('$initialDate');
                        await provider.selecionarData(
                          context,
                          initialDate: initialDate,
                        );

                        provider.saveEditing(
                            4,
                            atividade.id!,
                            provider.dataSelecionada != null
                                ? formatDateToHttp(provider.dataSelecionada!)
                                : atividade.dataAtividade);
                      }
                    },
                    trailing: provider.items[4].isEditing
                        ? IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () {
                              provider.items[4].isEditing = false;
                              provider.saveEditing(
                                  4,
                                  atividade.id!,
                                  provider.dataSelecionada != null
                                      ? provider.formatarData(
                                          provider.dataSelecionada)
                                      : atividade.dataAtividade);
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
                      child: ListView(children: [
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
                          subtitle: Text(atividade.dataAtividade),
                        ),
                        ListTile(
                          title: const Text('Horas Solicitadas'),
                          subtitle: Text('${atividade.horasSolicitadas}'),
                        ),
                      ]),
                    ),
                    if (atividade.status == 'Reprovado')
                      Column(
                        children: [
                          const Text('Observação do professor:',
                              textAlign: TextAlign.center),
                          Text(
                            atividade.observacao,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                  ]);
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
                  provider.saveEditing(index, atividade.id!, newValue),
              onEditingComplete: () =>
                  provider.saveEditing(index, atividade.id!, controller.text),
            )
          : Text(field),
      onTap: () {
        if (!item.isEditing) {
          provider.startEditing(index);
        }
      },
      trailing: item.isEditing
          ? IconButton(
              icon: const Icon(Icons.check),
              onPressed: () =>
                  provider.saveEditing(index, atividade.id!, controller.text),
            )
          : const Icon(Icons.edit),
    );
  }
}
