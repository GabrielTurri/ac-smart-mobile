// import 'package:ac_smart/models/activity.dart';
import 'package:ac_smart/pages/ui/app_bar.dart';
import 'package:ac_smart/pages/ui/button.dart';
import 'package:flutter/material.dart';

class ActivityDetails extends StatelessWidget {
  const ActivityDetails({super.key, this.activityId});
  final int? activityId;

  @override
  Widget build(BuildContext context) {
    return (activityId == null)
        ? const InserirAtividade()
        : EditarAtividade(activityId: activityId!);
  }
}

class InserirAtividade extends StatelessWidget {
  const InserirAtividade({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ACSmartAppBar(title: 'Inserir Nova Atividade'),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Descrição'),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Anexos'),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Data da atividade'),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Descrição'),
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
  const EditarAtividade({
    super.key,
    required this.activityId,
  });

  final int activityId;

  @override
  Widget build(BuildContext context) {
    // Activity atividade = Activity(id: activityId);
    // Aqui ele precisa encontrar a atividade já cadastrada

    return Scaffold(
      appBar: const ACSmartAppBar(title: 'Editar Atividade'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 8,
          children: [
            Text(
              'Consultando a atividade id: $activityId',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Descrição'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Anexos'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Data da atividade'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Descrição'),
            ),
          ],
        ),
      ),
    );
  }
}
