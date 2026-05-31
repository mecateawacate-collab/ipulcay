import 'package:flutter/material.dart';

import '../../main.dart';
import '../login/servicio_usuario.dart';

class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesEstado();
}

class _PantallaAjustesEstado extends State<PantallaAjustes> {
  final ServicioUsuario servicioUsuario = ServicioUsuario();
  final TextEditingController controladorNombre = TextEditingController();

  bool guardandoNombre = false;
  bool temaCargado = false;
  String temaSeleccionado = 'pastel';

  final List<String> temasValidos = const [
    'pastel',
    'verde',
    'azul',
    'morado',
    'naranja',
    'oscuro',
    'oscuroAzul',
  ];

  @override
  void dispose() {
    controladorNombre.dispose();
    super.dispose();
  }

  Future<void> guardarNombre() async {
    final String nombre = controladorNombre.text.trim();

    if (nombre.isEmpty) {
      mostrarMensaje('Escribe un nombre válido');
      return;
    }

    setState(() {
      guardandoNombre = true;
    });

    try {
      await servicioUsuario.actualizarNombre(nombre);

      if (!mounted) return;

      mostrarMensaje('Nombre actualizado correctamente');
    } catch (e) {
      mostrarMensaje('No se pudo actualizar el nombre');
    }

    if (!mounted) return;

    setState(() {
      guardandoNombre = false;
    });
  }

  Future<void> cambiarTema(String tema) async {
    setState(() {
      temaSeleccionado = tema;
    });

    controlTema.cambiarTema(tema);

    try {
      await servicioUsuario.actualizarTema(tema);
    } catch (e) {
      mostrarMensaje('El tema cambió, pero no se pudo guardar');
    }
  }

  void cargarTemaInicial(String temaGuardado) {
    if (temaCargado) return;

    String temaSeguro = temaGuardado;

    if (!temasValidos.contains(temaSeguro)) {
      temaSeguro = 'pastel';
    }

    temaSeleccionado = temaSeguro;
    temaCargado = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controlTema.cambiarTema(temaSeguro);
    });
  }

  void mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String nombreTema(String tema) {
    if (tema == 'verde') return 'Verde';
    if (tema == 'azul') return 'Azul';
    if (tema == 'morado') return 'Morado';
    if (tema == 'naranja') return 'Naranja';
    if (tema == 'oscuro') return 'Oscuro verde';
    if (tema == 'oscuroAzul') return 'Oscuro azul';

    return 'Pastel';
  }

Widget opcionTema({
  required String id,
  required String titulo,
  required String detalle,
  required IconData icono,
}) {
  final ThemeData tema = Theme.of(context);
  final ColorScheme colores = tema.colorScheme;
  final TextTheme textos = tema.textTheme;

  final bool seleccionado = temaSeleccionado == id;

  return InkWell(
    onTap: () {
      cambiarTema(id);
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: seleccionado
              ? colores.primary.withAlpha(25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: seleccionado
                ? colores.primary.withAlpha(90)
                : colores.outline.withAlpha(35),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icono,
              color: seleccionado ? colores.primary : colores.onSurface,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: textos.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    detalle,
                    style: textos.bodySmall,
                  ),
                ],
              ),
            ),

            Icon(
              seleccionado
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: seleccionado
                  ? colores.primary
                  : colores.onSurface.withAlpha(120),
            ),
          ],
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final TextTheme textos = tema.textTheme;
    final ColorScheme colores = tema.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: servicioUsuario.escucharUsuarioActual(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final datosUsuario = snapshot.data;

          if (datosUsuario == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No se encontró el perfil del usuario.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final String nombreActual = datosUsuario['nombre'] ?? '';
          final String correo = datosUsuario['correo'] ?? 'Sin correo';
          final String rol = datosUsuario['rol'] ?? 'Sin rol';
          final String temaGuardado = datosUsuario['tema'] ?? 'pastel';

          if (controladorNombre.text.isEmpty) {
            controladorNombre.text = nombreActual;
          }

          cargarTemaInicial(temaGuardado);

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: colores.primary.withAlpha(35),
                          child: Icon(
                            Icons.person,
                            color: colores.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombreActual.isEmpty ? 'Usuario' : nombreActual,
                                style: textos.titleMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                correo,
                                style: textos.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rol: $rol',
                                style: textos.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Datos personales',
                  style: textos.titleLarge,
                ),

                const SizedBox(height: 10),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        TextField(
                          controller: controladorNombre,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            hintText: 'Ejemplo: Mecate Awacate',
                            prefixIcon: Icon(Icons.badge),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: guardandoNombre ? null : guardarNombre,
                            icon: guardandoNombre
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: Text(
                              guardandoNombre
                                  ? 'Guardando...'
                                  : 'Guardar nombre',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Tema de la aplicación',
                  style: textos.titleLarge,
                ),

                const SizedBox(height: 10),

                Card(
                  child: Column(
                    children: [
                      opcionTema(
                        id: 'pastel',
                        titulo: 'Pastel',
                        detalle: 'Suave y amigable',
                        icono: Icons.spa,
                      ),
                      opcionTema(
                        id: 'verde',
                        titulo: 'Verde',
                        detalle: 'Clásico de la app',
                        icono: Icons.eco,
                      ),
                      opcionTema(
                        id: 'azul',
                        titulo: 'Azul',
                        detalle: 'Limpio y profesional',
                        icono: Icons.water_drop,
                      ),
                      opcionTema(
                        id: 'morado',
                        titulo: 'Morado',
                        detalle: 'Moderno y elegante',
                        icono: Icons.auto_awesome,
                      ),
                      opcionTema(
                        id: 'naranja',
                        titulo: 'Naranja',
                        detalle: 'Cálido y comercial',
                        icono: Icons.local_fire_department,
                      ),
                      opcionTema(
                        id: 'oscuro',
                        titulo: 'Oscuro verde',
                        detalle: 'Modo noche clásico',
                        icono: Icons.dark_mode,
                      ),
                      opcionTema(
                        id: 'oscuroAzul',
                        titulo: 'Oscuro azul',
                        detalle: 'Modo noche tecnológico',
                        icono: Icons.nightlight,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colores.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: colores.primary.withAlpha(45),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: colores.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tema actual: ${nombreTema(temaSeleccionado)}',
                          style: textos.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}