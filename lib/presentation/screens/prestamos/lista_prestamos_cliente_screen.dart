import 'package:flutter/material.dart';
import '../../../core/config/theme/app_theme.dart';
import '../../../core/utils/formato_utils.dart';
import '../../../core/utils/fecha_utils.dart';
import '../../../data/models/cliente_model.dart';
import '../../../data/repositories/prestamo_repository_impl.dart';
import '../../../data/models/prestamo_model.dart';

class ListaPrestamosClienteScreen extends StatefulWidget {
  final ClienteModel cliente;

  const ListaPrestamosClienteScreen({super.key, required this.cliente});

  @override
  State<ListaPrestamosClienteScreen> createState() =>
      _ListaPrestamosClienteScreenState();
}

class _ListaPrestamosClienteScreenState
    extends State<ListaPrestamosClienteScreen> {
  final PrestamoRepositoryImpl _prestamoRepo = PrestamoRepositoryImpl();
  List<PrestamoModel> _prestamos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPrestamos();
  }

  Future<void> _cargarPrestamos() async {
    setState(() => _isLoading = true);
    _prestamos =
        await _prestamoRepo.obtenerPrestamosPorCliente(widget.cliente.id!);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Préstamos de ${widget.cliente.nombre}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _prestamos.isEmpty
              ? const Center(child: Text('No hay préstamos registrados'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _prestamos.length,
                  itemBuilder: (context, index) {
                    final prestamo = _prestamos[index];
                    return _buildPrestamoCard(prestamo);
                  },
                ),
    );
  }

  Widget _buildPrestamoCard(PrestamoModel prestamo) {
    final Color estadoColor = prestamo.estado == 'ACTIVO'
        ? AppTheme.success
        : prestamo.estado == 'COMPLETADO'
            ? AppTheme.primary
            : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(prestamo.codigo, style: AppTheme.heading3),
                Chip(
                  label: Text(
                    FormatoUtils.formatearEstadoPrestamo(prestamo.estado),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: estadoColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow(
                'Capital', FormatoUtils.formatearMoneda(prestamo.capital)),
            _buildInfoRow(
                'Cuota', FormatoUtils.formatearMoneda(prestamo.cuotaDiaria)),
            _buildInfoRow(
                'Saldo', FormatoUtils.formatearMoneda(prestamo.saldoPendiente)),
            _buildInfoRow(
                'Inicio', FechaUtils.formatearFecha(prestamo.fechaInicio)),
            _buildInfoRow('Vencimiento',
                FechaUtils.formatearFecha(prestamo.fechaVencimiento)),
            if (prestamo.estado == 'ACTIVO') ...[
              const Divider(),
              Row(
                children: [
                  const Icon(Icons.warning, size: 16, color: AppTheme.warning),
                  const SizedBox(width: 8),
                  Text(
                    'Mora: ${FechaUtils.calcularDiasMora(prestamo.fechaVencimiento)} días',
                    style:
                        AppTheme.bodyMedium.copyWith(color: AppTheme.warning),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodySmall),
          Text(value,
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
