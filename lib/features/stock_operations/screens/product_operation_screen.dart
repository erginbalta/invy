import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/inventory_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/zero_number_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../products/models/product.dart';
import '../repositories/stock_movement_repository.dart';

enum OperationMode { stockIn, stockOut, adjustment }

class ProductOperationScreen extends StatefulWidget {
  const ProductOperationScreen({
    required this.product,
    this.initialMode = OperationMode.stockIn,
    super.key,
  });

  final Product product;
  final OperationMode initialMode;

  @override
  State<ProductOperationScreen> createState() => _ProductOperationScreenState();
}

class _ProductOperationScreenState extends State<ProductOperationScreen> {
  final _quantityController = TextEditingController(text: '1');
  final _noteController = TextEditingController();
  late OperationMode _mode = widget.initialMode;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final value = int.tryParse(_quantityController.text.trim());
    if (value == null || value < 0 || (_mode != OperationMode.adjustment && value == 0)) {
      setState(() => _error = l10n.enterValidQuantity);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final controller = context.read<InventoryController>();
    try {
      switch (_mode) {
        case OperationMode.stockIn:
          await controller.stockIn(
            productId: widget.product.id!,
            quantity: value,
            note: _noteController.text,
          );
          break;
        case OperationMode.stockOut:
          await controller.stockOut(
            productId: widget.product.id!,
            quantity: value,
            note: _noteController.text,
          );
          break;
        case OperationMode.adjustment:
          await controller.adjustTo(
            productId: widget.product.id!,
            newStock: value,
            note: _noteController.text,
          );
          break;
      }
      if (mounted) Navigator.of(context).pop(true);
    } on StockBelowZeroException {
      setState(() => _error = l10n.stockCannotGoBelowZero);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = _mode == OperationMode.adjustment ? l10n.newStock : l10n.quantity;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.stockOperation)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.currentStockValue(widget.product.currentStock),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 18),
                  SegmentedButton<OperationMode>(
                    segments: [
                      ButtonSegment(
                        value: OperationMode.stockIn,
                        label: Text(l10n.operationIn),
                        icon: const Icon(Icons.add),
                      ),
                      ButtonSegment(
                        value: OperationMode.stockOut,
                        label: Text(l10n.operationOut),
                        icon: const Icon(Icons.remove),
                      ),
                      ButtonSegment(
                        value: OperationMode.adjustment,
                        label: Text(l10n.operationSet),
                        icon: const Icon(Icons.tune),
                      ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _mode = selection.first;
                        if (_mode == OperationMode.adjustment) {
                          _quantityController.text = widget.product.currentStock.toString();
                        } else if (_quantityController.text == '0') {
                          _quantityController.text = '1';
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ZeroNumberField(
                    controller: _quantityController,
                    labelText: label,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _noteController,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: l10n.noteOptional,
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? l10n.saving : l10n.saveOperation),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
