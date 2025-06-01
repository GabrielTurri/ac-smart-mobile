import 'package:ac_smart/views/atividade/ui/app_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ac_smart/viewmodels/atividades_viewmodel.dart';
import 'package:flutter/material.dart';

class InserirAtividade extends StatefulWidget {
  const InserirAtividade({super.key});

  @override
  State<InserirAtividade> createState() => _InserirAtividadeState();
}

class _InserirAtividadeState extends State<InserirAtividade> {
  final _descricaoController = TextEditingController();
  final _tituloController = TextEditingController();
  final _horasSolicitadasController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final atividadeProvider = context.read<AtividadeProvider>();

    // Para acessar o caminho do arquivo selecionado
    String? caminhoAtual = context.watch<AtividadeProvider>().arquivoPath;

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
                  // ElevatedButton(
                  //   onPressed: atividadeProvider.selecionarArquivo,
                  //   child: const Text('Selecionar Anexo'),
                  // ),
                  // Text(_anexo != null
                  //     ? 'Anexo: $_anexo'
                  //     : 'Nenhum anexo selecionado'),
                  TextField(
                    controller: _horasSolicitadasController,
                    keyboardType: const TextInputType.numberWithOptions(),
                    decoration: const InputDecoration(
                        labelText: 'Horas Totais',
                        border: OutlineInputBorder()),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          caminhoAtual != null
                              ? 'Arquivo selecionado: ${caminhoAtual.split('/').last}'
                              : 'Nenhum arquivo selecionado',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => atividadeProvider.selecionarArquivo(),
                        child: const Text('Selecionar Anexo'),
                      ),
                    ],
                  ),
                  const CalendarioInput(),
                  // CalendarioInput(initialDate: DateTime.now()),
                  // Use the CalendarioInput widget for date selection
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
                    // _anexo = 'path';
                    // _data = DateTime.now();

                    atividadeProvider.incluirAtividade(
                      titulo: _tituloController.text,
                      descricao: _descricaoController.text,
                      horasSolicitadas: horasSolicitadas,
                      dataAtividade: atividadeProvider.dataSelecionada!,
                    );
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Atividade enviada com sucesso!')));
                    atividadeProvider.carregarAtividades();
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

class CalendarioInput extends StatefulWidget {
  const CalendarioInput({super.key});

  @override
  State<CalendarioInput> createState() => _CalendarioInputState();
}

class _CalendarioInputState extends State<CalendarioInput> {
  @override
  Widget build(BuildContext context) {
    final atividadeProvider = context.watch<AtividadeProvider>();
    return TextFormField(
      readOnly: true,
      onTap: () async {
        await atividadeProvider.selecionarData(context);
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.calendar_month_outlined),
        suffixIcon: const Icon(Icons.arrow_drop_down_outlined),
        // labelText: 'Data da atividade',
        border: const OutlineInputBorder(),
        hintText: atividadeProvider.dataSelecionada != null
            ? '${atividadeProvider.dataSelecionada!.day.toString().padLeft(2, '0')}/${atividadeProvider.dataSelecionada!.month.toString().padLeft(2, '0')}/${atividadeProvider.dataSelecionada!.year}'
            : 'Selecione uma data',
      ),
    );
  }
}
