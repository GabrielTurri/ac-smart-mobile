import 'package:ac_smart/views/atividade/ui/activity_container.dart';
import 'package:ac_smart/views/atividade/ui/app_bar.dart';
import 'package:flutter/material.dart';

class Activities extends StatelessWidget {
  const Activities({super.key, this.isReproved = false});
  final bool isReproved;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ACSmartAppBar(
        title: (isReproved) ? 'Reprovadas' : 'Atividades',
      ),
      body: SingleChildScrollView(
        // height: MediaQuery.of(context).size.width * 0.80,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: ActivityList(isReproved: isReproved),
            ),
          ],
        ),
      ),
    );
  }
}
