import 'package:ac_smart/models/activity.dart';
import 'package:ac_smart/pages/ui/activity_container.dart';
import 'package:ac_smart/pages/ui/app_bar.dart';
import 'package:flutter/material.dart';

class Activities extends StatelessWidget {
  const Activities({super.key});

  @override
  Widget build(BuildContext context) {
    int qtdAtividades = atividades.length;

    return Scaffold(
      appBar: const ACSmartAppBar(
        title: 'Atividades',
      ),
      body: SingleChildScrollView(
        // height: MediaQuery.of(context).size.width * 0.80,
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: Column(
                spacing: 8,
                children: List<Widget>.generate(
                  qtdAtividades,
                  (index) => ActivityContainer(index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
