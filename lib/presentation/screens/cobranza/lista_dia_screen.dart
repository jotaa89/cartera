import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/theme/app_theme.dart';
import '../../../core/utils/formato_utils.dart';
import '../../../core/utils/fecha_utils.dart';
import '../../../data/models/prestamo_model.dart';
import '../../../data/models/cliente_model.dart';
import '../../../data/repositories/cliente_repository_impl.dart';
import '../../../data/repositories/pago_repository_impl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/prestamo_provider.dart';
import '../../providers/pago_provider.dart';
import '../clientes/lista_clientes_screen.dart';
import 'registrar_abono_screen.dart';

class ListaDiaScreen extends StatefulWidget {
  const ListaDiaScreen({super.key});

  @override
  State<ListaDiaScreen> createState() => _ListaDiaScreenState();
}

class _ListaDiaScreenState extends State<ListaDiaScreen> {
  final ClienteRepositoryImpl _clienteRepo = ClienteRepositoryImpl();
  final PagoRepositoryImpl _pagoRepo = PagoRepositoryImpl();

  List<Map<String, dynamic>> _listaCobranza = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final prestamoProvider = context.read<PrestamoProvider>();
    final pagoProvider = context.read<PagoProvider>();

    final cobradorId = authProvider.usuarioActual!.id!;

    // Cargar préstamos activos
    await prestamoProvider.cargarPrestamosActivos(cobradorId);

    // Cargar totales del día
    await pagoProvider.cargarTotalesDelDia(cobradorId, DateTime.now());

    // Construir lista de cobranza
    final lista = <Map<String, dynamic>>[];
    for (var prestamo in prestamoProvider.prestamos) {
      final cliente =
          await _clienteRepo.obtenerClientePorId(prestamo.clienteId);
      if (cliente != null) {
        final yaPago = await _pagoRepo.yaPagoHoy(prestamo.id!);
        final diasMora = FechaUtils.calcularDiasMora(prestamo.fechaVencimiento);

        lista.add({
          'prestamo': prestamo,
          'cliente': cliente,
          'yaPago': yaPago,
          'diasMora': diasMora,
        });
      }
    }

    // Ordenar: primero los que no pagaron, luego por sector
    lista.sort((a, b) {
      if (a['yaPago'] != b['yaPago']) {
        return a['yaPago'] ? 1 : -1;
      }
      return (a['cliente'] as ClienteModel).sector.compareTo(
            (b['cliente'] as ClienteModel).sector,
          );
    });

    setState(() {
      _listaCobranza = lista;
      _isLoading = false;
    });
  }

  Color _getEstadoColor(Map<String, dynamic> item) {
    if (item['yaPago']) return AppTheme.estadoPagado;
    if (item['diasMora'] > 0) return AppTheme.estadoMora;
    return AppTheme.estadoPendiente;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final pagoProvider = context.watch<PagoProvider>();

    final totalACobrar = _listaCobranza
        .where((item) => !item['yaPago'])
        .fold<double>(
            0,
            (sum, item) =>
                sum + (item['prestamo'] as PrestamoModel).cuotaDiaria);

    final porcentajeCobrado = totalACobrar > 0
        ? (pagoProvider.totalCobradoHoy / totalACobrar * 100).clamp(0, 100)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(authProvider.usuarioActual?.nombre ?? 'Cobrador'),
            Text(
              FechaUtils.formatearFecha(DateTime.now()),
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => _mostrarMenuUsuario(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarDatos,
        child: Column(
          children: [
            // Resumen del día
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('A cobrar hoy', style: AppTheme.bodySmall),
                          Text(
                            FormatoUtils.formatearMoneda(totalACobrar),
                            style: AppTheme.montoMediano,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Ya cobrado', style: AppTheme.bodySmall),
                          Text(
                            FormatoUtils.formatearMoneda(
                                pagoProvider.totalCobradoHoy),
                            style: AppTheme.montoMediano
                                .copyWith(color: AppTheme.success),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: porcentajeCobrado / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppTheme.success),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${porcentajeCobrado.toStringAsFixed(0)}% completado',
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Lista de clientes
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_listaCobranza.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('No hay préstamos activos'),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _listaCobranza.length,
                  itemBuilder: (context, index) {
                    final item = _listaCobranza[index];
                    return _buildClienteTile(item);
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ListaClientesScreen(),
            ),
          ).then((_) => _cargarDatos());
        },
        icon: const Icon(Icons.people),
        label: const Text('Clientes'),
      ),
    );
  }

  Widget _buildClienteTile(Map<String, dynamic> item) {
    final prestamo = item['prestamo'] as PrestamoModel;
    final cliente = item['cliente'] as ClienteModel;
    final yaPago = item['yaPago'] as bool;
    final diasMora = item['diasMora'] as int;
    final color = _getEstadoColor(item);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          if (!yaPago) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RegistrarAbonoScreen(
                  prestamo: prestamo,
                  cliente: cliente,
                ),
              ),
            ).then((_) => _cargarDatos());
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Indicador de color
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),

              // Info del cliente
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cliente.nombre,
                      style: AppTheme.heading3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cliente.sector,
                      style: AppTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (diasMora > 0) ...[
                          const Icon(Icons.warning,
                              size: 16, color: AppTheme.error),
                          const SizedBox(width: 4),
                          Text(
                            FormatoUtils.formatearDiasMora(diasMora),
                            style: AppTheme.bodySmall
                                .copyWith(color: AppTheme.error),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          FormatoUtils.formatearTelefono(cliente.telefono),
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Monto
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    FormatoUtils.formatearMoneda(prestamo.cuotaDiaria),
                    style: AppTheme.montoPequeno.copyWith(
                      color: yaPago ? AppTheme.success : AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (yaPago)
                    const Chip(
                      label: Text('PAGADO', style: TextStyle(fontSize: 10)),
                      backgroundColor: AppTheme.estadoPagado,
                      labelStyle: TextStyle(color: Colors.white),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarMenuUsuario(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                Navigator.pop(context);
                authProvider.logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
