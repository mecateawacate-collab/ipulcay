import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'codigo_pedido.dart';

class ClientePedido {
  final String id;
  final String nombre;
  final String documento;
  final String telefono;
  final String direccionTexto;
  final String tipoNegocio;

  const ClientePedido({
    required this.id,
    required this.nombre,
    required this.documento,
    required this.telefono,
    required this.direccionTexto,
    required this.tipoNegocio,
  });

  bool get existe => id.isNotEmpty;

  factory ClientePedido.fromMap(String id, Map<String, dynamic> data) {
    return ClientePedido(
      id: id,
      nombre: data['nombre'] ?? '',
      documento: data['documento'] ?? data['dni'] ?? '',
      telefono: data['telefono'] ?? '',
      direccionTexto: data['direccionTexto'] ?? '',
      tipoNegocio: data['tipoNegocio'] ?? 'No especificado',
    );
  }
}

class ProductoPedido {
  final String id;
  final String nombre;
  final String categoria;
  final double precio;
  final String imagenUrl;

  const ProductoPedido({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.imagenUrl,
  });

  factory ProductoPedido.fromMap(String id, Map<String, dynamic> data) {
    return ProductoPedido(
      id: id,
      nombre: data['nombre'] ?? '',
      categoria: data['categoria'] ?? 'Otros',
      precio: _numero(data['precio']),
      imagenUrl: data['imagenUrl'] ?? data['fotoUrl'] ?? data['imageUrl'] ?? '',
    );
  }

  static double _numero(dynamic valor) {
    if (valor is int) return valor.toDouble();
    if (valor is double) return valor;
    return double.tryParse(valor.toString()) ?? 0;
  }
}

class ItemPedido {
  final String productoId;
  final String nombre;
  final String categoria;
  final int cantidad;
  final double precioUnitario;
  final double precioTotal;
  final String imagenUrl;

  const ItemPedido({
    required this.productoId,
    required this.nombre,
    required this.categoria,
    required this.cantidad,
    required this.precioUnitario,
    required this.precioTotal,
    required this.imagenUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'productoId': productoId,
      'nombre': nombre,
      'categoria': categoria,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'precioTotal': precioTotal,
      'imagenUrl': imagenUrl,
    };
  }
}

class ServicioPedidos {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<ClientePedido>> obtenerClientes() async {
    final snapshot = await _db
        .collection('clientes')
        .where('activo', isEqualTo: true)
        .get();

    final clientes = snapshot.docs.map((doc) {
      return ClientePedido.fromMap(doc.id, doc.data());
    }).toList();

    clientes.sort((a, b) {
      return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
    });

    return clientes;
  }

  Future<List<ProductoPedido>> obtenerProductos() async {
    final snapshot = await _db
        .collection('productos')
        .where('activo', isEqualTo: true)
        .get();

    final productos = snapshot.docs.map((doc) {
      return ProductoPedido.fromMap(doc.id, doc.data());
    }).toList();

    productos.sort((a, b) {
      return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
    });

    return productos;
  }

  Future<ClientePedido?> buscarClientePorDocumento(String documento) async {
    final documentoLimpio = _limpiarNumero(documento);

    if (documentoLimpio.isEmpty) return null;

    final snapshot = await _db
        .collection('clientes')
        .where('documento', isEqualTo: documentoLimpio)
        .where('activo', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return ClientePedido.fromMap(doc.id, doc.data());
  }

  Future<ClientePedido> crearClienteAutomatico({
    required String nombre,
    required String documento,
    required String telefono,
    required String direccionTexto,
    required String tipoNegocio,
  }) async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('No hay usuario autenticado.');
    }

    final nombreLimpio = _limpiarNombre(nombre);
    final documentoLimpio = _limpiarNumero(documento);
    final telefonoLimpio = _limpiarNumero(telefono);
    final tipoNegocioLimpio = tipoNegocio.trim();
    final direccionLimpia = direccionTexto.trim();

    if (nombreLimpio.isEmpty) {
      throw Exception('Ingresa el nombre del cliente.');
    }

    if (documentoLimpio.isEmpty) {
      throw Exception('Ingresa el documento del cliente.');
    }

    if (documentoLimpio.length < 8) {
      throw Exception('El documento debe tener mínimo 8 números.');
    }

