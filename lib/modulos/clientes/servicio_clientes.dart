import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'modelo_cliente.dart';

class ServicioClientes {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _clientes {
    return _db.collection('clientes');
  }

  Stream<List<ModeloCliente>> obtenerClientes() {
    return _clientes
        .where('activo', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final clientes = snapshot.docs.map((doc) {
        return ModeloCliente.fromMap(doc.id, doc.data());
      }).toList();

      clientes.sort((a, b) {
        return a.nombreBusqueda.compareTo(b.nombreBusqueda);
      });

      return clientes;
    });
  }

  Future<void> crearCliente({
    required String nombre,
    required String documento,
    required String telefono,
    required String direccionTexto,
    required String tipoNegocio,
  }) async {
    final String nombreLimpio = _limpiarNombre(nombre);
    final String documentoLimpio = _limpiarDocumento(documento);
    final String telefonoLimpio = _limpiarNumero(telefono);
    final String direccionLimpia = direccionTexto.trim();
    final String tipoNegocioLimpio = tipoNegocio.trim();

    if (nombreLimpio.isEmpty) {
      throw Exception('El nombre del cliente es obligatorio.');
    }

    if (documentoLimpio.isEmpty) {
      throw Exception('El documento del cliente es obligatorio.');
    }

    if (documentoLimpio.length < 8) {
      throw Exception('El documento debe tener al menos 8 números.');
    }

    final bool existe = await existeDocumento(documentoLimpio);

    if (existe) {
      throw Exception('Ya existe un cliente con ese documento.');
    }

    final User? usuario = _auth.currentUser;

    await _clientes.add({
      'nombre': nombreLimpio,
      'nombreBusqueda': nombreLimpio.toLowerCase(),
      'documento': documentoLimpio,
      'telefono': telefonoLimpio,
      'direccionTexto': direccionLimpia,
      'tipoNegocio': tipoNegocioLimpio,
      'activo': true,
      'fechaCreacion': FieldValue.serverTimestamp(),
      'fechaActualizacion': FieldValue.serverTimestamp(),
      'creadoPorId': usuario?.uid ?? '',
      'creadoPorNombre': usuario?.email ?? '',
    });
  }

  Future<void> actualizarCliente({
    required String clienteId,
    required String nombre,
    required String documento,
    required String telefono,
    required String direccionTexto,
    required String tipoNegocio,
  }) async {
    final String nombreLimpio = _limpiarNombre(nombre);
    final String documentoLimpio = _limpiarDocumento(documento);
    final String telefonoLimpio = _limpiarNumero(telefono);
    final String direccionLimpia = direccionTexto.trim();
    final String tipoNegocioLimpio = tipoNegocio.trim();

    if (clienteId.isEmpty) {
      throw Exception('No se encontró el cliente a editar.');
    }

    if (nombreLimpio.isEmpty) {
      throw Exception('El nombre del cliente es obligatorio.');
    }

    if (documentoLimpio.isEmpty) {
      throw Exception('El documento del cliente es obligatorio.');
    }

    if (documentoLimpio.length < 8) {
      throw Exception('El documento debe tener al menos 8 números.');
    }

    final bool existe = await existeDocumento(
      documentoLimpio,
      ignorarClienteId: clienteId,
    );

    if (existe) {
      throw Exception('Ya existe otro cliente con ese documento.');
    }

    await _clientes.doc(clienteId).update({
      'nombre': nombreLimpio,
      'nombreBusqueda': nombreLimpio.toLowerCase(),
      'documento': documentoLimpio,
      'telefono': telefonoLimpio,
      'direccionTexto': direccionLimpia,
      'tipoNegocio': tipoNegocioLimpio,
      'fechaActualizacion': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> existeDocumento(
    String documento, {
    String? ignorarClienteId,
  }) async {
    final String documentoLimpio = _limpiarDocumento(documento);

    final consultaDocumento = await _clientes
        .where('documento', isEqualTo: documentoLimpio)
        .where('activo', isEqualTo: true)
        .limit(3)
        .get();

    for (final doc in consultaDocumento.docs) {
      if (doc.id != ignorarClienteId) {
        return true;
      }
    }

    final consultaDniAntiguo = await _clientes
        .where('dni', isEqualTo: documentoLimpio)
        .where('activo', isEqualTo: true)
        .limit(3)
        .get();

    for (final doc in consultaDniAntiguo.docs) {
      if (doc.id != ignorarClienteId) {
        return true;
      }
    }

    return false;
  }

  String _limpiarNombre(String valor) {
    final limpio = valor.trim().replaceAll(RegExp(r'\s+'), ' ');

    if (limpio.isEmpty) return '';

    return limpio
        .split(' ')
        .map((parte) {
          if (parte.isEmpty) return '';
          return parte[0].toUpperCase() + parte.substring(1).toLowerCase();
        })
        .join(' ');
  }

  String _limpiarNumero(String valor) {
    return valor.trim().replaceAll(RegExp(r'[^0-9]'), '');
  }

  String _limpiarDocumento(String valor) {
    return _limpiarNumero(valor);
  }
}