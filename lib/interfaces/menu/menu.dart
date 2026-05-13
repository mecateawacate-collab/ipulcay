import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuItem('Boletas', 'Registrar una venta o pedido', Icons.receipt_long, '/boletas', AppColors.accent),
      _MenuItem('Mapa', 'Locales disponibles y zonas rechazadas', Icons.map_outlined, '/mapa', AppColors.secondary),
      _MenuItem('Registros', 'Vendedores y visitas recientes', Icons.assignment_ind_outlined, '/registros', AppColors.primary),
    ];

    return AppShell(
      title: 'Menú principal',
      actions: [IconButton(onPressed: () => Navigator.pushReplacementNamed(context, '/'), icon: const Icon(Icons.logout))],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.secondary.withOpacity(.35), borderRadius: BorderRadius.circular(18)),
                  child: const Icon(Icons.dashboard_customize, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Panel vendedor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Administra visitas, ventas y zonas de oportunidad.', style: TextStyle(color: AppColors.muted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => Navigator.pushNamed(context, item.route),
                  child: SectionCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: item.color.withOpacity(.35), borderRadius: BorderRadius.circular(18)),
                          child: Icon(item.icon, color: AppColors.text),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)), const SizedBox(height: 4), Text(item.subtitle, style: const TextStyle(color: AppColors.muted))])),
                        const Icon(Icons.chevron_right, color: AppColors.muted),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _MenuItem {
  final String title, subtitle, route;
  final IconData icon;
  final Color color;
  _MenuItem(this.title, this.subtitle, this.icon, this.route, this.color);
}
