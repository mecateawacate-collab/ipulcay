import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:ipulcay/modulos/ventas/pantalla_ventas.dart';
import '../pedidos/pantalla_crear_pedido.dart';
import '../productos/pantalla_productos.dart';
import '../clientes/pantalla_clientes.dart';
import '../ajustes/pantalla_ajustes.dart';
import '../login/servicio_usuario.dart';
import '../login/servicio_login.dart';
import '../update/banner_update.dart';
import '../login/login.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuEstado();
}

class _MenuEstado extends State<Menu> {
  final ServicioLogin servicioLogin = ServicioLogin();
  final ServicioUsuario servicioUsuario = ServicioUsuario();

  String? rol;

  Future<void> cerrarSesion() async {
    await servicioLogin.cerrarSesion();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
      (route) => false,
    );
  }

  void mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool puedeVer(String permiso) {
    if (rol == 'administrador') {
      return true;
    }

    if (rol == 'vendedor') {
      return [
        'pedidos',
        'ventas',
        'mapa',
        'catalogo',
        'configuracion',
        'salir',
      ].contains(permiso);
    }

    if (rol == 'supervisor') {
      return [
        'productos',
        'clientes',
        'gestion',
        'configuracion',
        'salir',
      ].contains(permiso);
    }

    return false;
  }

  List<Widget> obtenerTarjetas() {
    final List<Widget> tarjetas = [];

    if (puedeVer('pedidos')) {
      tarjetas.add(
        tarjetaMenu(
          icono: Icons.receipt_long,
          titulo: 'Pedidos',
          texto: 'Crear pedido',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PantallaCrearPedido(),
              ),
            );
          },
        ),
      );
    }

    if (puedeVer('ventas')) {
      tarjetas.add(
        tarjetaMenu(
          icono: Icons.point_of_sale,
          titulo: 'Mis ventas',
          texto: 'Ver mis ventas',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PantallaVentas(),
              ),
            );
          },
        ),
      );
    }

    if (puedeVer('mapa')) {
      tarjetas.add(
        tarjetaMenu(
          icono: Icons.map,
          titulo: 'Mapa',
          texto: 'Ver entregas',
          onTap: () {
            mostrarMensaje('Módulo de mapa pendiente');
          },
        ),
      );
    }

    if (puedeVer('productos')) {
      tarjetas.add(
        tarjetaMenu(
          icono: Icons.inventory_2,
          titulo: 'Productos',
          texto: 'Administrar stock',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PantallaProductos(),
              ),
            );
          },
        ),
      );
    }

    if (puedeVer('clientes')) {
      tarjetas.add(
        tarjetaMenu(
          icono: Icons.people,
          titulo: 'Clientes',
          texto: 'Lista de clientes',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PantallaClientes(),
              ),
            );
          },
        ),
      );
    }

    if (puedeVer('gestion')) {
      tarjetas.add(
        tarjetaMenu(
          icono: Icons.dashboard_customize,
          titulo: 'Gestión',
          texto: 'Control general',
          onTap: () {
            mostrarMensaje('Módulo de gestión pendiente');
          },
        ),
      );
    }

    if (puedeVer('catalogo')) {
      tarjetas.add(
        tarjetaMenu(
          icono: Icons.menu_book,
          titulo: 'Catálogo',
          texto: 'Ver productos',
          onTap: () {
            mostrarMensaje('Módulo de catálogo pendiente');
          },
        ),
      );
    }

    if (puedeVer('configuracion')) {
      tarjetas.add(
        tarjetaMenu(
          icono: Icons.settings,
          titulo: 'Configuración',
          texto: 'Ajustes de app',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PantallaAjustes(),
              ),
            );
          },
        ),
      );
    }

    if (puedeVer('salir')) {
      tarjetas.add(
        tarjetaMenu(
          icono: Icons.logout,
          titulo: 'Salir',
          texto: 'Cerrar sesión',
          esPeligro: true,
          onTap: cerrarSesion,
        ),
      );
    }

    return tarjetas;
  }

  String nombreRol() {
    if (rol == 'administrador') return 'Administrador';
    if (rol == 'vendedor') return 'Vendedor';
    if (rol == 'supervisor') return 'Supervisor';
    return 'Sin rol';
  }

  @override
  Widget build(BuildContext context) {
    final User? usuario = FirebaseAuth.instance.currentUser;

    return StreamBuilder<Map<String, dynamic>?>(
      stream: servicioUsuario.escucharUsuarioActual(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final Map<String, dynamic>? datosUsuario = snapshot.data;

        if (datosUsuario == null) {
          return _pantallaSinPerfil();
        }

        final bool activo = datosUsuario['activo'] == true;
        final String rolActual = datosUsuario['rol'] ?? '';
        final String nombre = datosUsuario['nombre'] ?? 'Usuario';

        if (!activo) {
          return _pantallaUsuarioBloqueado();
        }

        rol = rolActual;

        final ThemeData tema = Theme.of(context);
        final TextTheme textos = tema.textTheme;
        final ColorScheme colores = tema.colorScheme;

        final List<Widget> tarjetas = obtenerTarjetas();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Ipulcay'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                onPressed: cerrarSesion,
                icon: const Icon(Icons.logout),
                tooltip: 'Cerrar sesión',
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const BannerUpdate(),

                _cabeceraUsuario(
                  usuario: usuario,
                  nombre: nombre,
                  textos: textos,
                  colores: colores,
                ),

                const SizedBox(height: 16),

                _tarjetaRol(
                  textos: textos,
                  colores: colores,
                ),

                const SizedBox(height: 24),

                Text(
                  'Menú principal',
                  style: textos.titleLarge,
                ),

                const SizedBox(height: 6),

                Text(
                  'Elige una opción para continuar con la gestión del negocio.',
                  style: textos.bodyMedium,
                ),

                const SizedBox(height: 20),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool pantallaAncha = constraints.maxWidth > 700;
                    final int columnas = pantallaAncha ? 3 : 2;

                    return GridView.count(
                      crossAxisCount: columnas,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: tarjetas.length <= 4 ? 1.25 : 0.95,
                      children: tarjetas,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _pantallaSinPerfil() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ipulcay'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.person_off,
                size: 64,
              ),

              const SizedBox(height: 16),

              const Text(
                'No se encontró el perfil del usuario en Firestore.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: cerrarSesion,
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pantallaUsuarioBloqueado() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuenta desactivada'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.block,
                size: 70,
                color: Colors.red,
              ),

              const SizedBox(height: 16),

              const Text(
                'Tu cuenta fue desactivada. Contacta con el administrador.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: cerrarSesion,
                icon: const Icon(Icons.logout),
                label: const Text('Salir'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cabeceraUsuario({
    required User? usuario,
    required String nombre,
    required TextTheme textos,
    required ColorScheme colores,
  }) {
    return Card(
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
                    nombre,
                    style: textos.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    usuario?.email ?? 'Usuario sin correo',
                    style: textos.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaRol({
    required TextTheme textos,
    required ColorScheme colores,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colores.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colores.primary.withAlpha(45),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_user,
            color: colores.primary,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              'Acceso: ${nombreRol()}',
              style: textos.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget tarjetaMenu({
    required IconData icono,
    required String titulo,
    required String texto,
    required VoidCallback onTap,
    bool esPeligro = false,
  }) {
    final ThemeData tema = Theme.of(context);
    final TextTheme textos = tema.textTheme;
    final ColorScheme colores = tema.colorScheme;

    final Color colorBase = esPeligro ? colores.error : colores.primary;
    final Color colorFondo = colorBase.withAlpha(28);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: colorFondo,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icono,
                  size: 32,
                  color: colorBase,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                titulo,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textos.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                texto,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textos.bodyMedium?.copyWith(
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}