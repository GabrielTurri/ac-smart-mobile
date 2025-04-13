import 'package:ac_smart/models/activity.dart';
import 'package:ac_smart/pages/ui/activity_container.dart';
import 'package:ac_smart/pages/ui/app_bar.dart';
import 'package:flutter/material.dart';

class ReprovedActivities extends StatelessWidget {
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
              padding: const EdgeInsets.all(8),
              child: const ActivityList(
                isReproved: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
