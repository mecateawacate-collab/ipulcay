import 'dart:math';

String generarCodigoPedido({
  required String vendedorId,
  DateTime? fecha,
}) {
  final DateTime ahora = fecha ?? DateTime.now();

  final String anio = ahora.year.toString();
  final String mes = ahora.month.toString().padLeft(2, '0');
  final String dia = ahora.day.toString().padLeft(2, '0');

  final String hora = ahora.hour.toString().padLeft(2, '0');
  final String minuto = ahora.minute.toString().padLeft(2, '0');
  final String segundo = ahora.second.toString().padLeft(2, '0');

  final String vendedorCorto = vendedorId.length >= 6
      ? vendedorId.substring(0, 6).toUpperCase()
      : vendedorId.toUpperCase();

  final int numeroAleatorio = Random().nextInt(9000) + 1000;

  return 'PED-$anio$mes$dia-$hora$minuto$segundo-$vendedorCorto-$numeroAleatorio';
}