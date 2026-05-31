import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class DatosUpdate {
  final bool activo;
  final bool obligatorio;
  final int versionCode;
  final String versionName;
  final String titulo;
  final String mensaje;
  final String storagePath;

  const DatosUpdate({
    required this.activo,
    required this.obligatorio,
    required this.versionCode,
    required this.versionName,
    required this.titulo,
    required this.mensaje,
    required this.storagePath,
  });

  factory DatosUpdate.fromMap(Map<String, dynamic> map) {
    return DatosUpdate(
      activo: map['activa'] == true,
      obligatorio: map['obligatoria'] == true,
      versionCode: int.tryParse(map['versionCodigo'].toString()) ?? 0,
      versionName: map['versionNombre'] ?? '',
      titulo: map['titulo'] ?? 'Actualización disponible',
      mensaje: map['mensaje'] ?? 'Hay una nueva versión de la aplicación.',
      storagePath: map['storagePath'] ?? '',
    );
  }
}

class ResultadoUpdate {
  final bool hayUpdate;
  final bool obligatorio;
  final int versionInstalada;
  final DatosUpdate? datos;

  const ResultadoUpdate({
    required this.hayUpdate,
    required this.obligatorio,
    required this.versionInstalada,
    required this.datos,
  });
}

class ServicioUpdate {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<ResultadoUpdate> revisarUpdate() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    final int versionInstalada = int.tryParse(info.buildNumber) ?? 1;

    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _db.collection('updates').doc('actual').get();

    if (!doc.exists || doc.data() == null) {
      return ResultadoUpdate(
        hayUpdate: false,
        obligatorio: false,
        versionInstalada: versionInstalada,
        datos: null,
      );
    }

    final DatosUpdate datos = DatosUpdate.fromMap(doc.data()!);

    if (!datos.activo) {
      return ResultadoUpdate(
        hayUpdate: false,
        obligatorio: false,
        versionInstalada: versionInstalada,
        datos: datos,
      );
    }

    final bool hayUpdate = versionInstalada < datos.versionCode;

    return ResultadoUpdate(
      hayUpdate: hayUpdate,
      obligatorio: hayUpdate && datos.obligatorio,
      versionInstalada: versionInstalada,
      datos: datos,
    );
  }

  Future<File> descargarApk(DatosUpdate datos) async {
    if (datos.storagePath.isEmpty) {
      throw Exception('No se encontró la ruta del APK en Storage.');
    }

    final Directory carpeta = await getTemporaryDirectory();

    final String nombreArchivo = datos.storagePath.split('/').last;

    final File archivo = File('${carpeta.path}/$nombreArchivo');

    final Reference referencia = _storage.ref(datos.storagePath);

    await referencia.writeToFile(archivo);

    return archivo;
  }

  Future<void> instalarApk(DatosUpdate datos) async {
    final File archivo = await descargarApk(datos);

    await OpenFilex.open(
      archivo.path,
      type: 'application/vnd.android.package-archive',
    );
  }
}