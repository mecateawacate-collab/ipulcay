import 'package:firebase_auth/firebase_auth.dart';

import '../ventas/venta_local.dart';
import 'servicio_pedidos.dart';

class ServicioPedidoLocal {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final VentaLocal _ventaLocal = VentaLocal();

  Future<void> guardarPedidoLocal({
    required String codigoPedido,
    required ClientePedido cliente,
    required DateTime fechaEmision,
    required List<ItemPedido> productos,
    required double total,
    required String metodoPago,
    required String metodoPagoOtro,
    required String observacionVendedor,
    required double? latitud,
    required double? longitud,
    required String direccionTexto,
    required String fotoReferenciaLocalPath,
  }) async {
    final User? usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('No hay usuario autenticado.');
    }

    final Map<String, dynamic> venta = {
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
      'fotoReferenciaUrl': '',
      'fotoReferenciaLocalPath': fotoReferenciaLocalPath,

      'vendedorId': usuario.uid,
      'vendedorEmail': usuario.email ?? '',

      'fechaEmision': fechaEmision.toIso8601String(),
      'fechaCreacionLocal': DateTime.now().toIso8601String(),
      'fechaRevision': null,

      'productos': productos.map((item) => item.toMap()).toList(),

      'total': total,
      'incluyeIgv': true,
      'metodoPago': metodoPago,
      'metodoPagoOtro': metodoPagoOtro.trim(),

      'observacionVendedor': observacionVendedor.trim(),
      'observacionSupervisor': '',

      'estado': 'pendiente',
      'estadoSincronizacion': 'pendiente_subida',
      'origen': 'app_vendedor_local',
      'activo': true,
    };

    await _ventaLocal.guardarVenta(venta);
  }
}