    final clienteExistente = await buscarClientePorDocumento(documentoLimpio);

    if (clienteExistente != null) {
      return clienteExistente;
    }

    final doc = await _db.collection('clientes').add({
      'nombre': nombreLimpio,
      'nombreBusqueda': nombreLimpio.toLowerCase(),
      'documento': documentoLimpio,
      'telefono': telefonoLimpio,
      'direccionTexto': direccionLimpia,
      'tipoNegocio': tipoNegocioLimpio,
      'activo': true,
      'fechaCreacion': FieldValue.serverTimestamp(),
      'fechaActualizacion': FieldValue.serverTimestamp(),
      'creadoPorId': usuario.uid,
      'creadoPorNombre': usuario.email ?? '',
    });

    return ClientePedido(
      id: doc.id,
      nombre: nombreLimpio,
      documento: documentoLimpio,
      telefono: telefonoLimpio,
      direccionTexto: direccionLimpia,
      tipoNegocio: tipoNegocioLimpio,
    );
  }

  Future<String> subirFotoReferencia(File foto) async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('No hay usuario autenticado.');
    }

    final nombreArchivo = DateTime.now().millisecondsSinceEpoch.toString();

    final referencia = _storage.ref(
      'pedidos/fotos_referencia/${usuario.uid}/$nombreArchivo.jpg',
    );

    await referencia.putFile(
      foto,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return referencia.getDownloadURL();
  }

Future<String> crearPedido({
  required ClientePedido cliente,
  required String direccionTexto,
  required DateTime fechaEmision,
  required List<ItemPedido> productos,
  required double total,
  required String metodoPago,
  required String metodoPagoOtro,
  required String observacionVendedor,
  required double? latitud,
  required double? longitud,
  required String fotoReferenciaUrl,
  String? codigoPedidoManual,
}) async {
  final User? usuario = _auth.currentUser;

  if (usuario == null) {
    throw Exception('No hay usuario autenticado.');
  }

  if (productos.isEmpty) {
    throw Exception('Agrega al menos un producto al pedido.');
  }

  final String codigoPedido = codigoPedidoManual ??
      generarCodigoPedido(
        vendedorId: usuario.uid,
      );

  final DocumentReference<Map<String, dynamic>> referenciaPedido =
      _db.collection('pedidos').doc(codigoPedido);

  final documentoExistente = await referenciaPedido.get();

  if (documentoExistente.exists) {
    throw Exception('Ya existe un pedido con este código. Intenta nuevamente.');
  }

  await referenciaPedido.set({
    'codigoPedido': codigoPedido,
    'codigoVenta': codigoPedido,
    'codigoUnico': codigoPedido,

    'empresaNombre': 'INDUSTRIAS PULCAY S.A.C',
    'empresaRuc': '20123456789',
    'empresaDireccion': 'JR. Ayacucho',
    'empresaTelefono': '987 123 654',
    'empresaEmail': 'ipulcay.ventas@gmail.com',

    'clienteId': cliente.id,
    'clienteNombre': cliente.nombre,
    'clienteTipoNegocio': cliente.tipoNegocio,
    'clienteDocumento': cliente.documento,
    'clienteTelefono': cliente.telefono,
    'clienteDireccion': direccionTexto.trim(),

    'latitud': latitud,
    'longitud': longitud,
    'fotoReferenciaUrl': fotoReferenciaUrl,

    'vendedorId': usuario.uid,
    'vendedorEmail': usuario.email ?? '',

    'fechaEmision': Timestamp.fromDate(fechaEmision),
    'fechaCreacion': FieldValue.serverTimestamp(),
    'fechaRevision': null,

    'productos': productos.map((item) => item.toMap()).toList(),

    'total': total,
    'incluyeIgv': true,
    'metodoPago': metodoPago,
    'metodoPagoOtro': metodoPagoOtro.trim(),

    'observacionVendedor': observacionVendedor.trim(),
    'observacionSupervisor': '',

    'estado': 'pendiente',
    'estadoSincronizacion': 'sincronizado',
    'origen': 'app_vendedor',
    'activo': true,
  });

  return codigoPedido;
}

  String _limpiarNumero(String valor) {
    return valor.trim().replaceAll(RegExp(r'[^0-9]'), '');
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
}