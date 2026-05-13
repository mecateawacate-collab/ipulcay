import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class BoletasPage extends StatefulWidget {
  const BoletasPage({super.key});

  @override
  State<BoletasPage> createState() => _BoletasPageState();
}

class _BoletasPageState extends State<BoletasPage> {
  final productos = <ProductoPedido>[
    ProductoPedido(producto: 'Agua 625ml', cantidad: 10, precio: 1.5),
  ];
  String metodoPago = 'Yape / Plin';
  final otroPagoCtrl = TextEditingController();

  double get total => productos.fold(0, (sum, item) => sum + item.total);

  void agregarProducto() {
    setState(() => productos.add(ProductoPedido(producto: '', cantidad: 1, precio: 0)));
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Boleta / Pedido',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nueva boleta', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Formulario visual para registrar pedidos de clientes.', style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 18),
          SectionCard(
            child: Column(
              children: const [
                _Input(label: 'Fecha de emisión', icon: Icons.calendar_today_outlined),
                SizedBox(height: 12),
                _Input(label: 'Cliente', icon: Icons.person_outline),
                SizedBox(height: 12),
                _Input(label: 'Tipo de negocio', icon: Icons.store_mall_directory_outlined),
                SizedBox(height: 12),
                _Input(label: 'DNI o RUC', icon: Icons.credit_card_outlined),
                SizedBox(height: 12),
                _Input(label: 'Teléfono', icon: Icons.phone_outlined),
                SizedBox(height: 12),
                _Input(label: 'Dirección', icon: Icons.location_on_outlined),
                SizedBox(height: 12),
                _Input(label: 'Vendedor', icon: Icons.badge_outlined),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(child: Text('Productos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              TextButton.icon(onPressed: agregarProducto, icon: const Icon(Icons.add), label: const Text('Agregar producto')),
            ],
          ),
          ...productos.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SectionCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text('Producto ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold))),
                        IconButton(
                          onPressed: productos.length == 1 ? null : () => setState(() => productos.removeAt(index)),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Producto', prefixIcon: Icon(Icons.inventory_2_outlined)),
                      controller: TextEditingController(text: item.producto),
                      onChanged: (v) => item.producto = v,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Cantidad'),
                            controller: TextEditingController(text: item.cantidad.toString()),
                            onChanged: (v) => setState(() => item.cantidad = int.tryParse(v) ?? 0),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Precio unit.'),
                            controller: TextEditingController(text: item.precio.toString()),
                            onChanged: (v) => setState(() => item.precio = double.tryParse(v) ?? 0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('Precio total: S/ ${item.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          }),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total a pagar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('S/ ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Método de pago', style: TextStyle(fontWeight: FontWeight.bold)),
                ...['Yape / Plin', 'Transferencia', 'Efectivo', 'Otro'].map((m) => RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(m),
                      value: m,
                      groupValue: metodoPago,
                      onChanged: (v) => setState(() => metodoPago = v!),
                    )),
                if (metodoPago == 'Otro') TextField(controller: otroPagoCtrl, decoration: const InputDecoration(labelText: 'Escribir método de pago', prefixIcon: Icon(Icons.edit_outlined))),
                const SizedBox(height: 12),
                const TextField(
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(labelText: 'Notas extra', alignLabelWithHint: true, prefixIcon: Icon(Icons.notes_outlined)),
                ),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.save_outlined), label: const Text('Guardar boleta demo'))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Input({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => TextField(decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)));
}

class ProductoPedido {
  String producto;
  int cantidad;
  double precio;
  ProductoPedido({required this.producto, required this.cantidad, required this.precio});
  double get total => cantidad * precio;
}
