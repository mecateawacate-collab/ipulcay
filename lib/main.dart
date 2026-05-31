import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'modulos/inicio/pantalla_inicio.dart';
import 'tema/control_tema.dart';
import 'firebase_options.dart';

final ControlTema controlTema = ControlTema();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await controlTema.cargarTemaGuardado();

  runApp(const AppPrincipal());
}

class AppPrincipal extends StatelessWidget {
  const AppPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controlTema,
      builder: (context, child) {
        return MaterialApp(
          title: 'Ipulcay',
          debugShowCheckedModeBanner: false,
          theme: controlTema.tema,
          home: const PantallaInicio(),
        );
      },
    );
  }
}