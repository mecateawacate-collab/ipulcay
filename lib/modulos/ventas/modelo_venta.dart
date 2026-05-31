import 'package:cloud_firestore/cloud_firestore.dart';

class ModeloVenta {
  final String id;
  final String codigoPedido;
  final String codigoVenta;
  final String clienteId;
  final String clienteNombre;
  final String clienteDocumento;
  final String clienteTelefono;
  final String clienteDireccion;
  final String vendedorId;
  final String vendedorEmail;
  final DateTime? fechaCreacion;
  final DateTime? fechaEmision;
  final double total;
  final String estado;
  final String estadoSincronizacion;
  final String metodoPago;
  final String metodoPagoOtro;
  final String observacionVendedor;
  final String observacionSupervisor;
  final double? latitud;
  final double? longitud;
  final String fotoReferenciaUrl;
  final String fotoReferenciaLocalPath;
  final List<Map<String, dynamic>> productos;
  final bool activo;
  final bool esLocal;
  final String mensajeError;

  const ModeloVenta({
    required this.id,
    required this.codigoPedido,
    required this.codigoVenta,
    required this.clienteId,
    required this.clienteNombre,
    required this.clienteDocumento,
    required this.clienteTelefono,
    required this.clienteDireccion,
    required this.vendedorId,
    required this.vendedorEmail,
    required this.fechaCreacion,
    required this.fechaEmision,
    required this.total,
    required this.estado,
    required this.estadoSincronizacion,
    required this.metodoPago,
    required this.metodoPagoOtro,
    required this.observacionVendedor,
    required this.observacionSupervisor,
    required this.latitud,
    required this.longitud,
    required this.fotoReferenciaUrl,
    required this.fotoReferenciaLocalPath,
    required this.productos,
    required this.activo,
    required this.esLocal,
    required this.mensajeError,
  });

  factory ModeloVenta.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return ModeloVenta.fromMap(doc.id, data, esLocal: false);
  }

  factory ModeloVenta.fromLocal(Map<String, dynamic> data) {
    final codigo = _texto(
      data['codigoPedido'] ?? data['codigoVenta'] ?? data['codigoUnico'],
    );
    return ModeloVenta.fromMap(
      codigo,
      data,
      esLocal: true,
    );
  }

  factory ModeloVenta.fromMap(
    String id,
    Map<String, dynamic> data, {
    required bool esLocal,
  }) {
    final codigo = _texto(
      data['codigoPedido'] ?? data['codigoVenta'] ?? data['codigoUnico'] ?? id,
    );

    return ModeloVenta(
      id: id,
      codigoPedido: codigo,
      codigoVenta: _texto(data['codigoVenta'] ?? codigo),
      clienteId: _texto(data['clienteId']),
      clienteNombre: _texto(data['clienteNombre']),
      clienteDocumento: _texto(data['clienteDocumento']),
      clienteTelefono: _texto(data['clienteTelefono']),
      clienteDireccion: _texto(data['clienteDireccion']),
      vendedorId: _texto(data['vendedorId']),
      vendedorEmail: _texto(data['vendedorEmail']),
      fechaCreacion: _fecha(data['fechaCreacion'] ?? data['fechaCreacionLocal']),
      fechaEmision: _fecha(data['fechaEmision']),
      total: _numero(data['total']),
      estado: _texto(data['estado'], defecto: 'pendiente'),
      estadoSincronizacion: _texto(
        data['estadoSincronizacion'],
        defecto: esLocal ? 'pendiente_subida' : 'sincronizado',
      ),
      metodoPago: _texto(data['metodoPago']),
      metodoPagoOtro: _texto(data['metodoPagoOtro']),
      observacionVendedor: _texto(data['observacionVendedor']),
      observacionSupervisor: _texto(data['observacionSupervisor']),
      latitud: _numeroNullable(data['latitud']),
      longitud: _numeroNullable(data['longitud']),
      fotoReferenciaUrl: _texto(data['fotoReferenciaUrl']),
      fotoReferenciaLocalPath: _texto(data['fotoReferenciaLocalPath']),
      productos: _listaMapas(data['productos']),
      activo: data['activo'] != false,
      esLocal: esLocal,
      mensajeError: _texto(data['mensajeError']),
    );
  }

  DateTime? get fechaPrincipal => fechaCreacion ?? fechaEmision;

  int get cantidadProductos {
    int cantidad = 0;
    for (final producto in productos) {
      final valor = producto['cantidad'];
      if (valor is int) {
        cantidad += valor;
      } else {
        cantidad += int.tryParse(valor.toString()) ?? 0;
      }
    }
    return cantidad;
  }

  bool get tieneUbicacion => latitud != null && longitud != null;

  bool get tieneFoto {
    return fotoReferenciaUrl.trim().isNotEmpty ||
        fotoReferenciaLocalPath.trim().isNotEmpty;
  }

  bool get puedeSubir {
    return codigoPedido.trim().isNotEmpty &&
        clienteNombre.trim().isNotEmpty &&
        clienteDocumento.trim().isNotEmpty &&
        clienteDireccion.trim().isNotEmpty &&
        productos.isNotEmpty &&
        tieneUbicacion;
  }

  static String _texto(dynamic valor, {String defecto = ''}) {
    if (valor == null) return defecto;
    final texto = valor.toString().trim();
    return texto.isEmpty ? defecto : texto;
  }

  static double _numero(dynamic valor) {
    if (valor is int) return valor.toDouble();
    if (valor is double) return valor;
    return double.tryParse(valor.toString()) ?? 0;
  }

  static double? _numeroNullable(dynamic valor) {
    if (valor == null) return null;
    if (valor is int) return valor.toDouble();
    if (valor is double) return valor;
    return double.tryParse(valor.toString());
  }

  static DateTime? _fecha(dynamic valor) {
    if (valor == null) return null;
    if (valor is Timestamp) return valor.toDate();
    if (valor is DateTime) return valor;
    return DateTime.tryParse(valor.toString());
  }

  static List<Map<String, dynamic>> _listaMapas(dynamic valor) {
    if (valor is! List) return [];
    return valor.map((item) {
      if (item is Map<String, dynamic>) return item;
      if (item is Map) return Map<String, dynamic>.from(item);
      return <String, dynamic>{};
    }).toList();
  }
}
