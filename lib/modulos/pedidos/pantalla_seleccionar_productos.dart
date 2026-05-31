import 'package:flutter/material.dart';

import '../productos/categorias_producto.dart';
import 'servicio_pedidos.dart';

class PantallaSeleccionarProductos extends StatefulWidget {
  final List<ProductoPedido> productos;
  final List<ItemPedido> itemsIniciales;

  const PantallaSeleccionarProductos({
    super.key,
    required this.productos,
    required this.itemsIniciales,
  });

  @override
  State<PantallaSeleccionarProductos> createState() {
    return _PantallaSeleccionarProductosState();
  }
}

class _PantallaSeleccionarProductosState
    extends State<PantallaSeleccionarProductos> {
  final TextEditingController busquedaController = TextEditingController();

  late List<ItemPedido> items;

  String categoriaSeleccionada = categoriaTodo;
  String busqueda = '';

  @override
  void initState() {
    super.initState();
    items = List<ItemPedido>.from(widget.itemsIniciales);
  }

  @override
  void dispose() {
    busquedaController.dispose();
    super.dispose();
  }

  double get total {
    return items.fold(0, (suma, item) => suma + item.precioTotal);
  }

  List<ProductoPedido> get productosFiltrados {
    final texto = busqueda.toLowerCase().trim();

    return widget.productos.where((producto) {
      final coincideCategoria = categoriaSeleccionada == categoriaTodo ||
          producto.categoria == categoriaSeleccionada;

      final coincideBusqueda = texto.isEmpty ||
          producto.nombre.toLowerCase().contains(texto) ||
          producto.categoria.toLowerCase().contains(texto);

      return coincideCategoria && coincideBusqueda;
    }).toList();
  }

  List<ItemPedido> prepararItemsConProducto(
    ProductoPedido producto,
    int cantidad,
  ) {
    final List<ItemPedido> nuevosItems = List<ItemPedido>.from(items);

    final index = nuevosItems.indexWhere(
      (item) => item.productoId == producto.id,
    );

    if (index >= 0) {
      final actual = nuevosItems[index];
      final nuevaCantidad = actual.cantidad + cantidad;

      nuevosItems[index] = ItemPedido(
        productoId: producto.id,
        nombre: producto.nombre,
        categoria: producto.categoria,
        cantidad: nuevaCantidad,
        precioUnitario: producto.precio,
        precioTotal: producto.precio * nuevaCantidad,
        imagenUrl: producto.imagenUrl,
      );
    } else {
      nuevosItems.add(
        ItemPedido(
          productoId: producto.id,
          nombre: producto.nombre,
          categoria: producto.categoria,
          cantidad: cantidad,
          precioUnitario: producto.precio,
          precioTotal: producto.precio * cantidad,
          imagenUrl: producto.imagenUrl,
        ),
      );
    }

    return nuevosItems;
  }

  void abrirCantidad(ProductoPedido producto) {
    final TextEditingController cantidadController =
        TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(producto.nombre),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Precio: S/ ${producto.precio.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              TextField(
                controller: cantidadController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final cantidad =
                    int.tryParse(cantidadController.text.trim()) ?? 0;

                if (cantidad <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('La cantidad debe ser mayor a 0.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                final nuevosItems = prepararItemsConProducto(
                  producto,
                  cantidad,
                );

                Navigator.pop(dialogContext);

                Future.delayed(Duration.zero, () {
                  if (!mounted) return;
                  Navigator.pop(context, nuevosItems);
                });
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void devolverItemsActuales() {
    Navigator.pop(context, items);
  }

  void quitarProducto(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void cambiarCantidad(int index) {
    final item = items[index];

    final TextEditingController cantidadController = TextEditingController(
      text: item.cantidad.toString(),
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(item.nombre),
          content: TextField(
            controller: cantidadController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nueva cantidad',
              prefixIcon: Icon(Icons.numbers),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final cantidad =
                    int.tryParse(cantidadController.text.trim()) ?? 0;

                if (cantidad <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('La cantidad debe ser mayor a 0.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                setState(() {
                  items[index] = ItemPedido(
                    productoId: item.productoId,
                    nombre: item.nombre,
                    categoria: item.categoria,
                    cantidad: cantidad,
                    precioUnitario: item.precioUnitario,
                    precioTotal: item.precioUnitario * cantidad,
                    imagenUrl: item.imagenUrl,
                  );
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  Widget imagenProducto(ProductoPedido producto) {
    if (producto.imagenUrl.isEmpty) {
      return const CircleAvatar(
        child: Icon(Icons.inventory_2),
      );
    }

    return CircleAvatar(
      backgroundImage: NetworkImage(producto.imagenUrl),
      onBackgroundImageError: (_, _) {},
      child: const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar producto'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: categoriaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: categoriasProducto.map((categoria) {
                    return DropdownMenuItem(
                      value: categoria,
                      child: Text(categoria),
                    );
                  }).toList(),
                  onChanged: (valor) {
                    setState(() {
                      categoriaSeleccionada = valor ?? categoriaTodo;
                    });
                  },
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: busquedaController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar por nombre o categoría',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (valor) {
                    setState(() {
                      busqueda = valor;
                    });
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: productosFiltrados.isEmpty
                ? const Center(
                    child: Text('No se encontraron productos.'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: productosFiltrados.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final producto = productosFiltrados[index];

                      return Card(
                        child: ListTile(
                          leading: imagenProducto(producto),
                          title: Text(producto.nombre),
                          subtitle: Text(
                            '${producto.categoria} · '
                            'S/ ${producto.precio.toStringAsFixed(2)}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle),
                            onPressed: () => abrirCantidad(producto),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          if (items.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: tema.dividerColor,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ya agregados',
                    style: tema.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];

                        return ListTile(
                          dense: true,
                          title: Text(item.nombre),
                          subtitle: Text(
                            '${item.cantidad} x '
                            'S/ ${item.precioUnitario.toStringAsFixed(2)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'S/ ${item.precioTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => cambiarCantidad(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => quitarProducto(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Total: S/ ${total.toStringAsFixed(2)}',
                      style: tema.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: devolverItemsActuales,
                      icon: const Icon(Icons.check),
                      label: const Text('Usar productos agregados'),
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