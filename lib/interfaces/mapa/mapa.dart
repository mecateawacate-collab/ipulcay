import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MapaPage extends StatelessWidget {
  const MapaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locales = [
      _Local('Bodega San José', 'Aceptado', 48, 80, AppColors.secondary),
      _Local('Minimarket Luna', 'Rechazado', 210, 105, AppColors.danger),
      _Local('Ferretería Norte', 'Pendiente', 120, 210, AppColors.accent),
      _Local('Restaurante El Punto', 'Rechazado', 255, 260, AppColors.danger),
      _Local('Botica Salud', 'Aceptado', 70, 310, AppColors.secondary),
    ];

    return AppShell(
      title: 'Mapa de locales',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ubicaciones para visitar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Mock visual tipo Google Maps. Los puntos rojos indican locales donde hubo rechazo.', style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 16),
          SectionCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: SizedBox(
                height: 390,
                child: Stack(
                  children: [
                    Container(color: const Color(0xFFE9F1E7)),
                    ...List.generate(8, (i) => Positioned(left: 0, right: 0, top: 35.0 + i * 44, child: Container(height: 2, color: Colors.white.withOpacity(.8)))),
                    ...List.generate(5, (i) => Positioned(top: 0, bottom: 0, left: 40.0 + i * 65, child: Container(width: 2, color: Colors.white.withOpacity(.75)))),
                    Positioned(left: 18, top: 20, child: _MapLabel('Av. Principal')),
                    Positioned(right: 20, bottom: 20, child: _MapLabel('Zona comercial')),
                    ...locales.map((l) => Positioned(
                          left: l.left,
                          top: l.top,
                          child: Tooltip(
                            message: '${l.nombre} - ${l.estado}',
                            child: Column(
                              children: [
                                Icon(Icons.location_pin, color: l.color, size: 38),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                  child: Text(l.estado, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...locales.map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SectionCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [Icon(Icons.store, color: l.color), const SizedBox(width: 12), Expanded(child: Text(l.nombre, style: const TextStyle(fontWeight: FontWeight.w600))), Text(l.estado, style: TextStyle(color: l.color, fontWeight: FontWeight.bold))]),
                ),
              )),
        ],
      ),
    );
  }
}

class _MapLabel extends StatelessWidget {
  final String text;
  const _MapLabel(this.text);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: Colors.white.withOpacity(.85), borderRadius: BorderRadius.circular(12)),
        child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
      );
}

class _Local {
  final String nombre, estado;
  final double left, top;
  final Color color;
  _Local(this.nombre, this.estado, this.left, this.top, this.color);
}
