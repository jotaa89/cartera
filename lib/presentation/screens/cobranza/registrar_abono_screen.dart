import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/config/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formato_utils.dart';
import '../../../data/models/pago_model.dart';
import '../../../data/models/prestamo_model.dart';
import '../../../data/models/cliente_model.dart';
import '../../providers/pago_provider.dart';
import '../../providers/auth_provider.dart';

class RegistrarAbonoScreen extends StatefulWidget {
  final PrestamoModel prestamo;
  final ClienteModel cliente;

  const RegistrarAbonoScreen({
    super.key,
    required this.prestamo,
    required this.cliente,
  });

  @override
  State<RegistrarAbonoScreen> createState() => _RegistrarAbonoScreenState();
}

class _RegistrarAbonoScreenState extends State<RegistrarAbonoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _moraController = TextEditingController();
  final _notasController = TextEditingController();

  String _metodoPago = AppConstants.pagoEfectivo;
  double _totalACobrar = 0.0;

  @override
  void initState() {
    super.initState();
    _montoController.text = widget.prestamo.cuotaDiaria.toStringAsFixed(2);
    _moraController.text = '0';
    _calcularTotal();
  }

  void _calcularTotal() {
    final monto = double.tryParse(_montoController.text) ?? 0;
    final mora = double.tryParse(_moraController.text) ?? 0;
    setState(() {
      _totalACobrar = monto + mora;
    });
  }

  Future<void> _registrarPago() async {
    if (!_formKey.currentState!.validate()) return;

    final pagoProvider = context.read<PagoProvider>();
    final authProvider = context.read<AuthProvider>();

    final pago = PagoModel(
      prestamoId: widget.prestamo.id!,
      fecha: DateTime.now(),
      monto: double.parse(_montoController.text),
      moraExtra: double.parse(_moraController.text),
      metodoPago: _metodoPago,
      notas: _notasController.text.isEmpty ? null : _notasController.text,
    );

    final resultado = await pagoProvider.registrarPago(pago);

    if (resultado != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Pago registrado exitosamente'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(pagoProvider.error ?? 'Error al registrar pago'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Abono'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info del cliente
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.cliente.nombre, style: AppTheme.heading2),
                    const SizedBox(height: 8),
                    Text(widget.cliente.sector, style: AppTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Saldo: ${FormatoUtils.formatearMoneda(widget.prestamo.saldoPendiente)}',
                      style: AppTheme.bodyLarge.copyWith(color: AppTheme.error),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Campo monto
            TextFormField(
              controller: _montoController,
              decoration: const InputDecoration(
                labelText: 'Monto del pago',
                prefixText: 'RD\$ ',
                helperText: 'Cuota diaria sugerida',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Ingrese un monto';
                final monto = double.tryParse(value);
                if (monto == null || monto <= 0) return 'Monto inválido';
                return null;
              },
              onChanged: (_) => _calcularTotal(),
            ),

            const SizedBox(height: 16),

            // Campo mora
            TextFormField(
              controller: _moraController,
              decoration: const InputDecoration(
                labelText: 'Mora extra (opcional)',
                prefixText: 'RD\$ ',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: (_) => _calcularTotal(),
            ),

            const SizedBox(height: 16),

            // Método de pago
            DropdownButtonFormField<String>(
              value: _metodoPago,
              decoration: const InputDecoration(
                labelText: 'Método de pago',
              ),
              items: const [
                DropdownMenuItem(
                  value: AppConstants.pagoEfectivo,
                  child: Text('Efectivo'),
                ),
                DropdownMenuItem(
                  value: AppConstants.pagoTransferencia,
                  child: Text('Transferencia'),
                ),
              ],
              onChanged: (value) {
                setState(() => _metodoPago = value!);
              },
            ),

            const SizedBox(height: 16),

            // Notas
            TextFormField(
              controller: _notasController,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Total a cobrar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL A COBRAR:', style: AppTheme.heading3),
                  Text(
                    FormatoUtils.formatearMoneda(_totalACobrar),
                    style:
                        AppTheme.montoGrande.copyWith(color: AppTheme.primary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botón cobrar
            ElevatedButton(
              onPressed: _registrarPago,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'COBRAR AHORA',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _montoController.dispose();
    _moraController.dispose();
    _notasController.dispose();
    super.dispose();
  }
}
