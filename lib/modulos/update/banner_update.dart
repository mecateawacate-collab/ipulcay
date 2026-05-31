import 'package:flutter/material.dart';

import 'servicio_update.dart';
import 'pantalla_bloqueo_update.dart';

class BannerUpdate extends StatefulWidget {
  const BannerUpdate({super.key});

  @override
  State<BannerUpdate> createState() => _BannerUpdateEstado();
}

class _BannerUpdateEstado extends State<BannerUpdate> {
  final ServicioUpdate servicioUpdate = ServicioUpdate();

  bool cargando = true;
  bool descargando = false;
  ResultadoUpdate? resultado;
  bool ocultarBanner = false;
  bool bloqueoEnviado = false;

  @override
  void initState() {
    super.initState();
    revisarUpdate();
  }

  Future<void> revisarUpdate() async {
    try {
      final ResultadoUpdate respuesta = await servicioUpdate.revisarUpdate();

      if (!mounted) return;

      if (respuesta.hayUpdate &&
          respuesta.obligatorio &&
          respuesta.datos != null) {
        abrirPantallaBloqueo(respuesta.datos!);
        return;
      }

      setState(() {
        resultado = respuesta;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });
    }
  }

  void abrirPantallaBloqueo(DatosUpdate datos) {
    if (bloqueoEnviado) return;

    bloqueoEnviado = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => PantallaBloqueoUpdate(
            datos: datos,
          ),
        ),
        (route) => false,
      );
    });
  }

  Future<void> abrirUpdate(DatosUpdate datos) async {
    setState(() {
      descargando = true;
    });

    try {
      await servicioUpdate.instalarApk(datos);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo descargar la actualización: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      descargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (cargando || ocultarBanner) {
      return const SizedBox.shrink();
    }

    final ResultadoUpdate? info = resultado;

    if (info == null || !info.hayUpdate || info.datos == null) {
      return const SizedBox.shrink();
    }

    final DatosUpdate datos = info.datos!;
    final ThemeData tema = Theme.of(context);
    final ColorScheme colores = tema.colorScheme;
    final TextTheme textos = tema.textTheme;

    final bool obligatorio = info.obligatorio;

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: obligatorio ? colores.error : colores.primary,
            width: 1.4,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: (obligatorio ? colores.error : colores.primary)
                      .withAlpha(30),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  obligatorio
                      ? Icons.warning_amber_rounded
                      : Icons.system_update_alt,
                  color: obligatorio ? colores.error : colores.primary,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      datos.titulo,
                      style: textos.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      datos.mensaje,
                      style: textos.bodyMedium,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Versión nueva: ${datos.versionName}',
                      style: textos.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: descargando
                                ? null
                                : () {
                                    abrirUpdate(datos);
                                  },
                            icon: descargando
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.download),
                            label: Text(
                              descargando ? 'Descargando...' : 'Actualizar',
                            ),
                          ),
                        ),

                        if (!obligatorio) ...[
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: descargando
                                ? null
                                : () {
                                    setState(() {
                                      ocultarBanner = true;
                                    });
                                  },
                            icon: const Icon(Icons.close),
                            tooltip: 'Ocultar',
                          ),
                        ],
                      ],
                    ),

                    if (obligatorio) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Esta actualización es obligatoria para continuar.',
                        style: textos.bodyMedium?.copyWith(
                          color: colores.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}