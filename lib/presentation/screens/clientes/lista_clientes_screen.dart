import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/theme/app_theme.dart';
import '../../../core/utils/formato_utils.dart';
import '../../../data/models/cliente_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cliente_provider.dart';
import 'form_cliente_screen.dart';
import 'detalle_cliente_screen.dart';

class ListaClientesScreen extends StatefulWidget {
  const ListaClientesScreen({super.key});

  @override
  State<ListaClientesScreen> createState() => _ListaClientesScreenState();
}

class _ListaClientesScreenState extends State<ListaClientesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    final authProvider = context.read<AuthProvider>();
    final clienteProvider = context.read<ClienteProvider>();
    await clienteProvider
        .cargarClientesPorCobrador(authProvider.usuarioActual!.id!);
  }

  void _buscar(String query) {
    setState(() => _searchQuery = query.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final clienteProvider = context.watch<ClienteProvider>();
    final authProvider = context.read<AuthProvider>();

    final clientesFiltrados = clienteProvider.clientes.where((cliente) {
      if (_searchQuery.isEmpty) return true;
      return cliente.nombre.toLowerCase().contains(_searchQuery) ||
          cliente.cedula.contains(_searchQuery) ||
          cliente.telefono.contains(_searchQuery) ||
          cliente.codigo.toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Clientes'),
      ),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar cliente...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _buscar('');
                        },
                      )
                    : null,
              ),
              onChanged: _buscar,
            ),
          ),

          // Lista de clientes
          if (clienteProvider.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (clientesFiltrados.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  _searchQuery.isEmpty
                      ? 'No tienes clientes registrados'
                      : 'No se encontraron clientes',
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: clientesFiltrados.length,
                itemBuilder: (context, index) {
                  final cliente = clientesFiltrados[index];
                  return _buildClienteTile(cliente);
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FormClienteScreen(
                cobradorId: authProvider.usuarioActual!.id!,
              ),
            ),
          ).then((_) => _cargarClientes());
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo Cliente'),
      ),
    );
  }

  Widget _buildClienteTile(ClienteModel cliente) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary,
          child: Text(
            FormatoUtils.obtenerIniciales(cliente.nombre),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(cliente.nombre, style: AppTheme.heading3),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cliente.codigo, style: AppTheme.bodySmall),
            Text(FormatoUtils.formatearTelefono(cliente.telefono)),
            Text(cliente.sector, style: AppTheme.bodySmall),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetalleClienteScreen(cliente: cliente),
            ),
          ).then((_) => _cargarClientes());
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
