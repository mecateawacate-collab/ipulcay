import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'codigo_pedido.dart';
import 'dialogos_pedido.dart';
import 'pantalla_seleccionar_productos.dart';
import 'pantalla_ubicacion_pedido.dart';
import 'servicio_pedido_local.dart';
import 'servicio_pedidos.dart';

class PantallaCrearPedido extends StatefulWidget {
  const PantallaCrearPedido({super.key});

  @override
  State<PantallaCrearPedido> createState() => _PantallaCrearPedidoState();
}

class _PantallaCrearPedidoState extends State<PantallaCrearPedido> {
  final ServicioPedidos servicioPedidos = ServicioPedidos();
  final ServicioPedidoLocal servicioPedidoLocal = ServicioPedidoLocal();
  final ImagePicker imagePicker = ImagePicker();

  final TextEditingController busquedaClienteController =
      TextEditingController();
  final TextEditingController nombreClienteController = TextEditingController();
  final TextEditingController documentoClienteController =
      TextEditingController();
  final TextEditingController telefonoClienteController =
      TextEditingController();
  final TextEditingController tipoNegocioController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController observacionController = TextEditingController();
  final TextEditingController metodoOtroController = TextEditingController();

  List<ClientePedido> clientes = [];
  List<ProductoPedido> productos = [];
  List<ItemPedido> items = [];

  ClientePedido? clienteSeleccionado;

  bool cargando = true;
  bool guardando = false;

  DateTime fechaEmision = DateTime.now();

  String metodoPago = 'Yape / PLIN';

  double? latitud;
  double? longitud;
  File? fotoReferencia;

  final List<String> metodosPago = const [
    'Yape / PLIN',
    'Transferencia',
    'Efectivo',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  @override
  void dispose() {
    busquedaClienteController.dispose();
    nombreClienteController.dispose();
    documentoClienteController.dispose();
    telefonoClienteController.dispose();
    tipoNegocioController.dispose();
    direccionController.dispose();
    observacionController.dispose();
    metodoOtroController.dispose();
    super.dispose();
  }

  Future<void> cargarDatos() async {
    try {
      final resultados = await Future.wait([
        servicioPedidos.obtenerClientes(),
        servicioPedidos.obtenerProductos(),
      ]).timeout(const Duration(seconds: 8));

      if (!mounted) return;

      setState(() {
        clientes = resultados[0] as List<ClientePedido>;
        productos = resultados[1] as List<ProductoPedido>;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudieron cargar datos de Firebase. Puedes llenar el pedido manualmente.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  double get totalPedido {
    return items.fold(0, (total, item) => total + item.precioTotal);
  }

  List<ClientePedido> get clientesFiltrados {
    final texto = busquedaClienteController.text.toLowerCase().trim();

    if (texto.isEmpty) return [];

    return clientes.where((cliente) {
      return cliente.nombre.toLowerCase().contains(texto) ||
          cliente.documento.toLowerCase().contains(texto);
    }).take(6).toList();
  }

  void mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void seleccionarCliente(ClientePedido cliente) {
    setState(() {
      clienteSeleccionado = cliente;

      busquedaClienteController.text = cliente.nombre;
      nombreClienteController.text = cliente.nombre;
      documentoClienteController.text = cliente.documento;
      telefonoClienteController.text = cliente.telefono;
      tipoNegocioController.text = cliente.tipoNegocio;
      direccionController.text = cliente.direccionTexto;
    });
  }

  void limpiarClienteSeleccionado() {
    setState(() {
      clienteSeleccionado = null;
      busquedaClienteController.clear();
      nombreClienteController.clear();
      documentoClienteController.clear();
      telefonoClienteController.clear();
      tipoNegocioController.clear();
      direccionController.clear();
    });
  }

  Future<void> elegirFecha() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: fechaEmision,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (fecha == null) return;

    setState(() {
      fechaEmision = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        DateTime.now().hour,
        DateTime.now().minute,
      );
    });
  }

  Future<void> abrirProductos() async {
    final resultado = await Navigator.push<List<ItemPedido>>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PantallaSeleccionarProductos(
            productos: productos,
            itemsIniciales: items,
          );
        },
      ),
    );

    if (resultado == null) return;

    setState(() {
      items = resultado;
    });
  }

