import 'package:flutter/material.dart';

import 'servicio_update.dart';

class PantallaBloqueoUpdate extends StatefulWidget {
  final DatosUpdate datos;

  const PantallaBloqueoUpdate({
    super.key,
    required this.datos,
  });

  @override
  State<PantallaBloqueoUpdate> createState() => _PantallaBloqueoUpdateEstado();
}

class _PantallaBloqueoUpdateEstado extends State<PantallaBloqueoUpdate> {
  final ServicioUpdate servicioUpdate = ServicioUpdate();

  bool abriendo = false;

  Future<void> abrirUpdate() async {
    setState(() {
      abriendo = true;
    });

    try {
      await servicioUpdate.instalarApk(widget.datos);
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
      abriendo = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textos = Theme.of(context).textTheme;
    final ColorScheme colores = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(26),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          color: colores.error.withAlpha(30),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Icon(
                          Icons.system_update_alt,
                          color: colores.error,
                          size: 44,
                        ),
                      ),

                      const SizedBox(height: 22),

                      Text(
                        widget.datos.titulo,
                        textAlign: TextAlign.center,
                        style: textos.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        widget.datos.mensaje,
                        textAlign: TextAlign.center,
                        style: textos.bodyMedium,
                      ),

                      const SizedBox(height: 14),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colores.error.withAlpha(18),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colores.error.withAlpha(90),
                          ),
                        ),
                        child: Text(
                          'Esta actualización es obligatoria. La app no podrá usarse hasta instalar la nueva versión.',
                          textAlign: TextAlign.center,
                          style: textos.bodyMedium?.copyWith(
                            color: colores.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        'Versión nueva: ${widget.datos.versionName}',
                        style: textos.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: abriendo ? null : abrirUpdate,
                          icon: abriendo
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.download),
                          label: Text(
                            abriendo ? 'Abriendo...' : 'Actualizar ahora',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}