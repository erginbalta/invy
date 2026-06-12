import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../app/inventory_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/area_display.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/zero_number_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../areas/models/area.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({
    this.product,
    this.initialCode,
    super.key,
  });

  final Product? product;
  final String? initialCode;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _minimumController = TextEditingController(text: '0');
  final _picker = ImagePicker();

  String? _imagePath;
  int? _selectedAreaId;
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    if (product != null) {
      _nameController.text = product.name;
      _codeController.text = product.code;
      _selectedAreaId = product.areaId;
      _stockController.text = product.currentStock.toString();
      _minimumController.text = product.minimumStock.toString();
      _imagePath = product.imagePath;
    } else if (widget.initialCode != null) {
      _codeController.text = widget.initialCode!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _stockController.dispose();
    _minimumController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 78,
      maxWidth: 1400,
    );
    if (picked == null) return;
    setState(() => _imagePath = picked.path);
  }

  Future<void> _chooseImageSource() async {
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.chooseImageSource,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(l10n.camera),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(l10n.gallery),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (source != null) {
      await _pickImage(source);
    }
  }

  Future<void> _openAreaDialog() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.newArea),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l10n.areaName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();

    final name = result?.trim();
    if (name == null || name.isEmpty || !mounted) return;

    final area = await context.read<InventoryController>().createArea(name);
    if (!mounted) return;
    setState(() => _selectedAreaId = area.id);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    final controller = context.read<InventoryController>();
    final name = _nameController.text.trim();
    final code = _codeController.text.trim();
    final stock = int.parse(_stockController.text.trim());
    final minimum = int.parse(_minimumController.text.trim());
    final areaId = _selectedAreaId;

    if (areaId == null) {
      setState(() {
        _saving = false;
        _error = AppLocalizations.of(context).areaRequired;
      });
      return;
    }

    try {
      if (_isEditing) {
        final current = widget.product!;
        await controller.updateProduct(
          current.copyWith(
            name: name,
            code: code,
            areaId: areaId,
            minimumStock: minimum,
            imagePath: _imagePath,
          ),
        );
      } else {
        await controller.createProduct(
          name: name,
          code: code.isEmpty ? null : code,
          areaId: areaId,
          currentStock: stock,
          minimumStock: minimum,
          imagePath: _imagePath,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on DuplicateCodeException {
      setState(() => _error = AppLocalizations.of(context).codeAlreadyUsedInArea);
    } on MissingAreaException {
      setState(() => _error = AppLocalizations.of(context).areaRequired);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final areas = context.watch<InventoryController>().areas;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? l10n.editProduct : l10n.addProduct)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ImagePickerButton(
                      imagePath: _imagePath,
                      onTap: _chooseImageSource,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(labelText: l10n.productName),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.enterProductName;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _codeController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: _isEditing
                            ? l10n.barcodeOrCode
                            : l10n.barcodeOrCodeOptional,
                        helperText: _isEditing ? null : l10n.barcodeCodeHelper,
                      ),
                      validator: (value) {
                        if (_isEditing && (value == null || value.trim().isEmpty)) {
                          return l10n.savedProductNeedsCode;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _AreaSelector(
                      areas: areas,
                      selectedAreaId: _selectedAreaId,
                      onChanged: (value) => setState(() => _selectedAreaId = value),
                      onAddArea: _openAreaDialog,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ZeroNumberField(
                            controller: _stockController,
                            enabled: !_isEditing,
                            labelText: _isEditing ? l10n.currentStock : l10n.startingStock,
                            helperText: _isEditing ? l10n.useStockActions : null,
                            validator: _validateWholeNumber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ZeroNumberField(
                            controller: _minimumController,
                            labelText: l10n.minimumStock,
                            validator: _validateWholeNumber,
                          ),
                        ),
                      ],
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: Text(_saving ? l10n.saving : l10n.saveProduct),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateWholeNumber(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 0) {
      return AppLocalizations.of(context).useZeroOrMore;
    }
    return null;
  }
}

class _AreaSelector extends StatelessWidget {
  const _AreaSelector({
    required this.areas,
    required this.selectedAreaId,
    required this.onChanged,
    required this.onAddArea,
  });

  final List<Area> areas;
  final int? selectedAreaId;
  final ValueChanged<int?> onChanged;
  final VoidCallback onAddArea;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (areas.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.areaRequired,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onAddArea,
              icon: const Icon(Icons.add_location_alt_outlined),
              label: Text(l10n.addAreaFirst),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<int>(
          key: ValueKey(selectedAreaId),
          initialValue: areas.any((area) => area.id == selectedAreaId)
              ? selectedAreaId
              : null,
          decoration: InputDecoration(labelText: l10n.area),
          items: [
            for (final area in areas)
              DropdownMenuItem<int>(
                value: area.id,
                child: Text(displayAreaName(area.name, l10n)),
              ),
          ],
          onChanged: onChanged,
          validator: (value) => value == null ? l10n.areaRequired : null,
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onAddArea,
          icon: const Icon(Icons.add),
          label: Text(l10n.addArea),
        ),
      ],
    );
  }
}

class _ImagePickerButton extends StatelessWidget {
  const _ImagePickerButton({
    required this.imagePath,
    required this.onTap,
  });

  final String? imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 128,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          image: path == null
              ? null
              : DecorationImage(
                  image: FileImage(File(path)),
                  fit: BoxFit.cover,
                ),
        ),
        child: path == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).addOptionalImage,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              )
            : Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppLocalizations.of(context).change,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
