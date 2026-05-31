import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServicioLogin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    final credencial = await _auth.signInWithEmailAndPassword(
      email: correo.trim(),
      password: password.trim(),
    );

    final usuario = credencial.user;

    if (usuario == null) {
      await _auth.signOut();
      throw Exception('No se pudo obtener el usuario');
    }

    final documento = await _firestore
        .collection('usuarios')
        .doc(usuario.uid)
        .get();

    if (!documento.exists) {
      await _auth.signOut();
      throw Exception('No existe perfil del usuario');
    }

    final datos = documento.data();

    if (datos == null || datos['activo'] != true) {
      await _auth.signOut();
      throw Exception('Usuario desactivado');
    }

    return credencial;
  }

  Future<void> recuperarPassword({
    required String correo,
  }) async {
    await _auth.sendPasswordResetEmail(
      email: correo.trim(),
    );
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  User? obtenerUsuarioActual() {
    return _auth.currentUser;
  }
}