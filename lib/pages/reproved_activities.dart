import 'package:ac_smart/pages/ui/activity_container.dart';
import 'package:ac_smart/pages/ui/app_bar.dart';
import 'package:flutter/material.dart';

class ReprovedActivities extends StatelessWidget {
  final int currentSelectedNavigation = 1;
  const ReprovedActivities({super.key, int? currentSelectedNavigation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ACSmartAppBar(title: 'Reprovadas'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                spacing: 8,
                children: List<Widget>.generate(
                  4,
                  (index) => const ActivityContainer(
                    isReproved: true,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
