import 'package:flutter/material.dart';

import 'modelo_cliente.dart';
import 'servicio_clientes.dart';

class PantallaClientes extends StatefulWidget {
  const PantallaClientes({super.key});

  @override
  State<PantallaClientes> createState() => _PantallaClientesState();
}

class _PantallaClientesState extends State<PantallaClientes> {
  final ServicioClientes servicioClientes = ServicioClientes();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController documentoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController tipoNegocioController = TextEditingController();

  bool guardando = false;

  @override
  void dispose() {
    nombreController.dispose();
    documentoController.dispose();
    telefonoController.dispose();
    direccionController.dispose();
    tipoNegocioController.dispose();
    super.dispose();
  }

  void limpiarFormulario() {
    nombreController.clear();
    documentoController.clear();
    telefonoController.clear();
    direccionController.clear();
    tipoNegocioController.clear();
  }

  void llenarFormulario(ModeloCliente cliente) {
    nombreController.text = cliente.nombre;
    documentoController.text = cliente.documento;
    telefonoController.text = cliente.telefono;
    direccionController.text = cliente.direccionTexto;
    tipoNegocioController.text = cliente.tipoNegocio;
  }

  Future<void> guardarCliente({ModeloCliente? cliente}) async {
    setState(() {
      guardando = true;
    });

    try {
      if (cliente == null) {
        await servicioClientes.crearCliente(
          nombre: nombreController.text,
          documento: documentoController.text,
          telefono: telefonoController.text,
          direccionTexto: direccionController.text,
          tipoNegocio: tipoNegocioController.text,
        );
      } else {
        await servicioClientes.actualizarCliente(
          clienteId: cliente.id,
          nombre: nombreController.text,
          documento: documentoController.text,
          telefono: telefonoController.text,
          direccionTexto: direccionController.text,
          tipoNegocio: tipoNegocioController.text,
        );
      }

      if (!mounted) return;

      limpiarFormulario();
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cliente == null
                ? 'Cliente creado correctamente.'
                : 'Cliente actualizado correctamente.',
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
    }

    if (!mounted) return;

    setState(() {
      guardando = false;
    });
  }

  void abrirFormularioCliente({ModeloCliente? cliente}) {
    if (cliente == null) {
      limpiarFormulario();
    } else {
      llenarFormulario(cliente);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final ThemeData tema = Theme.of(context);
        final bool editando = cliente != null;

        return Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 18,
            bottom: MediaQuery.of(context).viewInsets.bottom + 18,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  editando ? 'Editar cliente' : 'Nuevo cliente',
                  style: tema.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                TextField(
                  controller: nombreController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del cliente',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: documentoController,
                  keyboardType: TextInputType.number,
                  maxLength: 11,
                  decoration: const InputDecoration(
                    labelText: 'Documento / DNI / RUC',
                    prefixIcon: Icon(Icons.badge),
                    counterText: '',
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: telefonoController,
                  keyboardType: TextInputType.phone,
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
                    labelText: 'Dirección escrita',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: guardando
                        ? null
                        : () => guardarCliente(cliente: cliente),
                    icon: guardando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      guardando
                          ? 'Guardando...'
                          : editando
                              ? 'Actualizar cliente'
                              : 'Guardar cliente',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void abrirDetalleCliente(ModeloCliente cliente) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaDetalleCliente(cliente: cliente),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final ColorScheme colores = tema.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => abrirFormularioCliente(),
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo'),
      ),
      body: StreamBuilder<List<ModeloCliente>>(
        stream: servicioClientes.obtenerClientes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudieron cargar los clientes.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final clientes = snapshot.data ?? [];

          if (clientes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.groups_rounded,
                      size: 72,
                      color: colores.primary,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Aún no hay clientes',
                      style: tema.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crea tus primeros clientes de prueba para luego generar pedidos.',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: clientes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final cliente = clientes[index];

              return Card(
                child: ListTile(
                  onTap: () => abrirDetalleCliente(cliente),
                  leading: CircleAvatar(
                    child: Text(
                      cliente.nombre.isNotEmpty
                          ? cliente.nombre[0].toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(
                    cliente.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Doc: ${cliente.documento}\n'
                    'Tel: ${cliente.telefono.isEmpty ? 'Sin teléfono' : cliente.telefono}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Editar cliente',
                    onPressed: () => abrirFormularioCliente(cliente: cliente),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PantallaDetalleCliente extends StatelessWidget {
  final ModeloCliente cliente;

  const PantallaDetalleCliente({
    super.key,
    required this.cliente,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del cliente'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cliente.nombre,
                    style: tema.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _DatoCliente(
                    icono: Icons.badge,
                    titulo: 'Documento',
                    valor: cliente.documento,
                  ),

                  _DatoCliente(
                    icono: Icons.store,
                    titulo: 'Tipo de negocio',
                    valor: cliente.tipoNegocio.isEmpty
                        ? 'Sin tipo de negocio'
                        : cliente.tipoNegocio,
                  ),

                  _DatoCliente(
                    icono: Icons.phone,
                    titulo: 'Teléfono',
                    valor: cliente.telefono.isEmpty
                        ? 'Sin teléfono'
                        : cliente.telefono,
                  ),

                  _DatoCliente(
                    icono: Icons.location_on,
                    titulo: 'Dirección',
                    valor: cliente.direccionTexto.isEmpty
                        ? 'Sin dirección'
                        : cliente.direccionTexto,
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: tema.colorScheme.primary.withAlpha(20),
                    ),
                    child: const Text(
                      'Información detallada en desarrollo.\nAquí luego podremos mostrar pedidos, historial, ubicación frecuente y estado del cliente.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DatoCliente extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _DatoCliente({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: tema.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(valor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}