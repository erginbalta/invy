import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/inventory_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/area_display.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../settings/screens/area_management_screen.dart';
import '../../scanner/screens/scanner_screen.dart';
import '../../scanner/widgets/code_product_picker.dart';
import '../../settings/screens/settings_screen.dart';
import '../../stock_operations/screens/product_operation_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../../areas/models/area.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  Future<void> _openScanner(BuildContext context) async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
    );
    if (code == null || !context.mounted) return;
    await _handleCode(context, code);
  }

  Future<void> _handleCode(BuildContext context, String code) async {
    final product = await resolveProductForCode(
      context,
      code,
      allowCreateInArea: true,
    );
    if (!context.mounted) return;

    if (product == null) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductFormScreen(initialCode: code),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductOperationScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<InventoryController>(
      builder: (context, controller, _) {
        final products = controller.products;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.appTitle),
            actions: [
              IconButton(
                tooltip: l10n.addProduct,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProductFormScreen()),
                  );
                },
                icon: const Icon(Icons.add),
              ),
              IconButton(
                tooltip: l10n.settings,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: controller.loadProducts,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                children: [
                  _StatsRow(
                    total: controller.totalProductCount,
                    low: controller.lowStockCount,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: controller.setSearchQuery,
                    decoration: InputDecoration(
                      hintText: l10n.searchProductsOrCodes,
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilterChip(
                      selected: controller.lowStockOnly,
                      onSelected: controller.setLowStockOnly,
                      label: Text(l10n.lowStockOnly),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _AreaFilters(
                    areas: controller.areas,
                    selectedAreaId: controller.selectedAreaId,
                    onSelected: controller.setAreaFilter,
                  ),
                  const SizedBox(height: 12),
                  if (products.isEmpty)
                    EmptyState(
                      title: controller.searchQuery.isEmpty && !controller.lowStockOnly
                          ? l10n.noProductsYet
                          : l10n.nothingFound,
                      message: controller.searchQuery.isEmpty && !controller.lowStockOnly
                          ? l10n.emptyProductsMessage
                          : l10n.emptySearchMessage,
                      action: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ProductFormScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: Text(l10n.addProduct),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AreaManagementScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_location_alt_outlined),
                            label: Text(l10n.addArea),
                          ),
                        ],
                      ),
                    )
                  else
                    for (final Product product in products) ...[
                      ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(
                                productId: product.id!,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openScanner(context),
            icon: const Icon(Icons.qr_code_scanner),
            label: Text(l10n.scan),
          ),
        );
      },
    );
  }
}

class _AreaFilters extends StatelessWidget {
  const _AreaFilters({
    required this.areas,
    required this.selectedAreaId,
    required this.onSelected,
  });

  final List<Area> areas;
  final int? selectedAreaId;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            selected: selectedAreaId == null,
            onSelected: (_) => onSelected(null),
            label: Text(l10n.allAreas),
          ),
          for (final area in areas) ...[
            const SizedBox(width: 8),
            ChoiceChip(
              selected: selectedAreaId == area.id,
              onSelected: (_) => onSelected(area.id),
              label: Text(displayAreaName(area.name, l10n)),
            ),
          ],
          const SizedBox(width: 8),
          ActionChip(
            avatar: const Icon(Icons.add, size: 18),
            label: Text(l10n.addArea),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AreaManagementScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.total, required this.low});

  final int total;
  final int low;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppCard(
            child: _Stat(
              label: AppLocalizations.of(context).products,
              value: '$total',
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppCard(
            child: _Stat(
              label: AppLocalizations.of(context).lowStock,
              value: '$low',
              color: AppColors.warning,
            ),
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
