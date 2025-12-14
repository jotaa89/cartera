import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/config/theme/app_theme.dart';
import '../../../core/utils/formato_utils.dart';
import '../../../data/models/cliente_model.dart';
import '../../providers/cliente_provider.dart';

class FormClienteScreen extends StatefulWidget {
  final ClienteModel? cliente;
  final int cobradorId;

  const FormClienteScreen({
    super.key,
    this.cliente,
    required this.cobradorId,
  });

  @override
  State<FormClienteScreen> createState() => _FormClienteScreenState();
}

class _FormClienteScreenState extends State<FormClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _telReferenciaController = TextEditingController();
  final _nombreReferenciaController = TextEditingController();
  final _direccionController = TextEditingController();
  final _sectorController = TextEditingController();
  final _ref1NombreController = TextEditingController();
  final _ref1TelController = TextEditingController();
  final _ref2NombreController = TextEditingController();
  final _ref2TelController = TextEditingController();
  final _observacionesController = TextEditingController();

  String? _fotoPath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.cliente != null) {
      _nombreController.text = widget.cliente!.nombre;
      _cedulaController.text = widget.cliente!.cedula;
      _telefonoController.text = widget.cliente!.telefono;
      _telReferenciaController.text = widget.cliente!.telReferencia;
      _nombreReferenciaController.text = widget.cliente!.nombreReferencia;
      _direccionController.text = widget.cliente!.direccion;
      _sectorController.text = widget.cliente!.sector;
      _ref1NombreController.text = widget.cliente!.referencia1Nombre ?? '';
      _ref1TelController.text = widget.cliente!.referencia1Tel ?? '';
      _ref2NombreController.text = widget.cliente!.referencia2Nombre ?? '';
      _ref2TelController.text = widget.cliente!.referencia2Tel ?? '';
      _observacionesController.text = widget.cliente!.observaciones ?? '';
      _fotoPath = widget.cliente!.fotoPath;
    }
  }

  Future<void> _tomarFoto(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() => _fotoPath = image.path);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final clienteProvider = context.read<ClienteProvider>();

    final cliente = ClienteModel(
      id: widget.cliente?.id,
      codigo: widget.cliente?.codigo ?? '',
      nombre: FormatoUtils.capitalizarPalabras(_nombreController.text),
      cedula: _cedulaController.text.replaceAll('-', ''),
      telefono: _telefonoController.text.replaceAll(RegExp(r'\D'), ''),
      telReferencia:
          _telReferenciaController.text.replaceAll(RegExp(r'\D'), ''),
      nombreReferencia:
          FormatoUtils.capitalizarPalabras(_nombreReferenciaController.text),
      direccion: _direccionController.text,
      sector: _sectorController.text.toUpperCase(),
      fotoPath: _fotoPath,
      referencia1Nombre: _ref1NombreController.text.isEmpty
          ? null
          : _ref1NombreController.text,
      referencia1Tel: _ref1TelController.text.isEmpty
          ? null
          : _ref1TelController.text.replaceAll(RegExp(r'\D'), ''),
      referencia2Nombre: _ref2NombreController.text.isEmpty
          ? null
          : _ref2NombreController.text,
      referencia2Tel: _ref2TelController.text.isEmpty
          ? null
          : _ref2TelController.text.replaceAll(RegExp(r'\D'), ''),
      observaciones: _observacionesController.text.isEmpty
          ? null
          : _observacionesController.text,
      cobradorId: widget.cobradorId,
      fechaCreacion: widget.cliente?.fechaCreacion,
    );

    bool success;
    if (widget.cliente == null) {
      final resultado = await clienteProvider.crearCliente(cliente);
      success = resultado != null;
    } else {
      success = await clienteProvider.actualizarCliente(cliente);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Cliente guardado exitosamente'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(clienteProvider.error ?? 'Error al guardar'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.cliente == null ? 'Nuevo Cliente' : 'Editar Cliente'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Foto
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    backgroundImage:
                        _fotoPath != null ? FileImage(File(_fotoPath!)) : null,
                    child: _fotoPath == null
                        ? const Icon(Icons.person,
                            size: 60, color: AppTheme.primary)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: PopupMenuButton(
                      icon: const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.primary,
                        child: Icon(Icons.camera_alt,
                            size: 18, color: Colors.white),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'camera',
                          child: Row(
                            children: [
                              Icon(Icons.camera_alt),
                              SizedBox(width: 8),
                              Text('Tomar foto'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'gallery',
                          child: Row(
                            children: [
                              Icon(Icons.photo_library),
                              SizedBox(width: 8),
                              Text('Desde galería'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'camera') _tomarFoto(ImageSource.camera);
                        if (value == 'gallery') _tomarFoto(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Datos básicos
            const Text('DATOS BÁSICOS', style: AppTheme.heading3),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre completo *'),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v?.isEmpty ?? true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _cedulaController,
              decoration: const InputDecoration(
                labelText: 'Cédula *',
                hintText: '001-1234567-8',
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Campo requerido';
                if (!FormatoUtils.validarCedula(v!)) return 'Cédula inválida';
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono personal *',
                hintText: '809-123-4567',
              ),
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Campo requerido';
                if (!FormatoUtils.validarTelefono(v!))
                  return 'Teléfono inválido';
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Referencia de contacto
            const Text('REFERENCIA DE CONTACTO', style: AppTheme.heading3),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nombreReferenciaController,
              decoration:
                  const InputDecoration(labelText: 'Nombre de referencia *'),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v?.isEmpty ?? true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _telReferenciaController,
              decoration:
                  const InputDecoration(labelText: 'Teléfono de referencia *'),
              keyboardType: TextInputType.phone,
              validator: (v) => v?.isEmpty ?? true ? 'Campo requerido' : null,
            ),

            const SizedBox(height: 24),

            // Dirección
            const Text('DIRECCIÓN', style: AppTheme.heading3),
            const SizedBox(height: 16),

            TextFormField(
              controller: _direccionController,
              decoration: const InputDecoration(
                labelText: 'Dirección completa *',
                hintText: 'Calle, número, apto.',
              ),
              maxLines: 2,
              validator: (v) => v?.isEmpty ?? true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _sectorController,
              decoration: const InputDecoration(labelText: 'Sector/Barrio *'),
              textCapitalization: TextCapitalization.characters,
              validator: (v) => v?.isEmpty ?? true ? 'Campo requerido' : null,
            ),

            const SizedBox(height: 24),

            // Referencias personales (opcional)
            const Text('REFERENCIAS PERSONALES (Opcional)',
                style: AppTheme.heading3),
            const SizedBox(height: 16),

            TextFormField(
              controller: _ref1NombreController,
              decoration:
                  const InputDecoration(labelText: 'Referencia 1 - Nombre'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _ref1TelController,
              decoration:
                  const InputDecoration(labelText: 'Referencia 1 - Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _ref2NombreController,
              decoration:
                  const InputDecoration(labelText: 'Referencia 2 - Nombre'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _ref2TelController,
              decoration:
                  const InputDecoration(labelText: 'Referencia 2 - Teléfono'),
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 24),

            // Observaciones
            TextFormField(
              controller: _observacionesController,
              decoration: const InputDecoration(
                labelText: 'Observaciones',
                hintText: 'Notas adicionales sobre el cliente...',
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _guardar,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child:
                  const Text('GUARDAR CLIENTE', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cedulaController.dispose();
    _telefonoController.dispose();
    _telReferenciaController.dispose();
    _nombreReferenciaController.dispose();
    _direccionController.dispose();
    _sectorController.dispose();
    _ref1NombreController.dispose();
    _ref1TelController.dispose();
    _ref2NombreController.dispose();
    _ref2TelController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }
}
