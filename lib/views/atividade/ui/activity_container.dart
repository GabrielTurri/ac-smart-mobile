import 'package:ac_smart/models/activity.dart';
import 'package:ac_smart/viewmodels/atividades_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ActivityList extends StatelessWidget {
  const ActivityList({super.key, this.isReproved = false});
  final bool isReproved;

  @override
  Widget build(BuildContext context) {
    List<Activity> atividades = context.watch<AtividadeProvider>().atividades;

    final listaAtividades = (isReproved)
        ? atividades.where((a) => a.status == "Reprovada").toList()
        : atividades.where((a) => a.status != "Reprovada").toList();

    return SizedBox(
      height: 600,
      width: double.infinity,
      child: ListView.builder(
        itemCount: listaAtividades.length,
        itemBuilder: (context, index) {
          return ActivityContainer(listaAtividades[index],
              isReproved: isReproved);
        },
      ),
    );
  }
}

class ActivityContainer extends StatelessWidget {
  final bool isReproved;
  final Activity atividade;

  const ActivityContainer(this.atividade, {super.key, this.isReproved = false});

  @override
  Widget build(BuildContext context) {
    Icon tileIcon = (atividade.status == 'Aprovada')
        ? const Icon(
            Icons.check_circle,
            color: Colors.green,
          )
        : const Icon(
            Icons.hourglass_bottom,
            color: Colors.grey,
          );

    return (!isReproved)
        ? ActivityTile(tileIcon: tileIcon, atividade: atividade)
        : ReprovedActivityTile(atividade: atividade);
  }
}

class ActivityTile extends StatelessWidget {
  const ActivityTile({
    super.key,
    required this.tileIcon,
    required this.atividade,
  });

  final Icon tileIcon;
  final Activity atividade;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: tileIcon,
      onTap: () => context.push('/activities/${atividade.id}'),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            atividade.descricao,
            style: const TextStyle(fontSize: 16),
          ),
          Text('${atividade.horasSolicitadas}H'),
        ],
      ),
      subtitle: Text(atividade.status),
    );
  }
}

class ReprovedActivityTile extends StatelessWidget {
  const ReprovedActivityTile({
    super.key,
    required this.atividade,
  });

  final Activity atividade;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.cancel,
        color: Colors.red,
      ),
      onTap: () => context.push('/activities/${atividade.id}'),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            atividade.descricao,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            '${atividade.horasSolicitadas}H',
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
        ],
      ),
      subtitle: Text(atividade.status,
          style: const TextStyle(
            color: Colors.red,
          )),
    );
  }
}
