import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ACSMartLogin extends StatelessWidget {
  const ACSMartLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const TextField(
            decoration: InputDecoration(labelText: 'E-mail / RA'),
          ),
          const TextField(
            decoration: InputDecoration(labelText: 'Senha'),
          ),
          FilledButton(
            onPressed: () {
              context.push('/');
            },
            child: const Text('Fazer login'),
          )
        ],
      ),
    );
  }
}
