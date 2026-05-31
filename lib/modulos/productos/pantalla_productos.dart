import 'package:flutter/material.dart';

import 'categorias_producto.dart';
import 'modelo_producto.dart';
import 'servicio_productos.dart';
import 'pantalla_crear_producto.dart';

class PantallaProductos extends StatefulWidget {
  const PantallaProductos({super.key});

  @override
  State<PantallaProductos> createState() => _PantallaProductosEstado();
}

class _PantallaProductosEstado extends State<PantallaProductos> {
  final ServicioProductos servicioProductos = ServicioProductos();
  final TextEditingController busquedaControlador = TextEditingController();
  final FocusNode focoBusqueda = FocusNode();

  late Stream<List<ModeloProducto>> productosStream;

  String categoriaSeleccionada = categoriaTodo;
  String textoBusqueda = '';
  bool mostrarActivos = true;

  @override
  void initState() {
    super.initState();

    productosStream = servicioProductos.obtenerProductos(
      mostrarActivos: mostrarActivos,
    );
  }

  @override
  void dispose() {
    busquedaControlador.dispose();
    focoBusqueda.dispose();
    super.dispose();
  }

  void actualizarStreamProductos() {
    productosStream = servicioProductos.obtenerProductos(
      mostrarActivos: mostrarActivos,
    );
  }

  void abrirFormularioCrear() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PantallaCrearProducto(),
      ),
    );
  }

  void abrirFormularioEditar(ModeloProducto producto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaCrearProducto(
          producto: producto,
        ),
      ),
    );
  }

  Future<void> confirmarDesactivar(ModeloProducto producto) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Desactivar producto'),
          content: Text(
            '¿Seguro que deseas ocultar "${producto.nombre}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Desactivar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await servicioProductos.desactivarProducto(producto.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto desactivado correctamente'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo desactivar el producto'),
        ),
      );
    }
  }

  Future<void> confirmarActivar(ModeloProducto producto) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reactivar producto'),
          content: Text(
            '¿Deseas volver a mostrar "${producto.nombre}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reactivar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await servicioProductos.activarProducto(producto.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto reactivado correctamente'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo reactivar el producto'),
        ),
      );
    }
  }

  List<ModeloProducto> filtrarProductos(List<ModeloProducto> productos) {
    final String busqueda = textoBusqueda.trim().toLowerCase();

    return productos.where((producto) {
      final bool coincideCategoria =
          categoriaSeleccionada == categoriaTodo ||
          producto.categoria == categoriaSeleccionada;

      final bool coincideBusqueda =
          busqueda.isEmpty ||
          producto.nombre.toLowerCase().contains(busqueda) ||
          producto.categoria.toLowerCase().contains(busqueda) ||
          producto.precio.toStringAsFixed(2).contains(busqueda);

      return coincideCategoria && coincideBusqueda;
    }).toList();
  }

  Widget construirImagenProducto(ModeloProducto producto) {
    if (producto.imagenUrl.isEmpty) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.inventory_2),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        producto.imagenUrl,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.broken_image),
          );
        },
      ),
    );
  }

  Widget construirFiltros() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            TextField(
              controller: busquedaControlador,
              focusNode: focoBusqueda,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                labelText: 'Buscar producto',
                hintText: 'Ejemplo: Pilsen, Coca Cola, vino...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (valor) {
                setState(() {
                  textoBusqueda = valor;
                });
              },
            ),

            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              initialValue: categoriaSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Filtrar por categoría',
                prefixIcon: Icon(Icons.category),
              ),
              items: categoriasProducto.map((categoria) {
                return DropdownMenuItem<String>(
                  value: categoria,
                  child: Text(categoria),
                );
              }).toList(),
              onChanged: (valor) {
                if (valor == null) return;

                focoBusqueda.unfocus();

                setState(() {
                  categoriaSeleccionada = valor;
                });
              },
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  focoBusqueda.unfocus();

                  setState(() {
                    mostrarActivos = !mostrarActivos;
                    categoriaSeleccionada = categoriaTodo;
                    textoBusqueda = '';
                    busquedaControlador.clear();

                    actualizarStreamProductos();
                  });
                },
                icon: Icon(
                  mostrarActivos
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                label: Text(
                  mostrarActivos
                      ? 'Ver productos desactivados'
                      : 'Ver productos activos',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget construirProducto(ModeloProducto producto) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: construirImagenProducto(producto),
        title: Text(
          producto.nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${producto.categoria}\nS/ ${producto.precio.toStringAsFixed(2)}',
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (valor) {
            focoBusqueda.unfocus();

            if (valor == 'editar') {
              abrirFormularioEditar(producto);
            }

            if (valor == 'desactivar') {
              confirmarDesactivar(producto);
            }

            if (valor == 'activar') {
              confirmarActivar(producto);
            }
          },
          itemBuilder: (context) {
            if (mostrarActivos) {
              return const [
                PopupMenuItem(
                  value: 'editar',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'desactivar',
                  child: Row(
                    children: [
                      Icon(Icons.visibility_off),
                      SizedBox(width: 8),
                      Text('Desactivar'),
                    ],
                  ),
                ),
              ];
            }

            return const [
              PopupMenuItem(
                value: 'editar',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'activar',
                child: Row(
                  children: [
                    Icon(Icons.visibility),
                    SizedBox(width: 8),
                    Text('Reactivar'),
                  ],
                ),
              ),
            ];
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String titulo = mostrarActivos
        ? 'Productos activos'
        : 'Productos desactivados';

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
      ),
      floatingActionButton: mostrarActivos
          ? FloatingActionButton(
              onPressed: abrirFormularioCrear,
              child: const Icon(Icons.add),
            )
          : null,
      body: StreamBuilder<List<ModeloProducto>>(
        stream: productosStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error al cargar productos'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final productos = snapshot.data ?? [];
          final productosFiltrados = filtrarProductos(productos);

          return Column(
            children: [
              construirFiltros(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Resultados: ${productosFiltrados.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!mostrarActivos)
                      const Chip(
                        label: Text('Modo ocultos'),
                        avatar: Icon(Icons.visibility_off),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: productosFiltrados.isEmpty
                    ? Center(
                        child: Text(
                          mostrarActivos
                              ? 'No hay productos activos con esos filtros'
                              : 'No hay productos desactivados con esos filtros',
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: productosFiltrados.length,
                        itemBuilder: (context, index) {
                          final producto = productosFiltrados[index];

                          return construirProducto(producto);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}