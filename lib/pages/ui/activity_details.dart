import 'package:flutter/material.dart';

class ActivityDetails extends StatelessWidget {
  const ActivityDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      spacing: 8,
      children: [
        TextField(
          decoration: InputDecoration(labelText: 'Descrição'),
        )
      ],
    );
  }
}
