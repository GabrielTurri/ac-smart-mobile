import 'package:ac_smart/models/activity.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ActivityContainer extends StatelessWidget {
  const ActivityContainer(
    this.idAtividade, {
    super.key,
    this.isReproved = false,
  });
  final bool isReproved;
  final int idAtividade;

  @override
  Widget build(BuildContext context) {
    Activity atividade = ConsultarAtividade(idAtividade);

    // List<Activity> atividades = [];
    // for (var i = 0; i < atividadeController.atividades.length; i++) {
    //   atividades.add(atividadeController.ConsultarAtividade(i));
    // }

    Icon tileIcon = const Icon(
      Icons.pending,
      color: Colors.grey,
    );

    switch (atividade.status) {
      case 'Aprovada':
        tileIcon = const Icon(
          Icons.check_circle,
          color: Colors.green,
        );
        break;
      case 'Pendente':
        tileIcon = const Icon(
          Icons.pending,
          color: Colors.amber,
        );
        break;
      case 'Reprovada':
        tileIcon = const Icon(
          Icons.remove_circle,
          color: Colors.red,
        );
        break;
    }

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
          Text(
            '${atividade.horasSolicitadas}H',
            style: TextStyle(
              color: isReproved ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
      subtitle: Text(atividade.status),
    );
    // return Container(
    //   width: double.infinity,
    //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
    //   decoration: BoxDecoration(
    //       color: Colors.white,
    //       border: Border.all(width: 1),
    //       borderRadius: BorderRadius.circular(8),
    //       boxShadow: const [
    //         BoxShadow(
    //           blurRadius: 0.5,
    //           offset: Offset(3, 3),
    //           blurStyle: BlurStyle.solid,
    //           spreadRadius: 0.2,
    //         ),
    //       ]),
    //   child: Row(
    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //     children: [
    //       Text(
    //         atividade.descricao,
    //         style: const TextStyle(fontSize: 16),
    //       ),
    //       Text(
    //         '${atividade.horasSolicitadas}H',
    //         style: TextStyle(
    //           color: isReproved ? Colors.red : Colors.black,
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