  void quitarItemPedido(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void editarCantidadItem(int index) {
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
              labelText: 'Cantidad',
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
                  mostrarMensaje('La cantidad debe ser mayor a 0.');
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

  Future<void> abrirMapa() async {
    final resultado = await Navigator.push<ResultadoUbicacionPedido>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PantallaUbicacionPedido(
            latitudInicial: latitud,
            longitudInicial: longitud,
          );
        },
      ),
    );

    if (resultado == null) return;

    setState(() {
      latitud = resultado.latitud;
      longitud = resultado.longitud;
    });
  }

  Future<void> tomarFoto() async {
    final XFile? foto = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1200,
    );

    if (foto == null) return;

    setState(() {
      fotoReferencia = File(foto.path);
    });
  }

  Future<void> elegirFotoGaleria() async {
    final XFile? foto = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1200,
    );

    if (foto == null) return;

    setState(() {
      fotoReferencia = File(foto.path);
    });
  }

  ClientePedido clienteDesdeFormulario() {
    return ClientePedido(
      id: clienteSeleccionado?.id ?? '',
      nombre: nombreClienteController.text.trim(),
      documento: documentoClienteController.text.trim(),
      telefono: telefonoClienteController.text.trim(),
      tipoNegocio: tipoNegocioController.text.trim().isEmpty
          ? 'No especificado'
          : tipoNegocioController.text.trim(),
      direccionTexto: direccionController.text.trim(),
    );
  }

  Future<ClientePedido> prepararCliente() async {
    final cliente = clienteSeleccionado;

    if (cliente != null) {
      return ClientePedido(
        id: cliente.id,
        nombre: cliente.nombre,
        documento: cliente.documento,
        telefono: cliente.telefono,
        tipoNegocio: cliente.tipoNegocio,
        direccionTexto: direccionController.text.trim(),
      );
    }

    return servicioPedidos.crearClienteAutomatico(
      nombre: nombreClienteController.text,
      documento: documentoClienteController.text,
      telefono: telefonoClienteController.text,
      tipoNegocio: tipoNegocioController.text,
      direccionTexto: direccionController.text,
    );
  }

  bool validarFormulario() {
    if (nombreClienteController.text.trim().isEmpty) {
      mostrarMensaje('Ingresa el nombre del cliente.');
      return false;
    }

    if (documentoClienteController.text.trim().isEmpty) {
      mostrarMensaje('Ingresa el documento del cliente.');
      return false;
    }

    if (direccionController.text.trim().isEmpty) {
      mostrarMensaje('Ingresa la dirección del pedido.');
      return false;
    }

    if (items.isEmpty) {
      mostrarMensaje('Agrega al menos un producto.');
      return false;
    }

    if (latitud == null || longitud == null) {
      mostrarMensaje('Selecciona la ubicación en el mapa.');
      return false;
    }

    if (metodoPago == 'Otro' && metodoOtroController.text.trim().isEmpty) {
      mostrarMensaje('Especifica el método de pago.');
      return false;
    }

    return true;
  }

  Future<void> guardarPedido() async {
    if (!validarFormulario()) return;

    final User? usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      mostrarMensaje('No hay usuario autenticado.');
      return;
    }

    final String codigoPedido = generarCodigoPedido(
      vendedorId: usuario.uid,
    );

    setState(() {
      guardando = true;
    });

    try {
      final ClientePedido cliente = await obtenerClienteParaGuardar();
      final String fotoUrl = await intentarSubirFoto();

      final String codigoGuardado = await servicioPedidos
          .crearPedido(
            cliente: cliente,
            direccionTexto: direccionController.text,
            fechaEmision: fechaEmision,
            productos: items,
            total: totalPedido,
            metodoPago: metodoPago,
            metodoPagoOtro: metodoOtroController.text,
            observacionVendedor: observacionController.text,
            latitud: latitud,
            longitud: longitud,
            fotoReferenciaUrl: fotoUrl,
            codigoPedidoManual: codigoPedido,
          )
          .timeout(const Duration(seconds: 8));

      if (!mounted) return;

      setState(() {
        guardando = false;
      });

      await DialogosPedido.mostrarPedidoCreado(
        context: context,
        codigoPedido: codigoGuardado,
      );
    } catch (_) {
      await guardarPedidoComoLocal(codigoPedido);
    }
  }

  Future<ClientePedido> obtenerClienteParaGuardar() async {
    try {
      return await prepararCliente().timeout(const Duration(seconds: 6));
    } catch (_) {
      return clienteDesdeFormulario();
    }
  }

  Future<String> intentarSubirFoto() async {
    if (fotoReferencia == null) return '';

    try {
      return await servicioPedidos
          .subirFotoReferencia(fotoReferencia!)
          .timeout(const Duration(seconds: 6));
    } catch (_) {
      return '';
    }
  }

  Future<void> guardarPedidoComoLocal(String codigoPedido) async {
    try {
      await servicioPedidoLocal.guardarPedidoLocal(
        codigoPedido: codigoPedido,
        cliente: clienteDesdeFormulario(),
        fechaEmision: fechaEmision,
        productos: items,
        total: totalPedido,
        metodoPago: metodoPago,
        metodoPagoOtro: metodoOtroController.text,
        observacionVendedor: observacionController.text,
        latitud: latitud,
        longitud: longitud,
        direccionTexto: direccionController.text,
        fotoReferenciaLocalPath: fotoReferencia?.path ?? '',
      );

      if (!mounted) return;

      setState(() {
        guardando = false;
      });

      await DialogosPedido.mostrarPedidoLocalCreado(
        context: context,
        codigoPedido: codigoPedido,
      );
    } catch (errorLocal) {
      if (!mounted) return;

      setState(() {
        guardando = false;
      });

      mostrarMensaje(
        errorLocal.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Widget bloqueCliente() {
    final filtrados = clientesFiltrados;

    return Column(
      children: [
        TextField(
          controller: busquedaClienteController,
          decoration: InputDecoration(
            labelText: 'Buscar cliente por nombre o documento',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: clienteSeleccionado == null
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: limpiarClienteSeleccionado,
                  ),
          ),
          onChanged: (_) {
            setState(() {
              clienteSeleccionado = null;
            });
          },
        ),

        if (filtrados.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...filtrados.map((cliente) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(cliente.nombre),
                subtitle: Text(
                  'Doc: ${cliente.documento} · ${cliente.tipoNegocio}',
                ),
                onTap: () => seleccionarCliente(cliente),
              ),
            );
          }),
        ],

        const SizedBox(height: 14),

        TextField(
          controller: nombreClienteController,
          textCapitalization: TextCapitalization.words,
          readOnly: clienteSeleccionado != null,
          decoration: const InputDecoration(
            labelText: 'Nombre del cliente',
            prefixIcon: Icon(Icons.person),
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: documentoClienteController,
          keyboardType: TextInputType.number,
          readOnly: clienteSeleccionado != null,
          maxLength: 11,
          decoration: const InputDecoration(
            labelText: 'Documento / DNI / RUC',
            prefixIcon: Icon(Icons.badge),
            counterText: '',
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: telefonoClienteController,
          keyboardType: TextInputType.phone,
          readOnly: clienteSeleccionado != null,
          maxLength: 9,
          decoration: const InputDecoration(
            labelText: 'Teléfono',
            prefixIcon: Icon(Icons.phone),
            counterText: '',
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: tipoNegocioController,
          textCapitalization: TextCapitalization.words,
          readOnly: clienteSeleccionado != null,
          decoration: const InputDecoration(
            labelText: 'Tipo de negocio',
            prefixIcon: Icon(Icons.store),
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: direccionController,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Dirección escrita del pedido',
            prefixIcon: Icon(Icons.location_on),
            helperText: 'Este dato puede cambiar aunque el cliente ya exista.',
          ),
        ),
      ],
    );
  }

  Widget bloqueUbicacionFoto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: abrirMapa,
          icon: const Icon(Icons.map),
          label: const Text('Seleccionar punto en el mapa'),
        ),

        if (latitud != null && longitud != null) ...[
          const SizedBox(height: 8),
          Text(
            'Ubicación seleccionada: ${latitud!.toStringAsFixed(6)}, '
            '${longitud!.toStringAsFixed(6)}',
          ),
        ],

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: tomarFoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Tomar foto'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: elegirFotoGaleria,
                icon: const Icon(Icons.photo),
                label: const Text('Galería'),
              ),
            ),
          ],
        ),

        if (fotoReferencia != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              fotoReferencia!,
              height: 170,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }

  Widget bloqueProductos(BuildContext context) {
    final tema = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: abrirProductos,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Agregar producto'),
          ),
        ),

        if (items.isEmpty) ...[
          const SizedBox(height: 10),
          const Text('Todavía no agregaste productos.'),
        ],

        if (items.isNotEmpty) ...[
          const SizedBox(height: 12),

          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return Card(
              child: ListTile(
                title: Text(
                  item.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${item.cantidad} x S/ ${item.precioUnitario.toStringAsFixed(2)}',
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
                      tooltip: 'Editar cantidad',
                      onPressed: () => editarCantidadItem(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Quitar producto',
                      onPressed: () => quitarItemPedido(index),
                    ),
                  ],
                ),
              ),
            );
          }),

          const Divider(),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Total: S/ ${totalPedido.toStringAsFixed(2)}',
              style: tema.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear pedido'),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _TarjetaSeccion(
                  titulo: 'Datos de empresa',
                  icono: Icons.business,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('INDUSTRIAS PULCAY S.A.C'),
                      Text('RUC: 20123456789'),
                      Text('JR. Ayacucho'),
                      Text('Central Telefónica: 987 123 654'),
                      Text('Email: ipulcay.ventas@gmail.com'),
                    ],
                  ),
                ),

                _TarjetaSeccion(
                  titulo: 'Cliente',
                  icono: Icons.person,
                  child: bloqueCliente(),
                ),

                _TarjetaSeccion(
                  titulo: 'Ubicación y foto referencial',
                  icono: Icons.place,
                  child: bloqueUbicacionFoto(),
                ),

                _TarjetaSeccion(
                  titulo: 'Fecha de emisión',
                  icono: Icons.calendar_month,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${fechaEmision.day}/${fechaEmision.month}/${fechaEmision.year}',
                          style: tema.textTheme.titleMedium,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: elegirFecha,
                        icon: const Icon(Icons.edit_calendar),
                        label: const Text('Cambiar'),
                      ),
                    ],
                  ),
                ),

                _TarjetaSeccion(
                  titulo: 'Productos',
                  icono: Icons.inventory_2,
                  child: bloqueProductos(context),
                ),

                _TarjetaSeccion(
                  titulo: 'Pago',
                  icono: Icons.payments,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: metodoPago,
                        decoration: const InputDecoration(
                          labelText: 'Pagará con',
                          prefixIcon: Icon(Icons.payment),
                        ),
                        items: metodosPago.map((metodo) {
                          return DropdownMenuItem(
                            value: metodo,
                            child: Text(metodo),
                          );
                        }).toList(),
                        onChanged: (valor) {
                          setState(() {
                            metodoPago = valor ?? 'Yape / PLIN';
                          });
                        },
                      ),

                      if (metodoPago == 'Otro') ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: metodoOtroController,
                          decoration: const InputDecoration(
                            labelText: 'Especificar método de pago',
                            prefixIcon: Icon(Icons.edit),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                _TarjetaSeccion(
                  titulo: 'Observación del vendedor',
                  icono: Icons.notes,
                  child: TextField(
                    controller: observacionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText:
                          'Ejemplo: cliente prefiere entrega temprano, pide otro producto, tiene dudas, etc.',
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: guardando ? null : guardarPedido,
                    icon: guardando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(guardando ? 'Guardando...' : 'Guardar pedido'),
                  ),
                ),
              ],
            ),
    );
  }
}

class _TarjetaSeccion extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Widget child;

  const _TarjetaSeccion({
    required this.titulo,
    required this.icono,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono),
                const SizedBox(width: 10),
                Text(
                  titulo,
                  style: tema.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}