import 'package:flutter/material.dart';

import '../update/banner_update.dart';
import 'servicio_login.dart';
import '../menu/menu.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginEstado();
}

class _LoginEstado extends State<Login> {
  final TextEditingController correoControlador = TextEditingController();
  final TextEditingController passwordControlador = TextEditingController();

  final ServicioLogin servicioLogin = ServicioLogin();

  bool cargando = false;
  bool mostrarPassword = false;
  String mensajeError = '';

  Future<void> iniciarSesion() async {
    setState(() {
      cargando = true;
      mensajeError = '';
    });

    try {
      await servicioLogin.iniciarSesion(
        correo: correoControlador.text,
        password: passwordControlador.text,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Menu(),
        ),
      );
    } catch (e) {
      setState(() {
        mensajeError = 'Correo o contraseña incorrectos';
      });
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  Future<void> recuperarPassword() async {
    if (correoControlador.text.trim().isEmpty) {
      setState(() {
        mensajeError = 'Escribe tu correo para recuperar la contraseña';
      });
      return;
    }

    try {
      await servicioLogin.recuperarPassword(
        correo: correoControlador.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correo de recuperación enviado'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setState(() {
        mensajeError = 'No se pudo enviar el correo de recuperación';
      });
    }
  }

  @override
  void dispose() {
    correoControlador.dispose();
    passwordControlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BannerUpdate(),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ipulcay',
                          style: textos.displayLarge?.copyWith(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Sistema de gestión',
                          style: textos.bodyMedium,
                        ),

                        const SizedBox(height: 30),

                        TextField(
                          controller: correoControlador,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Correo',
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: passwordControlador,
                          obscureText: !mostrarPassword,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  mostrarPassword = !mostrarPassword;
                                });
                              },
                              icon: Icon(
                                mostrarPassword ? Icons.visibility_off : Icons.visibility,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        if (mensajeError.isNotEmpty)
                          Text(
                            mensajeError,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: cargando ? null : iniciarSesion,
                            child: cargando
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Entrar'),
                          ),
                        ),

                        TextButton(
                          onPressed: cargando ? null : recuperarPassword,
                          child: const Text('¿Olvidaste tu contraseña?'),
                        ),
                      ],
                    ),
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