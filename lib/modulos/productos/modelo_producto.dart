class ModeloProducto {
  final String id;
  final String nombre;
  final String categoria;
  final double precio;
  final String imagenUrl;
  final String imagenPath;
  final bool activo;

  ModeloProducto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.imagenUrl,
    required this.imagenPath,
    required this.activo,
  });

  factory ModeloProducto.fromMap(String id, Map<String, dynamic> data) {
    return ModeloProducto(
      id: id,
      nombre: data['nombre'] ?? '',
      categoria: data['categoria'] ?? 'Otros',
      precio: (data['precio'] ?? 0).toDouble(),
      imagenUrl: data['imagenUrl'] ?? '',
      imagenPath: data['imagenPath'] ?? '',
      activo: data['activo'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'categoria': categoria,
      'precio': precio,
      'imagenUrl': imagenUrl,
      'imagenPath': imagenPath,
      'activo': activo,
    };
  }
}