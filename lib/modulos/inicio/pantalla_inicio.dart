import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../login/login.dart';
import '../menu/menu.dart';
import '../update/servicio_update.dart';
import '../update/pantalla_bloqueo_update.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioEstado();
}

class _PantallaInicioEstado extends State<PantallaInicio> {
  final ServicioUpdate servicioUpdate = ServicioUpdate();

  String mensaje = 'Revisando aplicación...';

  @override
  void initState() {
    super.initState();
    revisarEntrada();
  }

  Future<void> revisarEntrada() async {
    try {
      setState(() {
        mensaje = 'Buscando actualizaciones...';
      });

      final ResultadoUpdate resultado = await servicioUpdate.revisarUpdate();

      if (!mounted) return;

      if (resultado.hayUpdate && resultado.obligatorio && resultado.datos != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaBloqueoUpdate(
              datos: resultado.datos!,
            ),
          ),
        );
        return;
      }

      setState(() {
        mensaje = 'Verificando sesión...';
      });

      final User? usuario = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      if (usuario != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Menu(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Login(),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Login(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textos = Theme.of(context).textTheme;
    final ColorScheme colores = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    color: colores.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
                    Icons.inventory_2,
                    size: 44,
                    color: colores.primary,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Ipulcay',
                  style: textos.displayLarge?.copyWith(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Sistema de gestión',
                  style: textos.bodyMedium,
                ),

                const SizedBox(height: 32),

                const CircularProgressIndicator(),

                const SizedBox(height: 18),

                Text(
                  mensaje,
                  textAlign: TextAlign.center,
                  style: textos.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}