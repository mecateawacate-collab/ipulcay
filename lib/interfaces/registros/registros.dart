import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RegistrosPage extends StatelessWidget {
  const RegistrosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vendedores = [
      {'nombre': 'Luis Ramos', 'zona': 'Centro', 'visitas': '12', 'rechazos': '3'},
      {'nombre': 'Ana Torres', 'zona': 'San Miguel', 'visitas': '9', 'rechazos': '1'},
      {'nombre': 'Carlos Peña', 'zona': 'La Victoria', 'visitas': '15', 'rechazos': '5'},
      {'nombre': 'María Flores', 'zona': 'Surco', 'visitas': '7', 'rechazos': '2'},
    ];

    return AppShell(
      title: 'Registros',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Vendedores registrados', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Simulación de control de visitas y rechazos por zona.', style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 18),
          ...vendedores.map((v) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SectionCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.secondary.withOpacity(.45),
                        child: const Icon(Icons.person, color: AppColors.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(v['nombre']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('Zona: ${v['zona']}', style: const TextStyle(color: AppColors.muted)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${v['visitas']} visitas', style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text('${v['rechazos']} rechazos', style: const TextStyle(color: AppColors.danger)),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 10),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nuevo registro rápido', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 12),
                const TextField(decoration: InputDecoration(labelText: 'Nombre del vendedor', prefixIcon: Icon(Icons.badge_outlined))),
                const SizedBox(height: 12),
                const TextField(decoration: InputDecoration(labelText: 'Zona asignada', prefixIcon: Icon(Icons.place_outlined))),
                const SizedBox(height: 14),
                SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Simular registro'))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
