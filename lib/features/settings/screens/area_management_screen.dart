import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/inventory_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/area_display.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../areas/models/area.dart';
import '../../areas/repositories/area_repository.dart';

class AreaManagementScreen extends StatelessWidget {
  const AreaManagementScreen({super.key});

  Future<void> _openAreaDialog(
    BuildContext context, {
    Area? area,
  }) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: area?.name ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(area == null ? l10n.newArea : l10n.renameArea),
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
    if (name == null || name.isEmpty || !context.mounted) return;

    if (area == null) {
      await context.read<InventoryController>().createArea(name);
    } else {
      await context.read<InventoryController>().renameArea(
            id: area.id!,
            name: name,
          );
    }
  }

  Future<void> _deleteArea(BuildContext context, Area area) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAreaTitle),
        content: Text(l10n.deleteAreaMessage(displayAreaName(area.name, l10n))),
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
    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<InventoryController>().softDeleteArea(area.id!);
    } on AreaInUseException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.areaInUseMessage),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<InventoryController>(
      builder: (context, controller, _) {
        final areas = controller.areas;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.areas),
            actions: [
              IconButton(
                tooltip: l10n.addAreaTooltip,
                onPressed: () => _openAreaDialog(context),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          body: SafeArea(
            child: areas.isEmpty
                ? EmptyState(
                    title: l10n.noAreasYet,
                    message: l10n.noAreasMessage,
                    action: ElevatedButton.icon(
                      onPressed: () => _openAreaDialog(context),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addArea),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    itemCount: areas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final area = areas[index];
                      return AppCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayAreaName(area.name, l10n),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: l10n.renameAreaTooltip,
                              onPressed: () => _openAreaDialog(
                                context,
                                area: area,
                              ),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: l10n.deleteAreaTooltip,
                              onPressed: () => _deleteArea(context, area),
                              icon: const Icon(Icons.delete_outline),
                              color: AppColors.danger,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openAreaDialog(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.area),
          ),
        );
      },
    );
  }
}
