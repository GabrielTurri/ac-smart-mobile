import 'package:flutter/material.dart';

class ACSmartButton extends StatelessWidget {
  const ACSmartButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.color = const Color(0xff043565),
  });
  final String text;
  final Function onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () => onPressed,
        style: FilledButton.styleFrom(
            backgroundColor: const Color(0xff043565),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: Text(text),
      ),
    );
  }
}
