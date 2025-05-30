import 'package:ac_smart/viewmodels/login_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ACSMartLogin extends StatefulWidget {
  const ACSMartLogin({super.key});

  @override
  State<ACSMartLogin> createState() => _ACSMartLoginState();
}

class _ACSMartLoginState extends State<ACSMartLogin> {
  String email = "";
  String senha = "";
  @override
  Widget build(BuildContext context) {
    // final _emailController = TextEditingController();
    // final _passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Bem-vindo!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              // controller: _emailController,
              decoration: InputDecoration(
                labelText: 'E-mail / RA',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.email),
              ),
              onChanged: (value) {
                email = value;
                setState(() {});
              },
            ),
            const SizedBox(height: 20),
            TextField(
              // controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock),
              ),
              onChanged: (value) {
                senha = value;
                setState(() {});
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () {
                  LoginProvider().fazerLogin(context,
                      email: email, senha: senha, tipo: "aluno");
                  context.go('/');
                },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: const Color(0xff043565),
                ),
                child: const Text('Fazer login'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Não tem conta? Entre em contato com a sua instituição de ensino.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
