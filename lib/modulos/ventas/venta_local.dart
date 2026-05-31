import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class VentaLocal {
  static const String _nombreArchivo = 'ventas_locales.json';

  Future<File> _archivo() async {
    final directorio = await getApplicationDocumentsDirectory();
    return File('${directorio.path}/$_nombreArchivo');
  }

  Future<List<Map<String, dynamic>>> obtenerVentas() async {
    final archivo = await _archivo();

    if (!await archivo.exists()) {
      return [];
    }

    final contenido = await archivo.readAsString();

    if (contenido.trim().isEmpty) {
      return [];
    }

    final datos = jsonDecode(contenido);

    if (datos is! List) {
      return [];
    }

    return datos.map((item) {
      if (item is Map<String, dynamic>) return item;
      if (item is Map) return Map<String, dynamic>.from(item);
      return <String, dynamic>{};
    }).where((item) {
      return item['codigoPedido'] != null;
    }).toList();
  }

  Future<void> guardarVenta(Map<String, dynamic> venta) async {
    final ventas = await obtenerVentas();
    final codigo = venta['codigoPedido']?.toString() ?? '';

    if (codigo.isEmpty) {
      throw Exception('No se puede guardar una venta local sin código.');
    }

    final index = ventas.indexWhere((item) => item['codigoPedido'] == codigo);

    if (index >= 0) {
      ventas[index] = venta;
    } else {
      ventas.add(venta);
    }

    await _guardarTodo(ventas);
  }

  Future<void> eliminarVenta(String codigoPedido) async {
    final ventas = await obtenerVentas();
    ventas.removeWhere((item) => item['codigoPedido'] == codigoPedido);
    await _guardarTodo(ventas);
  }

  Future<void> marcarError({
    required String codigoPedido,
    required String mensaje,
  }) async {
    final ventas = await obtenerVentas();
    final index = ventas.indexWhere((item) => item['codigoPedido'] == codigoPedido);

    if (index < 0) return;

    ventas[index]['estadoSincronizacion'] = 'error';
    ventas[index]['mensajeError'] = mensaje;
    ventas[index]['fechaUltimoIntento'] = DateTime.now().toIso8601String();

    await _guardarTodo(ventas);
  }

  Future<void> _guardarTodo(List<Map<String, dynamic>> ventas) async {
    final archivo = await _archivo();
    const encoder = JsonEncoder.withIndent('  ');
    await archivo.writeAsString(encoder.convert(ventas));
  }
}
