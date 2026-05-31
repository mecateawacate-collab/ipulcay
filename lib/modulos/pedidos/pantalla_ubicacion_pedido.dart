import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ResultadoUbicacionPedido {
  final double latitud;
  final double longitud;

  const ResultadoUbicacionPedido({
    required this.latitud,
    required this.longitud,
  });
}

class PantallaUbicacionPedido extends StatefulWidget {
  final double? latitudInicial;
  final double? longitudInicial;

  const PantallaUbicacionPedido({
    super.key,
    this.latitudInicial,
    this.longitudInicial,
  });

  @override
  State<PantallaUbicacionPedido> createState() {
    return _PantallaUbicacionPedidoState();
  }
}

class _PantallaUbicacionPedidoState extends State<PantallaUbicacionPedido> {
  GoogleMapController? controladorMapa;

  late LatLng punto;

  bool buscandoUbicacion = false;

  @override
  void initState() {
    super.initState();

    punto = LatLng(
      widget.latitudInicial ?? -13.1588,
      widget.longitudInicial ?? -74.2239,
    );
  }

  void seleccionarPunto(LatLng nuevoPunto) {
    setState(() {
      punto = nuevoPunto;
    });
  }

  Future<void> irAMiUbicacion() async {
    setState(() {
      buscandoUbicacion = true;
    });

    try {
      final servicioActivo = await Geolocator.isLocationServiceEnabled();

      if (!servicioActivo) {
        throw Exception('Activa la ubicación/GPS del dispositivo.');
      }

      LocationPermission permiso = await Geolocator.checkPermission();

      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.denied) {
        throw Exception('Permiso de ubicación denegado.');
      }

      if (permiso == LocationPermission.deniedForever) {
        throw Exception(
          'El permiso de ubicación fue bloqueado. Actívalo desde ajustes.',
        );
      }

      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final nuevoPunto = LatLng(
        posicion.latitude,
        posicion.longitude,
      );

      setState(() {
        punto = nuevoPunto;
      });

      await controladorMapa?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: nuevoPunto,
            zoom: 18,
          ),
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
      buscandoUbicacion = false;
    });
  }

  void guardarUbicacion() {
    Navigator.pop(
      context,
      ResultadoUbicacionPedido(
        latitud: punto.latitude,
        longitud: punto.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final marcador = Marker(
      markerId: const MarkerId('pedido'),
      position: punto,
      draggable: true,
      onDragEnd: seleccionarPunto,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación del pedido'),
        actions: [
          TextButton(
            onPressed: guardarUbicacion,
            child: const Text('Listo'),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: punto,
              zoom: 16,
            ),
            markers: {marcador},
            onMapCreated: (controller) {
              controladorMapa = controller;
            },
            onTap: seleccionarPunto,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
          ),

          Positioned(
            right: 14,
            top: 14,
            child: FloatingActionButton.small(
              heroTag: 'btnMiUbicacion',
              onPressed: buscandoUbicacion ? null : irAMiUbicacion,
              child: buscandoUbicacion
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),

          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  'Toca el mapa o arrastra el marcador para elegir el punto exacto.\n'
                  'Lat: ${punto.latitude.toStringAsFixed(6)} | '
                  'Lng: ${punto.longitude.toStringAsFixed(6)}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}