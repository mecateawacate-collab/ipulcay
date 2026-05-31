import 'package:cloud_firestore/cloud_firestore.dart';

class ModeloCliente {
  final String id;
  final String nombre;
  final String nombreBusqueda;
  final String documento;
  final String telefono;
  final String direccionTexto;
  final String tipoNegocio;
  final bool activo;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;
  final String creadoPorId;
  final String creadoPorNombre;

  const ModeloCliente({
    required this.id,
    required this.nombre,
    required this.nombreBusqueda,
    required this.documento,
    required this.telefono,
    required this.direccionTexto,
    required this.tipoNegocio,
    required this.activo,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    required this.creadoPorId,
    required this.creadoPorNombre,
  });

  factory ModeloCliente.fromMap(String id, Map<String, dynamic> data) {
    return ModeloCliente(
      id: id,
      nombre: data['nombre'] ?? '',
      nombreBusqueda: data['nombreBusqueda'] ?? '',
      documento: data['documento'] ?? data['dni'] ?? '',
      telefono: data['telefono'] ?? '',
      direccionTexto: data['direccionTexto'] ?? '',
      tipoNegocio: data['tipoNegocio'] ?? '',
      activo: data['activo'] ?? true,
      fechaCreacion: _fecha(data['fechaCreacion']),
      fechaActualizacion: _fecha(data['fechaActualizacion']),
      creadoPorId: data['creadoPorId'] ?? '',
      creadoPorNombre: data['creadoPorNombre'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'nombreBusqueda': nombreBusqueda,
      'documento': documento,
      'telefono': telefono,
      'direccionTexto': direccionTexto,
      'tipoNegocio': tipoNegocio,
      'activo': activo,
      'fechaCreacion': fechaCreacion,
      'fechaActualizacion': fechaActualizacion,
      'creadoPorId': creadoPorId,
      'creadoPorNombre': creadoPorNombre,
    };
  }

  static DateTime? _fecha(dynamic valor) {
    if (valor == null) return null;
    if (valor is Timestamp) return valor.toDate();
    if (valor is DateTime) return valor;
    return null;
  }
}