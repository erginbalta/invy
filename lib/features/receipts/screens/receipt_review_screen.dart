import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../app/inventory_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/area_display.dart';
import '../../../core/widgets/app_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../areas/models/area.dart';
import '../../products/models/product.dart';
import '../models/receipt_review_line.dart';

class ReceiptReviewScreen extends StatefulWidget {
  const ReceiptReviewScreen({
    required this.initialLines,
    this.orderId,
    super.key,
  });

  final List<ReceiptReviewLine> initialLines;
  final int? orderId;

  @override
  State<ReceiptReviewScreen> createState() => _ReceiptReviewScreenState();
}

class _ReceiptReviewScreenState extends State<ReceiptReviewScreen> {
  late List<ReceiptReviewLine> _lines = [...widget.initialLines];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepareLines());
  }

  void _prepareLines() {
    if (!mounted) return;
    setState(() {
      _lines = _lines.map(_withDefaultAllocation).toList();
    });
  }

  ReceiptReviewLine _withDefaultAllocation(ReceiptReviewLine line) {
    final areas = context.read<InventoryController>().areas;
    if (line.allocations.isNotEmpty || areas.isEmpty) return line;
    return line.copyWith(
      allocations: [
        ReceiptAllocation(areaId: areas.first.id!, quantity: line.quantity),
      ],
    );
  }

  void _addLine() {
    final areas = context.read<InventoryController>().areas;
    setState(() {
      _lines.add(
        ReceiptReviewLine(
          name: '',
          quantity: 1,
          allocations: areas.isEmpty
              ? const []
              : [ReceiptAllocation(areaId: areas.first.id!, quantity: 1)],
        ),
      );
    });
  }

  Future<void> _openAreaDialog() async {
    final l10n = AppLocalizations.of(context);
    final textController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.newArea),
        content: TextField(
          controller: textController,
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
            onPressed: () => Navigator.of(context).pop(textController.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    textController.dispose();

    final name = result?.trim();
    if (name == null || name.isEmpty || !mounted) return;
    final area = await context.read<InventoryController>().createArea(name);
    if (!mounted) return;
    setState(() {
      _lines = _lines
          .map((line) => line.allocations.isEmpty
              ? line.copyWith(
                  allocations: [
                    ReceiptAllocation(areaId: area.id!, quantity: line.quantity),
                  ],
                )
              : line)
          .toList();
    });
  }

  void _updateLine(int index, ReceiptReviewLine line) {
    setState(() => _lines[index] = line);
  }

  void _removeLine(int index) {
    setState(() => _lines.removeAt(index));
  }

  void _splitEvenly(int index) {
    final areas = context.read<InventoryController>().areas;
    if (areas.isEmpty) return;
    final line = _lines[index];
    final selectedAreas = line.allocations.length > 1
        ? line.allocations.map((allocation) => allocation.areaId).toList()
        : areas.take(2).map((area) => area.id!).toList();
    if (selectedAreas.isEmpty) return;

    final base = line.quantity ~/ selectedAreas.length;
    var remaining = line.quantity % selectedAreas.length;
    final allocations = selectedAreas.map((areaId) {
      final extra = remaining > 0 ? 1 : 0;
      remaining -= extra;
      return ReceiptAllocation(areaId: areaId, quantity: base + extra);
    }).toList();
    _updateLine(index, line.copyWith(allocations: allocations));
  }

  Future<void> _confirm() async {
    final l10n = AppLocalizations.of(context);
    final lines = _lines.map(_withDefaultAllocation).toList();
    if (lines.isEmpty || lines.any((line) => !line.isValid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.allocatedMismatch)),
      );
      return;
    }

    setState(() => _isSaving = true);
    await context.read<InventoryController>().applyReceiptLines(
          lines: lines,
          orderId: widget.orderId,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.orderId == null ? l10n.receiptSaved : l10n.orderCompleted),
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<InventoryController>(
      builder: (context, controller, _) {
        final areas = controller.areas;
        final products = controller.activeProducts;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.receiptReview)),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
              children: [
                if (_lines.isEmpty)
                  AppCard(
                    child: Text(
                      l10n.noReceiptLines,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                for (var index = 0; index < _lines.length; index++) ...[
                  _ReceiptLineCard(
                    key: ValueKey('line-$index-${_lines[index].name}-${_lines[index].quantity}'),
                    line: _lines[index],
                    areas: areas,
                    products: products,
                    onChanged: (line) => _updateLine(index, line),
                    onRemove: () => _removeLine(index),
                    onSplitEvenly: () => _splitEvenly(index),
                    onAddArea: _openAreaDialog,
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton.icon(
                  onPressed: _addLine,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addLine),
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _confirm,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(l10n.confirmAddStock),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReceiptLineCard extends StatelessWidget {
  const _ReceiptLineCard({
    required this.line,
    required this.areas,
    required this.products,
    required this.onChanged,
    required this.onRemove,
    required this.onSplitEvenly,
    required this.onAddArea,
    super.key,
  });

  final ReceiptReviewLine line;
  final List<Area> areas;
  final List<Product> products;
  final ValueChanged<ReceiptReviewLine> onChanged;
  final VoidCallback onRemove;
  final VoidCallback onSplitEvenly;
  final VoidCallback onAddArea;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.product,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.removeLine,
                onPressed: onRemove,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: line.name,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: l10n.itemName),
            onChanged: (value) => onChanged(line.copyWith(name: value)),
          ),
          const SizedBox(height: 10),
          _InlineNumberField(
            value: line.quantity,
            label: l10n.quantity,
            onChanged: (value) {
              var next = line.copyWith(quantity: value);
              if (next.allocations.length == 1) {
                next = next.copyWith(
                  allocations: [
                    next.allocations.first.copyWith(quantity: value),
                  ],
                );
              }
              onChanged(next);
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int?>(
            initialValue: line.selectedProductId,
            decoration: InputDecoration(labelText: l10n.productMatch),
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text(l10n.newProduct),
              ),
              for (final product in products)
                DropdownMenuItem<int?>(
                  value: product.id,
                  child: Text('${product.name} - ${displayAreaName(product.areaName, l10n)}'),
                ),
            ],
            onChanged: (value) {
              onChanged(
                line.copyWith(
                  selectedProductId: value,
                  clearSelectedProduct: value == null,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.distributeToAreas,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: onSplitEvenly,
                child: Text(l10n.splitEvenly),
              ),
            ],
          ),
          for (var index = 0; index < line.allocations.length; index++) ...[
            _AllocationRow(
              allocation: line.allocations[index],
              areas: areas,
              onChanged: (allocation) {
                final next = [...line.allocations];
                next[index] = allocation;
                onChanged(line.copyWith(allocations: next));
              },
              onRemove: line.allocations.length == 1
                  ? null
                  : () {
                      final next = [...line.allocations]..removeAt(index);
                      onChanged(line.copyWith(allocations: next));
                    },
            ),
            const SizedBox(height: 8),
          ],
          OutlinedButton.icon(
            onPressed: areas.isEmpty
                ? onAddArea
                : () {
                    final used = line.allocations.map((item) => item.areaId).toSet();
                    final area = areas.firstWhere(
                      (area) => !used.contains(area.id),
                      orElse: () => areas.first,
                    );
                    onChanged(
                      line.copyWith(
                        allocations: [
                          ...line.allocations,
                          ReceiptAllocation(areaId: area.id!, quantity: 1),
                        ],
                      ),
                    );
                  },
            icon: const Icon(Icons.add),
            label: Text(areas.isEmpty ? l10n.addAreaFirst : l10n.addArea),
          ),
          if (!line.isValid)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.allocatedMismatch,
                style: const TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AllocationRow extends StatelessWidget {
  const _AllocationRow({
    required this.allocation,
    required this.areas,
    required this.onChanged,
    this.onRemove,
  });

  final ReceiptAllocation allocation;
  final List<Area> areas;
  final ValueChanged<ReceiptAllocation> onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<int>(
            initialValue: areas.any((area) => area.id == allocation.areaId)
                ? allocation.areaId
                : null,
            decoration: InputDecoration(labelText: l10n.area),
            items: [
              for (final area in areas)
                DropdownMenuItem<int>(
                  value: area.id,
                  child: Text(displayAreaName(area.name, l10n)),
                ),
            ],
            onChanged: (value) {
              if (value == null) return;
              onChanged(allocation.copyWith(areaId: value));
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _InlineNumberField(
            value: allocation.quantity,
            label: l10n.quantity,
            onChanged: (value) => onChanged(allocation.copyWith(quantity: value)),
          ),
        ),
        IconButton(
          tooltip: l10n.removeLine,
          onPressed: onRemove,
          icon: const Icon(Icons.remove_circle_outline),
          color: AppColors.danger,
        ),
      ],
    );
  }
}

class _InlineNumberField extends StatefulWidget {
  const _InlineNumberField({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final int value;
  final String label;
  final ValueChanged<int> onChanged;

  @override
  State<_InlineNumberField> createState() => _InlineNumberFieldState();
}

class _InlineNumberFieldState extends State<_InlineNumberField> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode.addListener(_handleFocus);
  }

  @override
  void didUpdateWidget(covariant _InlineNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && oldWidget.value != widget.value) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocus() {
    if (_focusNode.hasFocus && _controller.text.trim() == '0') {
      _controller.clear();
      return;
    }
    if (!_focusNode.hasFocus && _controller.text.trim().isEmpty) {
      _controller.text = '0';
      widget.onChanged(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(labelText: widget.label),
      onChanged: (value) => widget.onChanged(int.tryParse(value) ?? 0),
    );
  }
}
