import 'package:flutter/material.dart';

import 'modelo_venta.dart';
import 'servicio_ventas.dart';

class PantallaVentas extends StatefulWidget {
  const PantallaVentas({super.key});

  @override
  State<PantallaVentas> createState() => _PantallaVentasEstado();
}

class _PantallaVentasEstado extends State<PantallaVentas> {
  final ServicioVentas servicioVentas = ServicioVentas();

  String filtro = 'todas';
  bool sincronizando = false;

  Future<List<ModeloVenta>> cargarLocales() {
    return servicioVentas.obtenerVentasLocales();
  }

  List<ModeloVenta> filtrarVentas(List<ModeloVenta> ventas) {
    if (filtro == 'todas') return ventas;

    if (filtro == 'locales') {
      return ventas.where((venta) => venta.esLocal).toList();
    }

    if (filtro == 'pendientes') {
      return ventas.where((venta) {
        return venta.estado == 'pendiente' ||
            venta.estadoSincronizacion == 'pendiente_subida';
      }).toList();
    }

    if (filtro == 'sincronizadas') {
      return ventas.where((venta) {
        return venta.estadoSincronizacion == 'sincronizado' && !venta.esLocal;
      }).toList();
    }

    if (filtro == 'errores') {
      return ventas
          .where((venta) => venta.estadoSincronizacion == 'error')
          .toList();
    }

    return ventas;
  }

