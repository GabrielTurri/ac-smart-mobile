import 'package:ac_smart/pages/ui/activity_container.dart';
import 'package:ac_smart/pages/ui/app_bar.dart';
import 'package:flutter/material.dart';

class Activities extends StatelessWidget {
  final int currentSelectedNavigation = 1;
  const Activities({super.key, int? currentSelectedNavigation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ACSmartAppBar(
        title: 'Atividades',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                spacing: 8,
                children: List<Widget>.generate(
                  40,
                  (index) => const ActivityContainer(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
