import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServicioUsuario {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? obtenerAuthActual() {
    return _auth.currentUser;
  }

  Stream<Map<String, dynamic>?> escucharUsuarioActual() {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('usuarios')
        .doc(usuario.uid)
        .snapshots()
        .map((documento) {
      if (!documento.exists) {
        return null;
      }

      final datos = documento.data();

      if (datos == null) {
        return null;
      }

      return {
        'id': documento.id,
        ...datos,
      };
    });
  }

  Future<Map<String, dynamic>?> obtenerUsuarioActual() async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      return null;
    }

    final documento = await _firestore
        .collection('usuarios')
        .doc(usuario.uid)
        .get();

    if (!documento.exists) {
      return null;
    }

    return documento.data();
  }

  Future<String?> obtenerRolActual() async {
    final datosUsuario = await obtenerUsuarioActual();

    if (datosUsuario == null) {
      return null;
    }

    return datosUsuario['rol'];
  }

  Future<bool> usuarioActivo() async {
    final datosUsuario = await obtenerUsuarioActual();

    if (datosUsuario == null) {
      return false;
    }

    return datosUsuario['activo'] == true;
  }

  Future<void> actualizarNombre(String nombre) async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('No hay usuario autenticado');
    }

    await _firestore.collection('usuarios').doc(usuario.uid).update({
      'nombre': nombre.trim(),
    });
  }

  Future<void> actualizarTema(String tema) async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('No hay usuario autenticado');
    }

    await _firestore.collection('usuarios').doc(usuario.uid).update({
      'tema': tema,
    });
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
}