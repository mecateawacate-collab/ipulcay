import 'package:flutter/material.dart';

import '../ventas/pantalla_ventas.dart';

class DialogosPedido {
  static Future<void> mostrarPedidoCreado({
    required BuildContext context,
    required String codigoPedido,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Pedido creado con éxito'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('El pedido fue enviado correctamente a Firebase.'),
              const SizedBox(height: 12),
              const Text(
                'Código:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              SelectableText(codigoPedido),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text('Cerrar'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaVentas(),
                  ),
                );
              },
              icon: const Icon(Icons.point_of_sale),
              label: const Text('Ver mis ventas'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> mostrarPedidoLocalCreado({
    required BuildContext context,
    required String codigoPedido,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Pedido guardado localmente'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'No se pudo enviar a Firebase ahora. El pedido quedó guardado en el celular y podrás enviarlo desde Mis ventas cuando vuelva internet.',
              ),
              const SizedBox(height: 12),
              const Text(
                'Código:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              SelectableText(codigoPedido),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text('Cerrar'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaVentas(),
                  ),
                );
              },
              icon: const Icon(Icons.point_of_sale),
              label: const Text('Ver mis ventas'),
            ),
          ],
        );
      },
    );
  }
}