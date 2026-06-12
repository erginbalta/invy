import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/inventory_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../receipts/screens/receipt_screen.dart';
import '../models/order_item.dart';
import '../models/order_list.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({
    required this.order,
    super.key,
  });

  final OrderList order;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Future<List<OrderItem>> _itemsFuture;
  late OrderStatus _status;

  @override
  void initState() {
    super.initState();
    _status = widget.order.status;
    _itemsFuture = context.read<InventoryController>().orderItemsFor(widget.order.id!);
  }

  String _statusLabel(AppLocalizations l10n, OrderStatus status) {
    return switch (status) {
      OrderStatus.draft => l10n.draft,
      OrderStatus.waitingReceipt => l10n.waitingReceipt,
      OrderStatus.received => l10n.received,
    };
  }

  Future<void> _addReceipt() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ReceiptScreen(orderId: widget.order.id),
      ),
    );
    if (saved == true && mounted) {
      await context.read<InventoryController>().loadOrders();
      setState(() {
        _status = OrderStatus.received;
        _itemsFuture = context.read<InventoryController>().orderItemsFor(widget.order.id!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.order.title)),
      body: SafeArea(
        child: FutureBuilder<List<OrderItem>>(
          future: _itemsFuture,
          builder: (context, snapshot) {
            final items = snapshot.data ?? const <OrderItem>[];
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
              children: [
                AppCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.status,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        _statusLabel(l10n, _status),
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  EmptyState(
                    title: l10n.orderItems,
                    message: l10n.noOrderItems,
                  )
                else
                  for (final item in items) ...[
                    AppCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _status == OrderStatus.received
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: ElevatedButton.icon(
                  onPressed: _addReceipt,
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: Text(l10n.addReceiptToOrder),
                ),
              ),
            ),
    );
  }
}
