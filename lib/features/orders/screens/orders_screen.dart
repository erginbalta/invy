import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/inventory_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../l10n/app_localizations.dart';
import '../models/order_list.dart';
import 'order_detail_screen.dart';
import 'order_form_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  String _statusLabel(AppLocalizations l10n, OrderStatus status) {
    return switch (status) {
      OrderStatus.draft => l10n.draft,
      OrderStatus.waitingReceipt => l10n.waitingReceipt,
      OrderStatus.received => l10n.received,
    };
  }

  Color _statusColor(OrderStatus status) {
    return switch (status) {
      OrderStatus.draft => AppColors.textSecondary,
      OrderStatus.waitingReceipt => AppColors.warning,
      OrderStatus.received => AppColors.success,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<InventoryController>(
      builder: (context, controller, _) {
        final orders = controller.orders;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.orders)),
          body: SafeArea(
            child: orders.isEmpty
                ? EmptyState(
                    title: l10n.noOrdersYet,
                    message: l10n.noOrdersMessage,
                    action: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const OrderFormScreen()),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: Text(l10n.createOrder),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: controller.loadOrders,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                      itemCount: orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OrderDetailScreen(order: order),
                              ),
                            );
                          },
                          child: AppCard(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.title,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _statusLabel(l10n, order.status),
                                        style: TextStyle(
                                          color: _statusColor(order.status),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OrderFormScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: Text(l10n.newOrder),
          ),
        );
      },
    );
  }
}
