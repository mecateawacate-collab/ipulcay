import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userCtrl = TextEditingController(text: 'admin');
  final passCtrl = TextEditingController(text: '1234');
  String? error;

  void login() {
    if (userCtrl.text.trim() == 'admin' && passCtrl.text.trim() == '1234') {
      Navigator.pushReplacementNamed(context, '/menu');
    } else {
      setState(() => error = 'Usuario o contraseña incorrectos. Prueba admin / 1234');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(.45),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(Icons.storefront, size: 46, color: AppColors.primary),
                ),
                const SizedBox(height: 20),
                const Text('Ipulcay Vendedores', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.text)),
                const SizedBox(height: 8),
                const Text('Acceso rápido para fuerza de ventas', style: TextStyle(color: AppColors.muted)),
                const SizedBox(height: 26),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(controller: userCtrl, decoration: const InputDecoration(labelText: 'Usuario', prefixIcon: Icon(Icons.person_outline))),
                      const SizedBox(height: 14),
                      TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock_outline))),
                      if (error != null) ...[
                        const SizedBox(height: 12),
                        Text(error!, style: const TextStyle(color: AppColors.danger)),
                      ],
                      const SizedBox(height: 18),
                      ElevatedButton.icon(onPressed: login, icon: const Icon(Icons.login), label: const Text('Ingresar')),
                      const SizedBox(height: 10),
                      const Text('Demo: admin / 1234', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
