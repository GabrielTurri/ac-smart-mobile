import 'package:flutter/material.dart';

Drawer appDrawer() {
  return Drawer(
    backgroundColor: const Color(0xff001D39),
    child: Container(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100)),
                  ),
                  const DrawerText(
                    'José Silva Nascimento',
                    center: true,
                    isBold: true,
                  ),
                  const DrawerText(
                    'Ciência de Dados e Inteligência Artificial - Noite',
                    center: true,
                    isBold: true,
                  ),
                ],
              ),
            ),
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(title: DrawerText('Opção 1')),
                ListTile(title: DrawerText('Opção 2')),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class DrawerText extends StatelessWidget {
  const DrawerText(this.textValue,
      {super.key, this.center = false, this.isBold = false});
  final String textValue;
  final bool center;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final FontWeight fontWeightValue =
        (isBold == true) ? FontWeight.w800 : FontWeight.w500;

    return Text(
      textValue,
      style: TextStyle(
        color: Colors.white,
        fontWeight: fontWeightValue,
      ),
      textAlign: (center == true) ? TextAlign.center : TextAlign.start,
    );
  }
}
