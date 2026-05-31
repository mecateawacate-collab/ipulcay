import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'categorias_producto.dart';
import 'modelo_producto.dart';
import 'servicio_productos.dart';

class PantallaCrearProducto extends StatefulWidget {
  final ModeloProducto? producto;

  const PantallaCrearProducto({
    super.key,
    this.producto,
  });

  @override
  State<PantallaCrearProducto> createState() => _PantallaCrearProductoEstado();
}

class _PantallaCrearProductoEstado extends State<PantallaCrearProducto> {
  final TextEditingController nombreControlador = TextEditingController();
  final TextEditingController precioControlador = TextEditingController();

  final ServicioProductos servicioProductos = ServicioProductos();
  final ImagePicker selectorImagen = ImagePicker();

  File? imagenSeleccionada;

  String categoriaSeleccionada = 'Cervezas';

  bool cargando = false;
  String mensajeError = '';

  bool get esEdicion => widget.producto != null;

  @override
  void initState() {
    super.initState();

    final producto = widget.producto;

    if (producto != null) {
      nombreControlador.text = producto.nombre;
      precioControlador.text = producto.precio.toStringAsFixed(2);

      if (categoriasProducto.contains(producto.categoria)) {
        categoriaSeleccionada = producto.categoria;
      } else {
        categoriaSeleccionada = 'Otros';
      }
    }
  }

  Future<void> seleccionarImagen() async {
    final XFile? imagen = await selectorImagen.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (imagen == null) return;

    setState(() {
      imagenSeleccionada = File(imagen.path);
    });
  }

  Future<void> guardarProducto() async {
    final String nombre = nombreControlador.text.trim();

    final String precioTexto = precioControlador.text
        .trim()
        .replaceAll(',', '.');

    final double? precio = double.tryParse(precioTexto);

    if (nombre.isEmpty) {
      setState(() {
        mensajeError = 'El nombre del producto es obligatorio';
      });
      return;
    }

    if (precio == null || precio <= 0) {
      setState(() {
        mensajeError = 'El precio debe ser mayor a 0';
      });
      return;
    }

    setState(() {
      cargando = true;
      mensajeError = '';
    });

    try {
      if (esEdicion) {
        final producto = widget.producto!;

        await servicioProductos.editarProducto(
          id: producto.id,
          nombre: nombre,
          categoria: categoriaSeleccionada,
          precio: precio,
          nuevaImagen: imagenSeleccionada,
          imagenPathActual: producto.imagenPath,
        );
      } else {
        await servicioProductos.crearProducto(
          nombre: nombre,
          categoria: categoriaSeleccionada,
          precio: precio,
          imagen: imagenSeleccionada,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            esEdicion
                ? 'Producto actualizado correctamente'
                : 'Producto guardado correctamente',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        mensajeError = esEdicion
            ? 'No se pudo actualizar el producto'
            : 'No se pudo guardar el producto';
      });
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nombreControlador.dispose();
    precioControlador.dispose();
    super.dispose();
  }

  Widget construirVistaImagen() {
    final producto = widget.producto;

    if (imagenSeleccionada != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          imagenSeleccionada!,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    if (producto != null && producto.imagenUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          producto.imagenUrl,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 48),
          SizedBox(height: 8),
          Text('Sin imagen'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String titulo = esEdicion ? 'Editar producto' : 'Crear producto';

    final String textoBoton = esEdicion
        ? 'Actualizar producto'
        : 'Guardar producto';

    final List<String> categoriasFormulario = categoriasProducto
        .where((categoria) => categoria != categoriaTodo)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Text(
                  esEdicion ? 'Datos del producto' : 'Nuevo producto',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                construirVistaImagen(),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: cargando ? null : seleccionarImagen,
                    icon: const Icon(Icons.photo_library),
                    label: Text(
                      esEdicion ? 'Cambiar imagen' : 'Seleccionar imagen',
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: nombreControlador,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del producto',
                    prefixIcon: Icon(Icons.inventory),
                  ),
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: categoriaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: categoriasFormulario.map((categoria) {
                    return DropdownMenuItem<String>(
                      value: categoria,
                      child: Text(categoria),
                    );
                  }).toList(),
                  onChanged: cargando
                      ? null
                      : (valor) {
                          if (valor == null) return;

                          setState(() {
                            categoriaSeleccionada = valor;
                          });
                        },
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: precioControlador,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),

                const SizedBox(height: 12),

                if (mensajeError.isNotEmpty)
                  Text(
                    mensajeError,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: cargando ? null : guardarProducto,
                    icon: const Icon(Icons.save),
                    label: cargando
                        ? const Text('Guardando...')
                        : Text(textoBoton),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}