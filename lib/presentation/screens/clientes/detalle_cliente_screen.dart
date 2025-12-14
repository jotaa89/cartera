import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/theme/app_theme.dart';
import '../../../core/utils/formato_utils.dart';
import '../../../data/models/cliente_model.dart';
import '../../../data/repositories/prestamo_repository_impl.dart';
import 'form_cliente_screen.dart';
import '../prestamos/lista_prestamos_cliente_screen.dart';

class DetalleClienteScreen extends StatelessWidget {
  final ClienteModel cliente;

  const DetalleClienteScreen({super.key, required this.cliente});

  Future<void> _llamar(String telefono) async {
    final Uri url = Uri.parse('tel:$telefono');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FormClienteScreen(
                    cliente: cliente,
                    cobradorId: cliente.cobradorId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Foto y nombre
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  backgroundImage: cliente.fotoPath != null
                      ? FileImage(File(cliente.fotoPath!))
                      : null,
                  child: cliente.fotoPath == null
                      ? Icon(Icons.person, size: 60, color: AppTheme.primary)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(cliente.nombre,
                    style: AppTheme.heading1, textAlign: TextAlign.center),
                Text(cliente.codigo, style: AppTheme.bodySmall),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Datos básicos
          _buildSection(
            title: 'INFORMACIÓN BÁSICA',
            children: [
              _buildInfoRow(
                  'Cédula', FormatoUtils.formatearCedula(cliente.cedula)),
              _buildInfoRow(
                'Teléfono',
                FormatoUtils.formatearTelefono(cliente.telefono),
                trailing: IconButton(
                  icon: const Icon(Icons.phone, color: AppTheme.primary),
                  onPressed: () => _llamar(cliente.telefono),
                ),
              ),
              _buildInfoRow('Dirección', cliente.direccion),
              _buildInfoRow('Sector', cliente.sector),
            ],
          ),

          const SizedBox(height: 16),

          // Referencia
          _buildSection(
            title: 'REFERENCIA DE CONTACTO',
            children: [
              _buildInfoRow('Nombre', cliente.nombreReferencia),
              _buildInfoRow(
                'Teléfono',
                FormatoUtils.formatearTelefono(cliente.telReferencia),
                trailing: IconButton(
                  icon: const Icon(Icons.phone, color: AppTheme.primary),
                  onPressed: () => _llamar(cliente.telReferencia),
                ),
              ),
            ],
          ),

          if (cliente.referencia1Nombre != null) ...[
            const SizedBox(height: 16),
            _buildSection(
              title: 'REFERENCIAS PERSONALES',
              children: [
                if (cliente.referencia1Nombre != null)
                  _buildInfoRow(
                    'Ref. 1',
                    '${cliente.referencia1Nombre}\n${cliente.referencia1Tel != null ? FormatoUtils.formatearTelefono(cliente.referencia1Tel!) : ''}',
                  ),
                if (cliente.referencia2Nombre != null)
                  _buildInfoRow(
                    'Ref. 2',
                    '${cliente.referencia2Nombre}\n${cliente.referencia2Tel != null ? FormatoUtils.formatearTelefono(cliente.referencia2Tel!) : ''}',
                  ),
              ],
            ),
          ],

          if (cliente.observaciones != null &&
              cliente.observaciones!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSection(
              title: 'OBSERVACIONES',
              children: [
                Text(cliente.observaciones!, style: AppTheme.bodyMedium),
              ],
            ),
          ],

          const SizedBox(height: 24),

          // Botón ver préstamos
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListaPrestamosClienteScreen(cliente: cliente),
                ),
              );
            },
            icon: const Icon(Icons.list),
            label: const Text('VER PRÉSTAMOS'),
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: AppTheme.heading3.copyWith(color: AppTheme.primary)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style:
                    AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value, style: AppTheme.bodyMedium),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
