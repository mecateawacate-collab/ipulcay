import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'modelo_producto.dart';

class ServicioProductos {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> crearProducto({
    required String nombre,
    required String categoria,
    required double precio,
    File? imagen,
  }) async {
    final docProducto = _db.collection('productos').doc();

    String imagenUrl = '';
    String imagenPath = '';

    if (imagen != null) {
      imagenPath = 'productos/${docProducto.id}.jpg';

      final referencia = _storage.ref().child(imagenPath);

      await referencia.putFile(imagen);

      imagenUrl = await referencia.getDownloadURL();
    }

    await docProducto.set({
      'nombre': nombre.trim(),
      'categoria': categoria.trim(),
      'precio': precio,
      'imagenUrl': imagenUrl,
      'imagenPath': imagenPath,
      'activo': true,
      'fechaCreacion': FieldValue.serverTimestamp(),
      'fechaActualizacion': FieldValue.serverTimestamp(),
    });
  }

  Future<void> editarProducto({
    required String id,
    required String nombre,
    required String categoria,
    required double precio,
    File? nuevaImagen,
    String imagenPathActual = '',
  }) async {
    final datosActualizados = <String, dynamic>{
      'nombre': nombre.trim(),
      'categoria': categoria.trim(),
      'precio': precio,
      'fechaActualizacion': FieldValue.serverTimestamp(),
    };

    if (nuevaImagen != null) {
      final String imagenPath = imagenPathActual.isNotEmpty
          ? imagenPathActual
          : 'productos/$id.jpg';

      final referencia = _storage.ref().child(imagenPath);

      await referencia.putFile(nuevaImagen);

      final String imagenUrl = await referencia.getDownloadURL();

      datosActualizados['imagenUrl'] = imagenUrl;
      datosActualizados['imagenPath'] = imagenPath;
    }

    await _db.collection('productos').doc(id).update(datosActualizados);
  }

  Future<void> desactivarProducto(String id) async {
    await _db.collection('productos').doc(id).update({
      'activo': false,
      'fechaActualizacion': FieldValue.serverTimestamp(),
    });
  }

  Future<void> activarProducto(String id) async {
    await _db.collection('productos').doc(id).update({
      'activo': true,
      'fechaActualizacion': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ModeloProducto>> obtenerProductos({
    required bool mostrarActivos,
  }) {
    return _db
        .collection('productos')
        .where('activo', isEqualTo: mostrarActivos)
        .snapshots()
        .map((snapshot) {
      final productos = snapshot.docs.map((doc) {
        return ModeloProducto.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();

      productos.sort((a, b) {
        final compararCategoria = a.categoria.compareTo(b.categoria);

        if (compararCategoria != 0) {
          return compararCategoria;
        }

        return a.nombre.compareTo(b.nombre);
      });

      return productos;
    });
  }
}