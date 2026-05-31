// textos_app.dart
import 'package:flutter/material.dart';

class TextosApp {
  static const String fuentePrincipal = 'Roboto';

  static const TextStyle tituloGrande = TextStyle(
    fontFamily: fuentePrincipal,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle titulo = TextStyle(
    fontFamily: fuentePrincipal,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    height: 1.25,
  );

  static const TextStyle subtitulo = TextStyle(
    fontFamily: fuentePrincipal,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle normal = TextStyle(
    fontFamily: fuentePrincipal,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  static const TextStyle pequeno = TextStyle(
    fontFamily: fuentePrincipal,
    fontSize: 13,
    fontWeight: FontWeight.normal,
    height: 1.35,
  );

  static const TextStyle boton = TextStyle(
    fontFamily: fuentePrincipal,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle error = TextStyle(
    fontFamily: fuentePrincipal,
    fontSize: 14,
    color: Colors.red,
    fontWeight: FontWeight.w500,
  );
}