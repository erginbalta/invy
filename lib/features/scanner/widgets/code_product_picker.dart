import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/inventory_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/area_display.dart';
import '../../../l10n/app_localizations.dart';
import '../../products/models/product.dart';

class _CodePickResult {
  const _CodePickResult.product(this.product)
      : areaId = null,
        createInArea = false;

  const _CodePickResult.area(this.areaId)
      : product = null,
        createInArea = true;

  final Product? product;
  final int? areaId;
  final bool createInArea;
}

Future<Product?> resolveProductForCode(
  BuildContext context,
  String code, {
  bool allowCreateInArea = false,
}) async {
  final controller = context.read<InventoryController>();
  final matches = await controller.findAllByCode(code);
  if (matches.isEmpty || !context.mounted) return null;

  final usedAreaIds = matches.map((product) => product.areaId).toSet();
  final availableAreas = controller.areas
      .where((area) => !usedAreaIds.contains(area.id))
      .toList();

  if (matches.length == 1 && (!allowCreateInArea || availableAreas.isEmpty)) {
    return matches.first;
  }

  final l10n = AppLocalizations.of(context);
  final result = await showModalBottomSheet<_CodePickResult>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          children: [
            Text(
              l10n.chooseAreaForCode,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            for (final product in matches)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(product.name),
                subtitle: Text(
                  '${displayAreaName(product.areaName, l10n)} · ${product.currentStock}',
                ),
                onTap: () => Navigator.of(context).pop(
                  _CodePickResult.product(product),
                ),
              ),
            if (allowCreateInArea)
              for (final area in availableAreas)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.add_location_alt_outlined),
                  title: Text(l10n.createInArea),
                  subtitle: Text(displayAreaName(area.name, l10n)),
                  onTap: () => Navigator.of(context).pop(
                    _CodePickResult.area(area.id),
                  ),
                ),
          ],
        ),
      );
    },
  );

  if (result == null || !context.mounted) return null;
  if (!result.createInArea) return result.product;

  return controller.copyProductToArea(
    source: matches.first,
    areaId: result.areaId!,
  );
}
