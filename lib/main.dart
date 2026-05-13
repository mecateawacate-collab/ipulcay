import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'interfaces/login/login.dart';
import 'interfaces/menu/menu.dart';
import 'interfaces/boletas/boletas.dart';
import 'interfaces/mapa/mapa.dart';
import 'interfaces/registros/registros.dart';

void main() {
  runApp(const IpulcayApp());
}

class IpulcayApp extends StatelessWidget {
  const IpulcayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ipulcay Vendedores',
      theme: AppTheme.theme(),
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginPage(),
        '/menu': (_) => const MenuPage(),
        '/boletas': (_) => const BoletasPage(),
        '/mapa': (_) => const MapaPage(),
        '/registros': (_) => const RegistrosPage(),
      },
    );
  }
}