  Future<void> sincronizarTodo() async {
    if (sincronizando) return;

    setState(() {
      sincronizando = true;
    });

    try {
      final resultado = await servicioVentas.sincronizarPendientes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sincronización terminada. Subidas: ${resultado.subidas}. Errores: ${resultado.errores}.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          sincronizando = false;
        });
      }
    }
  }

  Future<void> sincronizarUno(String codigoPedido) async {
    try {
      await servicioVentas.sincronizarVenta(codigoPedido);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Venta enviada correctamente.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {});
    }
  }

  String textoFecha(DateTime? fecha) {
    if (fecha == null) return 'Sin fecha';

    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$anio $hora:$minuto';
  }

  String textoEstado(String estado) {
    if (estado == 'pendiente') return 'Pendiente';
    if (estado == 'aprobado') return 'Aprobado';
    if (estado == 'rechazado') return 'Rechazado';
    if (estado == 'entregado') return 'Entregado';
    return estado.isEmpty ? 'Sin estado' : estado;
  }

  String textoSincronizacion(ModeloVenta venta) {
    if (venta.esLocal && venta.estadoSincronizacion == 'error') return 'Error local';
    if (venta.esLocal) return 'Guardado local';
    if (venta.estadoSincronizacion == 'sincronizado') return 'Sincronizado';
    if (venta.estadoSincronizacion == 'pendiente_subida') return 'Pendiente de subir';
    if (venta.estadoSincronizacion == 'borrador') return 'Borrador local';
    if (venta.estadoSincronizacion == 'error') return 'Error';
    return venta.estadoSincronizacion.isEmpty ? 'Sin dato' : venta.estadoSincronizacion;
  }

  Color colorEstado(BuildContext context, String estado) {
    final colores = Theme.of(context).colorScheme;

    if (estado == 'pendiente') return colores.primary;
    if (estado == 'aprobado') return Colors.green;
    if (estado == 'rechazado') return colores.error;
    if (estado == 'entregado') return Colors.teal;
    return colores.outline;
  }

  Color colorSincronizacion(BuildContext context, ModeloVenta venta) {
    final colores = Theme.of(context).colorScheme;

    if (venta.esLocal && venta.estadoSincronizacion == 'error') {
      return colores.error;
    }

    if (venta.esLocal) return Colors.orange;
    if (venta.estadoSincronizacion == 'sincronizado') return Colors.green;
    if (venta.estadoSincronizacion == 'pendiente_subida') return Colors.orange;
    if (venta.estadoSincronizacion == 'borrador') return Colors.blueGrey;
    if (venta.estadoSincronizacion == 'error') return colores.error;
    return colores.outline;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis ventas'),
        actions: [
          IconButton(
            tooltip: 'Enviar pendientes',
            onPressed: sincronizando ? null : sincronizarTodo,
            icon: sincronizando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload),
          ),
        ],
      ),
      body: StreamBuilder<List<ModeloVenta>>(
        stream: servicioVentas.escucharMisVentasFirebase(),
        builder: (context, snapshotFirebase) {
          final ventasFirebase = snapshotFirebase.data ?? [];

          return FutureBuilder<List<ModeloVenta>>(
            future: cargarLocales(),
            builder: (context, snapshotLocal) {
              final ventasLocales = snapshotLocal.data ?? [];
              final ventas = [...ventasLocales, ...ventasFirebase];

              ventas.sort((a, b) {
                final fechaA = a.fechaPrincipal ?? DateTime(1900);
                final fechaB = b.fechaPrincipal ?? DateTime(1900);
                return fechaB.compareTo(fechaA);
              });

              final cargando = snapshotFirebase.connectionState ==
                      ConnectionState.waiting &&
                  snapshotLocal.connectionState == ConnectionState.waiting;

              if (cargando) {
                return const Center(child: CircularProgressIndicator());
              }

              final ventasFiltradas = filtrarVentas(ventas);

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (snapshotFirebase.hasError)
                      _AvisoOffline(texto: snapshotFirebase.error.toString()),

                    _ResumenVentas(ventas: ventas),

                    const SizedBox(height: 14),

                    _FiltrosVentas(
                      filtroActual: filtro,
                      onChanged: (valor) {
                        setState(() {
                          filtro = valor;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    if (ventasLocales.isNotEmpty)
                      _PanelPendientes(
                        cantidad: ventasLocales.length,
                        sincronizando: sincronizando,
                        onPressed: sincronizarTodo,
                      ),

                    if (ventas.isEmpty)
                      const _MensajeCentro(
                        icono: Icons.point_of_sale,
                        titulo: 'Todavía no tienes ventas',
                        texto: 'Cuando crees pedidos aparecerán aquí.',
                      )
                    else if (ventasFiltradas.isEmpty)
                      const _MensajeCentro(
                        icono: Icons.filter_alt_off,
                        titulo: 'No hay ventas con este filtro',
                        texto: 'Prueba con otro estado.',
                      )
                    else
                      ...ventasFiltradas.map((venta) {
                        return _TarjetaVenta(
                          venta: venta,
                          fechaTexto: textoFecha(venta.fechaPrincipal),
                          estadoTexto: textoEstado(venta.estado),
                          sincronizacionTexto: textoSincronizacion(venta),
                          estadoColor: colorEstado(context, venta.estado),
                          sincronizacionColor: colorSincronizacion(context, venta),
                          onEnviar: venta.esLocal
                              ? () => sincronizarUno(venta.codigoPedido)
                              : null,
                        );
                      }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AvisoOffline extends StatelessWidget {
  final String texto;

  const _AvisoOffline({required this.texto});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Card(
      color: colores.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.wifi_off, color: colores.onErrorContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'No se pudo conectar con Firebase. Se mostrarán las ventas locales disponibles.',
                style: TextStyle(color: colores.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelPendientes extends StatelessWidget {
  final int cantidad;
  final bool sincronizando;
  final VoidCallback onPressed;

  const _PanelPendientes({
    required this.cantidad,
    required this.sincronizando,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.cloud_upload, color: colores.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$cantidad venta(s) esperando el camión de internet.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            TextButton(
              onPressed: sincronizando ? null : onPressed,
              child: Text(sincronizando ? 'Enviando...' : 'Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumenVentas extends StatelessWidget {
  final List<ModeloVenta> ventas;

  const _ResumenVentas({required this.ventas});

  @override
  Widget build(BuildContext context) {
    final totalVentas = ventas.length;
    final locales = ventas.where((venta) => venta.esLocal).length;
    final pendientes = ventas.where((venta) => venta.estado == 'pendiente').length;
    final sincronizadas = ventas.where((venta) {
      return venta.estadoSincronizacion == 'sincronizado' && !venta.esLocal;
    }).length;
    final totalDinero = ventas.fold<double>(0, (suma, venta) => suma + venta.total);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _DatoResumen(
                  icono: Icons.receipt_long,
                  titulo: 'Ventas',
                  valor: totalVentas.toString(),
                ),
                _DatoResumen(
                  icono: Icons.inventory,
                  titulo: 'Locales',
                  valor: locales.toString(),
                ),
                _DatoResumen(
                  icono: Icons.pending_actions,
                  titulo: 'Pendientes',
                  valor: pendientes.toString(),
                ),
                _DatoResumen(
                  icono: Icons.cloud_done,
                  titulo: 'Subidas',
                  valor: sincronizadas.toString(),
                ),
                _DatoResumen(
                  icono: Icons.payments,
                  titulo: 'Total',
                  valor: 'S/ ${totalDinero.toStringAsFixed(2)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DatoResumen extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _DatoResumen({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Container(
      width: 145,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colores.primary.withAlpha(18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colores.primary.withAlpha(35)),
      ),
      child: Row(
        children: [
          Icon(icono, color: colores.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  valor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltrosVentas extends StatelessWidget {
  final String filtroActual;
  final ValueChanged<String> onChanged;

  const _FiltrosVentas({
    required this.filtroActual,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip('todas', 'Todas'),
          _chip('locales', 'Locales'),
          _chip('pendientes', 'Pendientes'),
          _chip('sincronizadas', 'Subidas'),
          _chip('errores', 'Errores'),
        ],
      ),
    );
  }


  Widget _chip(String valor, String texto) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(texto),
        selected: filtroActual == valor,
        onSelected: (_) => onChanged(valor),
      ),
    );
  }
}

class _TarjetaVenta extends StatelessWidget {
  final ModeloVenta venta;
  final String fechaTexto;
  final String estadoTexto;
  final String sincronizacionTexto;
  final Color estadoColor;
  final Color sincronizacionColor;
  final VoidCallback? onEnviar;

  const _TarjetaVenta({
    required this.venta,
    required this.fechaTexto,
    required this.estadoTexto,
    required this.sincronizacionTexto,
    required this.estadoColor,
    required this.sincronizacionColor,
    required this.onEnviar,
  });

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    venta.codigoPedido,
                    style: textos.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'S/ ${venta.total.toStringAsFixed(2)}',
                  style: textos.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              venta.clienteNombre.isEmpty ? 'Cliente sin nombre' : venta.clienteNombre,
              style: textos.bodyLarge,
            ),

            const SizedBox(height: 4),

            Text(
              'Doc: ${venta.clienteDocumento.isEmpty ? 'Sin documento' : venta.clienteDocumento}',
              style: textos.bodyMedium,
            ),

            const SizedBox(height: 4),

            Text(fechaTexto, style: textos.bodyMedium),

            if (venta.mensajeError.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                venta.mensajeError,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _EtiquetaVenta(
                  texto: estadoTexto,
                  color: estadoColor,
                  icono: Icons.assignment_turned_in,
                ),
                _EtiquetaVenta(
                  texto: sincronizacionTexto,
                  color: sincronizacionColor,
                  icono: venta.esLocal ? Icons.inventory : Icons.cloud_done,
                ),
                _EtiquetaVenta(
                  texto: '${venta.cantidadProductos} productos',
                  color: Theme.of(context).colorScheme.primary,
                  icono: Icons.inventory_2,
                ),
                if (venta.tieneUbicacion)
                  _EtiquetaVenta(
                    texto: 'Con ubicación',
                    color: Theme.of(context).colorScheme.primary,
                    icono: Icons.place,
                  ),
                if (venta.tieneFoto)
                  _EtiquetaVenta(
                    texto: 'Con foto',
                    color: Theme.of(context).colorScheme.primary,
                    icono: Icons.photo_camera,
                  ),
              ],
            ),

            if (onEnviar != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onEnviar,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Enviar esta venta'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EtiquetaVenta extends StatelessWidget {
  final String texto;
  final Color color;
  final IconData icono;

  const _EtiquetaVenta({
    required this.texto,
    required this.color,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16, color: color),
          const SizedBox(width: 5),
          Text(
            texto,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MensajeCentro extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String texto;

  const _MensajeCentro({
    required this.icono,
    required this.titulo,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        children: [
          Icon(icono, size: 64),
          const SizedBox(height: 16),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(texto, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
