import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'modelo_venta.dart';
import 'venta_local.dart';

class ResultadoSincronizacion {
  final int subidas;
  final int errores;

  const ResultadoSincronizacion({
    required this.subidas,
    required this.errores,
  });
}

class ServicioVentas {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final VentaLocal _ventaLocal = VentaLocal();

  User? get usuarioActual => _auth.currentUser;

  Stream<List<ModeloVenta>> escucharMisVentasFirebase() {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      return Stream.value([]);
    }

    return _db
        .collection('pedidos')
        .where('vendedorId', isEqualTo: usuario.uid)
        .where('activo', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final ventas = snapshot.docs.map(ModeloVenta.fromDoc).toList();
      _ordenarVentas(ventas);
      return ventas;
    });
  }

  Future<List<ModeloVenta>> obtenerVentasLocales() async {
    final ventas = await _ventaLocal.obtenerVentas();
    final modelos = ventas.map(ModeloVenta.fromLocal).toList();
    _ordenarVentas(modelos);
    return modelos;
  }

  Future<ResultadoSincronizacion> sincronizarPendientes() async {
    final ventas = await _ventaLocal.obtenerVentas();

    int subidas = 0;
    int errores = 0;

    for (final venta in ventas) {
      final codigo = venta['codigoPedido']?.toString() ?? '';

      if (codigo.isEmpty) continue;

      try {
        await _subirVentaLocal(venta);
        await _ventaLocal.eliminarVenta(codigo);
        subidas++;
      } catch (e) {
        errores++;
        await _ventaLocal.marcarError(
          codigoPedido: codigo,
          mensaje: e.toString().replaceAll('Exception: ', ''),
        );
      }
    }

    return ResultadoSincronizacion(subidas: subidas, errores: errores);
  }

  Future<void> sincronizarVenta(String codigoPedido) async {
    final ventas = await _ventaLocal.obtenerVentas();
    final venta = ventas.firstWhere(
      (item) => item['codigoPedido'] == codigoPedido,
      orElse: () => <String, dynamic>{},
    );

    if (venta.isEmpty) {
      throw Exception('No se encontró la venta local.');
    }

    try {
      await _subirVentaLocal(venta);
      await _ventaLocal.eliminarVenta(codigoPedido);
    } catch (e) {
      await _ventaLocal.marcarError(
        codigoPedido: codigoPedido,
        mensaje: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> _subirVentaLocal(Map<String, dynamic> venta) async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('No hay usuario autenticado.');
    }

    final codigoPedido = venta['codigoPedido']?.toString() ?? '';

    if (codigoPedido.isEmpty) {
      throw Exception('La venta local no tiene código.');
    }

    final docPedido = _db.collection('pedidos').doc(codigoPedido);
    final existePedido = await docPedido.get();

    if (existePedido.exists) {
      return;
    }

    final cliente = await _obtenerOCrearCliente(venta, usuario);
    final fotoUrl = await _resolverFotoUrl(venta, usuario.uid, codigoPedido);

    final fechaEmision = _fecha(venta['fechaEmision']) ?? DateTime.now();
    final fechaCreacion = _fecha(venta['fechaCreacionLocal']) ?? DateTime.now();

    final datosPedido = Map<String, dynamic>.from(venta);

    datosPedido.remove('fotoReferenciaLocalPath');
    datosPedido.remove('fechaCreacionLocal');
    datosPedido.remove('mensajeError');
    datosPedido.remove('fechaUltimoIntento');

    datosPedido.addAll({
      'clienteId': cliente.id,
      'clienteNombre': cliente.nombre,
      'clienteDocumento': cliente.documento,
      'clienteTelefono': cliente.telefono,
      'clienteDireccion': cliente.direccionTexto,
      'clienteTipoNegocio': cliente.tipoNegocio,
      'fotoReferenciaUrl': fotoUrl,
      'vendedorId': usuario.uid,
      'vendedorEmail': usuario.email ?? '',
      'fechaEmision': Timestamp.fromDate(fechaEmision),
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaRevision': null,
      'estado': 'pendiente',
      'estadoSincronizacion': 'sincronizado',
      'origen': 'app_vendedor_local_sincronizado',
      'activo': true,
    });

    await docPedido.set(datosPedido);
  }

  Future<_ClienteVenta> _obtenerOCrearCliente(
    Map<String, dynamic> venta,
    User usuario,
  ) async {
    final clienteId = _texto(venta['clienteId']);

    if (clienteId.isNotEmpty) {
      return _ClienteVenta(
        id: clienteId,
        nombre: _texto(venta['clienteNombre']),
        documento: _texto(venta['clienteDocumento']),
        telefono: _texto(venta['clienteTelefono']),
        direccionTexto: _texto(venta['clienteDireccion']),
        tipoNegocio: _texto(venta['clienteTipoNegocio'], defecto: 'No especificado'),
      );
    }

    final documento = _limpiarNumero(_texto(venta['clienteDocumento']));

    if (documento.isEmpty) {
      throw Exception('Falta el documento del cliente.');
    }

    final snapshot = await _db
        .collection('clientes')
        .where('documento', isEqualTo: documento)
        .where('activo', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final data = doc.data();

      return _ClienteVenta(
        id: doc.id,
        nombre: _texto(data['nombre']),
        documento: _texto(data['documento']),
        telefono: _texto(data['telefono']),
        direccionTexto: _texto(data['direccionTexto']),
        tipoNegocio: _texto(data['tipoNegocio'], defecto: 'No especificado'),
      );
    }

    final nombre = _limpiarNombre(_texto(venta['clienteNombre']));
    final telefono = _limpiarNumero(_texto(venta['clienteTelefono']));
    final direccionTexto = _texto(venta['clienteDireccion']);
    final tipoNegocio = _texto(venta['clienteTipoNegocio'], defecto: 'No especificado');

    if (nombre.isEmpty) {
      throw Exception('Falta el nombre del cliente.');
    }

    final doc = await _db.collection('clientes').add({
      'nombre': nombre,
      'nombreBusqueda': nombre.toLowerCase(),
      'documento': documento,
      'telefono': telefono,
      'direccionTexto': direccionTexto,
      'tipoNegocio': tipoNegocio,
      'activo': true,
      'fechaCreacion': FieldValue.serverTimestamp(),
      'fechaActualizacion': FieldValue.serverTimestamp(),
      'creadoPorId': usuario.uid,
      'creadoPorNombre': usuario.email ?? '',
    });

    return _ClienteVenta(
      id: doc.id,
      nombre: nombre,
      documento: documento,
      telefono: telefono,
      direccionTexto: direccionTexto,
      tipoNegocio: tipoNegocio,
    );
  }

  Future<String> _resolverFotoUrl(
    Map<String, dynamic> venta,
    String vendedorId,
    String codigoPedido,
  ) async {
    final fotoUrl = _texto(venta['fotoReferenciaUrl']);

    if (fotoUrl.isNotEmpty) {
      return fotoUrl;
    }

    final rutaLocal = _texto(venta['fotoReferenciaLocalPath']);

    if (rutaLocal.isEmpty) {
      return '';
    }

    final archivo = File(rutaLocal);

    if (!await archivo.exists()) {
      return '';
    }

    final referencia = _storage.ref(
      'pedidos/fotos_referencia/$vendedorId/$codigoPedido.jpg',
    );

    await referencia.putFile(
      archivo,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return referencia.getDownloadURL();
  }

  void _ordenarVentas(List<ModeloVenta> ventas) {
    ventas.sort((a, b) {
      final fechaA = a.fechaPrincipal ?? DateTime(1900);
      final fechaB = b.fechaPrincipal ?? DateTime(1900);
      return fechaB.compareTo(fechaA);
    });
  }

  String _texto(dynamic valor, {String defecto = ''}) {
    if (valor == null) return defecto;
    final texto = valor.toString().trim();
    return texto.isEmpty ? defecto : texto;
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

  DateTime? _fecha(dynamic valor) {
    if (valor == null) return null;
    if (valor is Timestamp) return valor.toDate();
    if (valor is DateTime) return valor;
    return DateTime.tryParse(valor.toString());
  }
}

class _ClienteVenta {
  final String id;
  final String nombre;
  final String documento;
  final String telefono;
  final String direccionTexto;
  final String tipoNegocio;

  const _ClienteVenta({
    required this.id,
    required this.nombre,
    required this.documento,
    required this.telefono,
    required this.direccionTexto,
    required this.tipoNegocio,
  });
}
