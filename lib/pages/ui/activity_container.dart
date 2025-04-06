import 'package:flutter/material.dart';

class ActivityContainer extends StatelessWidget {
  const ActivityContainer({super.key, this.isReproved = false});
  final bool isReproved;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              blurRadius: 0.5,
              offset: Offset(3, 3),
              blurStyle: BlurStyle.solid,
              spreadRadius: 0.2,
            ),
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Nome da Atividade',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            '4H',
            style: TextStyle(
              color: isReproved ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
