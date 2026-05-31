import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'tema_app.dart';

class ControlTema extends ChangeNotifier {
  String _temaActual = 'pastel';

  String get temaActual => _temaActual;

  final List<String> temasValidos = const [
    'pastel',
    'verde',
    'azul',
    'morado',
    'naranja',
    'oscuro',
    'oscuroAzul',
  ];

  ThemeData get tema {
    if (_temaActual == 'verde') return TemaApp.claro;
    if (_temaActual == 'azul') return TemaApp.azul;
    if (_temaActual == 'morado') return TemaApp.morado;
    if (_temaActual == 'naranja') return TemaApp.naranja;
    if (_temaActual == 'oscuro') return TemaApp.oscuro;
    if (_temaActual == 'oscuroAzul') return TemaApp.oscuroAzul;

    return TemaApp.pastel;
  }

  Future<void> cargarTemaGuardado() async {
    try {
      final usuario = FirebaseAuth.instance.currentUser;

      if (usuario == null) {
        _temaActual = 'pastel';
        return;
      }

      final documento = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .get();

      final datos = documento.data();

      if (datos == null) {
        _temaActual = 'pastel';
        return;
      }

      final String temaGuardado = datos['tema'] ?? 'pastel';

      if (temasValidos.contains(temaGuardado)) {
        _temaActual = temaGuardado;
      } else {
        _temaActual = 'pastel';
      }
    } catch (e) {
      _temaActual = 'pastel';
    }
  }

  void cambiarTema(String tema) {
    if (!temasValidos.contains(tema)) {
      _temaActual = 'pastel';
    } else {
      _temaActual = tema;
    }

    notifyListeners();
  }
}