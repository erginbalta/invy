import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/inventory_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/area_display.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/zero_number_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../scanner/screens/scanner_screen.dart';
import '../../stock_operations/models/stock_movement.dart';
import '../../stock_operations/repositories/stock_movement_repository.dart';
import '../../stock_operations/screens/product_operation_screen.dart';
import '../models/product.dart';
import '../models/qr_style.dart';
import '../repositories/product_repository.dart';
import 'product_form_screen.dart';
import 'qr_style_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    required this.productId,
    super.key,
  });

  final int productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductQrStyle _qrStyle = const ProductQrStyle(
    foreground: AppColors.primary,
    background: Colors.white,
    rounded: false,
  );

  Future<void> _openOperation(Product product, OperationMode mode) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProductOperationScreen(
          product: product,
          initialMode: mode,
        ),
      ),
    );
    if (changed == true && mounted) setState(() {});
  }

  Future<void> _openTransfer(Product product, List<Product> variants) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _TransferStockSheet(
        product: product,
        variants: variants,
      ),
    );
    if (changed == true && mounted) setState(() {});
  }

  Future<void> _customizeQr(Product product) async {
    final style = await Navigator.of(context).push<ProductQrStyle>(
      MaterialPageRoute(
        builder: (_) => QrStyleScreen(
          code: product.code,
          initialStyle: _qrStyle,
        ),
      ),
    );
    if (style != null && mounted) {
      setState(() => _qrStyle = style);
    }
  }

  Future<void> _downloadQr(Product product) async {
    final l10n = AppLocalizations.of(context);
    final bytes = await _buildQrPng(product);
    final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final safeCode = product.code.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final file = File('${directory.path}/invy_qr_$safeCode.png');
    await file.writeAsBytes(bytes);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.qrSaved(file.path))),
    );
  }

  Future<void> _addBarcode(Product product) async {
    final l10n = AppLocalizations.of(context);
    final code = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.qr_code_scanner),
                  title: Text(l10n.scanBarcode),
                  onTap: () async {
                    final scanned = await Navigator.of(context).push<String>(
                      MaterialPageRoute(builder: (_) => const ScannerScreen()),
                    );
                    if (context.mounted) Navigator.of(context).pop(scanned);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.edit_outlined),
                  title: Text(l10n.enterBarcode),
                  onTap: () async {
                    final manual = await _manualBarcodeDialog(context);
                    if (context.mounted) Navigator.of(context).pop(manual);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    final cleaned = code?.trim();
    if (cleaned == null || cleaned.isEmpty || !mounted) return;

    try {
      await context.read<InventoryController>().updateProductCode(
            productId: product.id!,
            code: cleaned,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.barcodeAdded)),
      );
      setState(() {});
    } on DuplicateCodeException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.codeAlreadyUsedInArea)),
      );
    }
  }

  Future<String?> _manualBarcodeDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.enterBarcode),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.barcodeOrCode,
          ),
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
    return result;
  }

  Future<List<int>> _buildQrPng(Product product) async {
    const width = 720.0;
    const height = 840.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = _qrStyle.background;
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), paint);

    final qrPainter = QrPainter(
      data: product.code,
      version: QrVersions.auto,
      gapless: true,
      eyeStyle: QrEyeStyle(
        eyeShape: _qrStyle.rounded ? QrEyeShape.circle : QrEyeShape.square,
        color: _qrStyle.foreground,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape:
            _qrStyle.rounded ? QrDataModuleShape.circle : QrDataModuleShape.square,
        color: _qrStyle.foreground,
      ),
    );
    final textPainter = TextPainter(
      text: TextSpan(
        text: product.code,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 42,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: width - 80);

    canvas.translate(100, 70);
    qrPainter.paint(canvas, const Size(520, 520));
    canvas.translate(-100, -70);
    textPainter.paint(canvas, Offset((width - textPainter.width) / 2, 650));

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _confirmDelete(Product product) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteProductTitle),
        content: Text(l10n.deleteProductMessage(product.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.delete,
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<InventoryController>().softDeleteProduct(product.id!);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<InventoryController>(
      builder: (context, controller, _) {
        final product = controller.productById(widget.productId);
        if (product == null) {
          return Scaffold(
            body: EmptyState(
              title: l10n.productNotFound,
              message: l10n.productNotFoundMessage,
            ),
          );
        }

        final variants = controller.variantsFor(product);
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.product),
            actions: [
              IconButton(
                tooltip: l10n.editProductTooltip,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductFormScreen(product: product),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: l10n.deleteProductTooltip,
                onPressed: () => _confirmDelete(product),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProductImage(product: product),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.code,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.isAggregate
                                  ? l10n.areaCount(product.aggregateProductIds.length)
                                  : displayAreaName(product.areaName, l10n),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                _StockValue(
                                  label: l10n.current,
                                  value: product.currentStock,
                                  color: product.isLowStock
                                      ? AppColors.warning
                                      : AppColors.primary,
                                ),
                                const SizedBox(width: 12),
                                _StockValue(
                                  label: l10n.minimum,
                                  value: product.minimumStock,
                                  color: AppColors.textPrimary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            if (!product.isAggregate) ...[
                              if (product.code.startsWith('INVY-')) ...[
                                OutlinedButton.icon(
                                  onPressed: () => _addBarcode(product),
                                  icon: const Icon(Icons.qr_code_scanner),
                                  label: Text(l10n.addBarcode),
                                ),
                                const SizedBox(height: 12),
                              ],
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _openOperation(
                                        product,
                                        OperationMode.stockIn,
                                      ),
                                      icon: const Icon(Icons.add),
                                      label: Text(l10n.stockIn),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _openOperation(
                                        product,
                                        OperationMode.stockOut,
                                      ),
                                      icon: const Icon(Icons.remove),
                                      label: Text(l10n.stockOut),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () => _openOperation(
                                  product,
                                  OperationMode.adjustment,
                                ),
                                icon: const Icon(Icons.tune),
                                label: Text(l10n.setStockCount),
                              ),
                            ],
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () => _openTransfer(product, variants),
                              icon: const Icon(Icons.compare_arrows),
                              label: Text(l10n.transferStock),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (product.isAggregate) ...[
                  const SizedBox(height: 16),
                  _AreaBreakdown(variants: variants),
                ],
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.qrCode,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: QrImageView(
                            data: product.code,
                            version: QrVersions.auto,
                            size: 180,
                            backgroundColor: _qrStyle.background,
                            eyeStyle: QrEyeStyle(
                              eyeShape: _qrStyle.rounded
                                  ? QrEyeShape.circle
                                  : QrEyeShape.square,
                              color: _qrStyle.foreground,
                            ),
                            dataModuleStyle: QrDataModuleStyle(
                              dataModuleShape: _qrStyle.rounded
                                  ? QrDataModuleShape.circle
                                  : QrDataModuleShape.square,
                              color: _qrStyle.foreground,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _customizeQr(product),
                              icon: const Icon(Icons.palette_outlined),
                              label: Text(l10n.customizeQr),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _downloadQr(product),
                              icon: const Icon(Icons.download),
                              label: Text(l10n.downloadQr),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _MovementHistory(productId: product.id!),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TransferStockSheet extends StatefulWidget {
  const _TransferStockSheet({
    required this.product,
    required this.variants,
  });

  final Product product;
  final List<Product> variants;

  @override
  State<_TransferStockSheet> createState() => _TransferStockSheetState();
}

class _TransferStockSheetState extends State<_TransferStockSheet> {
  final _quantityController = TextEditingController(text: '1');
  int? _sourceProductId;
  int? _targetAreaId;
  bool _moveAll = false;
  bool _saving = false;
  String? _error;

  bool get _isAggregate => widget.product.isAggregate;

  @override
  void initState() {
    super.initState();
    _sourceProductId = _isAggregate ? null : widget.product.id;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Product? _sourceProduct() {
    final id = _sourceProductId;
    if (id == null) return null;
    for (final product in widget.variants) {
      if (product.id == id) return product;
    }
    return widget.product.id == id ? widget.product : null;
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
    setState(() => _targetAreaId = area.id);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final source = _sourceProduct();
    final targetAreaId = _targetAreaId;
    if (source == null || targetAreaId == null) {
      setState(() => _error = l10n.areaRequired);
      return;
    }
    if (source.areaId == targetAreaId) {
      setState(() => _error = l10n.sameAreaTransferMessage);
      return;
    }

    final quantity = _moveAll
        ? source.currentStock
        : int.tryParse(_quantityController.text.trim()) ?? 0;
    if (quantity <= 0) {
      setState(() => _error = l10n.enterValidQuantity);
      return;
    }
    if (quantity > source.currentStock) {
      setState(() => _error = l10n.notEnoughStockMessage);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await context.read<InventoryController>().transferStock(
            source: source,
            targetAreaId: targetAreaId,
            quantity: quantity,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transferSaved)),
      );
      Navigator.of(context).pop(true);
    } on StockBelowZeroException {
      if (mounted) setState(() => _error = l10n.stockCannotGoBelowZero);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<InventoryController>();
    final source = _sourceProduct();
    final areas = controller.areas;
    final targetAreas = areas.where((area) => area.id != source?.areaId).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.transferStock,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 14),
              if (_isAggregate) ...[
                DropdownButtonFormField<int>(
                  initialValue: _sourceProductId,
                  decoration: InputDecoration(labelText: l10n.fromArea),
                  items: [
                    for (final product in widget.variants)
                      DropdownMenuItem<int>(
                        value: product.id,
                        child: Text(
                          '${displayAreaName(product.areaName, l10n)} · ${product.currentStock}',
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sourceProductId = value;
                      _targetAreaId = null;
                    });
                  },
                ),
                const SizedBox(height: 12),
              ],
              Text(
                l10n.availableStock(source?.currentStock ?? 0),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: targetAreas.any((area) => area.id == _targetAreaId)
                    ? _targetAreaId
                    : null,
                decoration: InputDecoration(labelText: l10n.toArea),
                items: [
                  for (final area in targetAreas)
                    DropdownMenuItem<int>(
                      value: area.id,
                      child: Text(displayAreaName(area.name, l10n)),
                    ),
                ],
                onChanged: (value) => setState(() => _targetAreaId = value),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _openAreaDialog,
                icon: const Icon(Icons.add),
                label: Text(l10n.addArea),
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _moveAll,
                onChanged: (value) => setState(() => _moveAll = value ?? false),
                title: Text(l10n.moveAll),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              if (!_moveAll) ...[
                const SizedBox(height: 6),
                ZeroNumberField(
                  controller: _quantityController,
                  labelText: l10n.quantity,
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.compare_arrows),
                label: Text(l10n.move),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AreaBreakdown extends StatelessWidget {
  const _AreaBreakdown({required this.variants});

  final List<Product> variants;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.areaBreakdown,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 12),
          for (final product in variants) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    displayAreaName(product.areaName, l10n),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${product.currentStock}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            if (product != variants.last)
              const Divider(height: 22, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final path = product.imagePath;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: Container(
        height: 180,
        width: double.infinity,
        color: AppColors.primarySoft,
        child: path == null
            ? Center(
                child: Text(
                  product.name.trim()[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 48,
                  ),
                ),
              )
            : Image.file(File(path), fit: BoxFit.cover),
      ),
    );
  }
}

class _StockValue extends StatelessWidget {
  const _StockValue({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
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
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovementHistory extends StatelessWidget {
  const _MovementHistory({required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<InventoryController>();
    return AppCard(
      child: FutureBuilder<List<StockMovement>>(
        future: controller.movementsFor(productId),
        builder: (context, snapshot) {
          final movements = snapshot.data ?? [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).movementHistory,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 12),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else if (movements.isEmpty)
                Text(
                  AppLocalizations.of(context).noStockMovementsYet,
                  style: const TextStyle(color: AppColors.textSecondary),
                )
              else
                for (final movement in movements) _MovementTile(movement: movement),
            ],
          );
        },
      ),
    );
  }
}

class _MovementTile extends StatelessWidget {
  const _MovementTile({required this.movement});

  final StockMovement movement;

  @override
  Widget build(BuildContext context) {
    final color = switch (movement.type) {
      StockMovementType.stockIn => AppColors.success,
      StockMovementType.stockOut => AppColors.danger,
      StockMovementType.adjustment => AppColors.warning,
    };
    final l10n = AppLocalizations.of(context);
    final label = switch (movement.type) {
      StockMovementType.stockIn => l10n.stockIn,
      StockMovementType.stockOut => l10n.stockOut,
      StockMovementType.adjustment => l10n.adjustment,
    };

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  l10n.movementRange(
                    movement.previousStock,
                    movement.newStock,
                    _formatDate(movement.createdAt),
                  ),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (movement.note != null)
                  Text(
                    movement.note!,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          Text(
            '${movement.quantity}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(local.day)}.${two(local.month)}.${local.year} ${two(local.hour)}:${two(local.minute)}';
  }
}
