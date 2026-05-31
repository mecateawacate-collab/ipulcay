import 'package:flutter/material.dart';

import 'colores_app.dart';
import 'textos_app.dart';

class TemaApp {
  static ThemeData claro = crearTemaClaro(
    principal: ColoresApp.claroPrincipal,
    secundario: ColoresApp.claroSecundario,
    fondo: ColoresApp.claroFondo,
    tarjeta: ColoresApp.claroTarjeta,
    texto: ColoresApp.claroTexto,
    textoSuave: ColoresApp.claroTextoSuave,
    borde: ColoresApp.claroBorde,
  );

  static ThemeData pastel = crearTemaClaro(
    principal: ColoresApp.pastelPrincipal,
    secundario: ColoresApp.pastelSecundario,
    fondo: ColoresApp.pastelFondo,
    tarjeta: ColoresApp.pastelTarjeta,
    texto: ColoresApp.pastelTexto,
    textoSuave: ColoresApp.pastelTextoSuave,
    borde: ColoresApp.pastelBorde,
    radio: 22,
  );

  static ThemeData azul = crearTemaClaro(
    principal: ColoresApp.azulPrincipal,
    secundario: ColoresApp.azulSecundario,
    fondo: ColoresApp.azulFondo,
    tarjeta: ColoresApp.azulTarjeta,
    texto: ColoresApp.azulTexto,
    textoSuave: ColoresApp.azulTextoSuave,
    borde: ColoresApp.azulBorde,
  );

  static ThemeData morado = crearTemaClaro(
    principal: ColoresApp.moradoPrincipal,
    secundario: ColoresApp.moradoSecundario,
    fondo: ColoresApp.moradoFondo,
    tarjeta: ColoresApp.moradoTarjeta,
    texto: ColoresApp.moradoTexto,
    textoSuave: ColoresApp.moradoTextoSuave,
    borde: ColoresApp.moradoBorde,
  );

  static ThemeData naranja = crearTemaClaro(
    principal: ColoresApp.naranjaPrincipal,
    secundario: ColoresApp.naranjaSecundario,
    fondo: ColoresApp.naranjaFondo,
    tarjeta: ColoresApp.naranjaTarjeta,
    texto: ColoresApp.naranjaTexto,
    textoSuave: ColoresApp.naranjaTextoSuave,
    borde: ColoresApp.naranjaBorde,
  );

  static ThemeData oscuro = crearTemaOscuro(
    principal: ColoresApp.oscuroPrincipal,
    secundario: ColoresApp.oscuroSecundario,
    fondo: ColoresApp.oscuroFondo,
    tarjeta: ColoresApp.oscuroTarjeta,
    texto: ColoresApp.oscuroTexto,
    textoSuave: ColoresApp.oscuroTextoSuave,
    borde: ColoresApp.oscuroBorde,
  );

  static ThemeData oscuroAzul = crearTemaOscuro(
    principal: ColoresApp.oscuroAzulPrincipal,
    secundario: ColoresApp.oscuroAzulSecundario,
    fondo: ColoresApp.oscuroAzulFondo,
    tarjeta: ColoresApp.oscuroAzulTarjeta,
    texto: ColoresApp.oscuroAzulTexto,
    textoSuave: ColoresApp.oscuroAzulTextoSuave,
    borde: ColoresApp.oscuroAzulBorde,
  );

  static ThemeData crearTemaClaro({
    required Color principal,
    required Color secundario,
    required Color fondo,
    required Color tarjeta,
    required Color texto,
    required Color textoSuave,
    required Color borde,
    double radio = 18,
  }) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: TextosApp.fuentePrincipal,
      brightness: Brightness.light,
      scaffoldBackgroundColor: fondo,
      colorScheme: ColorScheme.light(
        primary: principal,
        secondary: secundario,
        surface: tarjeta,
        error: ColoresApp.error,
        onPrimary: Colors.white,
        onSecondary: texto,
        onSurface: texto,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: principal,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontFamily: TextosApp.fuentePrincipal,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: tarjeta,
        elevation: 2,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radio),
          side: BorderSide(
            color: borde,
            width: 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: principal,
          foregroundColor: Colors.white,
          textStyle: TextosApp.boton,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: principal,
          textStyle: TextosApp.boton,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
          side: BorderSide(
            color: principal,
            width: 1.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tarjeta,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: TextStyle(
          color: textoSuave,
        ),
        hintStyle: TextStyle(
          color: textoSuave,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: borde,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: principal,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: ColoresApp.error,
            width: 1.4,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: ColoresApp.error,
            width: 2,
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: TextosApp.fuentePrincipal,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: texto,
        ),
        titleLarge: TextStyle(
          fontFamily: TextosApp.fuentePrincipal,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: texto,
        ),
        titleMedium: TextStyle(
          fontFamily: TextosApp.fuentePrincipal,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: texto,
        ),
        titleSmall: TextStyle(
          fontFamily: TextosApp.fuentePrincipal,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: texto,
        ),
        bodyLarge: TextStyle(
          fontFamily: TextosApp.fuentePrincipal,
          fontSize: 16,
          color: texto,
        ),
        bodyMedium: TextStyle(
          fontFamily: TextosApp.fuentePrincipal,
          fontSize: 14,
          color: textoSuave,
        ),
        bodySmall: TextStyle(
          fontFamily: TextosApp.fuentePrincipal,
          fontSize: 12,
          color: textoSuave,
        ),
      ),
    );
  }

  static ThemeData crearTemaOscuro({
    required Color principal,
    required Color secundario,
    required Color fondo,
    required Color tarjeta,
    required Color texto,
    required Color textoSuave,
    required Color borde,
  }) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: TextosApp.fuentePrincipal,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: fondo,
      colorScheme: ColorScheme.dark(
        primary: principal,
        secondary: secundario,
        surface: tarjeta,
        error: ColoresApp.error,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: texto,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: tarjeta,
        foregroundColor: texto,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: TextosApp.fuentePrincipal,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: texto,
        ),
      ),
      cardTheme: CardThemeData(
        color: tarjeta,
        elevation: 2,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: borde,
            width: 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: principal,
          foregroundColor: Colors.black,
          textStyle: TextosApp.boton,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: principal,
          textStyle: TextosApp.boton,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
          side: BorderSide(
            color: principal,
            width: 1.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tarjeta,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: TextStyle(
          color: textoSuave,
        ),
        hintStyle: TextStyle(
          color: textoSuave,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: borde,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: principal,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: ColoresApp.error,
            width: 1.4,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: ColoresApp.error,
            width: 2,
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: TextosApp.fuentePrincipal,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: texto,
        ),
        titleLarge: TextStyle(
          fontFamily: TextosApp.fuentePrincipal,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: texto,
        ),
        titleMedium: TextStyle(
          fontFamily: TextosApp.fuentePrincipal,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: texto,
        ),
        titleSmall: TextStyle(
          fontFamily: TextosApp.fuentePrincipal,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: texto,
        ),
        bodyLarge: TextStyle(
          fontFamily: TextosApp.fuentePrincipal,
          fontSize: 16,
          color: texto,
        ),
        bodyMedium: TextStyle(
          fontFamily: TextosApp.fuentePrincipal,
          fontSize: 14,
          color: textoSuave,
        ),
        bodySmall: TextStyle(
          fontFamily: TextosApp.fuentePrincipal,
          fontSize: 12,
          color: textoSuave,
        ),
      ),
    );
  }
}