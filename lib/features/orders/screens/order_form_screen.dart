import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../app/inventory_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../scanner/screens/scanner_screen.dart';
import '../../scanner/widgets/code_product_picker.dart';
import '../models/order_item.dart';

class OrderFormScreen extends StatefulWidget {
  const OrderFormScreen({super.key});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _titleController = TextEditingController();
  final _items = <DraftOrderItem>[];
  String? _titleError;
  String? _itemsError;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _scanItem() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
    );
    if (code == null || !mounted) return;

    final product = await resolveProductForCode(context, code);
    if (!mounted) return;
    if (product == null) {
      await _openManualDialog(initialCode: code);
      return;
    }
    setState(() {
      _items.add(
        DraftOrderItem(
          productId: product.id,
          name: product.name,
          code: product.code,
          quantity: 1,
        ),
      );
      _itemsError = null;
    });
  }

  Future<void> _openManualDialog({String? initialCode}) async {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final result = await showDialog<DraftOrderItem>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.manualItem),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: l10n.itemName),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: l10n.quantity),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
                if (name.isEmpty || quantity <= 0) return;
                Navigator.of(context).pop(
                  DraftOrderItem(
                    name: name,
                    code: initialCode,
                    quantity: quantity,
                  ),
                );
              },
              child: Text(l10n.addOrderItem),
            ),
          ],
        );
      },
    );
    nameController.dispose();
    quantityController.dispose();

    if (result == null) return;
    setState(() {
      _items.add(result);
      _itemsError = null;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final title = _titleController.text.trim();
    setState(() {
      _titleError = title.isEmpty ? l10n.enterOrderTitle : null;
      _itemsError = _items.isEmpty ? l10n.noOrderItems : null;
    });
    if (_titleError != null || _itemsError != null) return;

    setState(() => _isSaving = true);
    await context.read<InventoryController>().createOrder(
          title: title,
          items: _items,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.orderSaved)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.newOrder)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
          children: [
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.orderTitle,
                errorText: _titleError,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.orderItems,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.scan,
                  onPressed: _scanItem,
                  icon: const Icon(Icons.qr_code_scanner),
                ),
                IconButton(
                  tooltip: l10n.addOrderItem,
                  onPressed: _openManualDialog,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            if (_itemsError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _itemsError!,
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            for (var index = 0; index < _items.length; index++) ...[
              _DraftItemTile(
                item: _items[index],
                onRemove: () => setState(() => _items.removeAt(index)),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _scanItem,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: Text(l10n.scan),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openManualDialog,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.manualItem),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(l10n.saveOrder),
          ),
        ),
      ),
    );
  }
}

class _DraftItemTile extends StatelessWidget {
  const _DraftItemTile({
    required this.item,
    required this.onRemove,
  });

  final DraftOrderItem item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppLocalizations.of(context).quantity}: ${item.quantity}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
            color: AppColors.danger,
          ),
        ],
      ),
    );
  }
}
