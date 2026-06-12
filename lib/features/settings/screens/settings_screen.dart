import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/inventory_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../onboarding/data/settings_repository.dart';
import 'area_management_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _changeUsageType(
    BuildContext context,
    String usageType,
    LocalSetup setup,
  ) async {
    if (usageType == 'personal') {
      await context.read<InventoryController>().updateUsageType(usageType: 'personal');
      return;
    }

    final businessName = await _askBusinessName(context, setup.businessName);
    if (businessName == null || !context.mounted) return;
    if (businessName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).businessNameRequired),
        ),
      );
      return;
    }

    await context.read<InventoryController>().updateUsageType(
      usageType: 'business',
      businessName: businessName.trim(),
    );
  }

  Future<String?> _askBusinessName(
    BuildContext context,
    String? currentName,
  ) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: currentName ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.businessName),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.businessName,
            hintText: l10n.businessNameHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _confirmReset(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetLocalDataTitle),
        content: Text(l10n.resetLocalDataMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.reset,
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await context.read<InventoryController>().resetLocalData();
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<InventoryController>(
      builder: (context, controller, _) {
        final setup = controller.setup;
        final usageType = _normalizedUsageType(setup.usageType);
        return Scaffold(
          appBar: AppBar(title: Text(l10n.settings)),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SettingRow(
                        label: l10n.usageType,
                        value: _usageTypeLabel(usageType, l10n),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        key: ValueKey(usageType),
                        initialValue: usageType,
                        decoration: InputDecoration(labelText: l10n.usageType),
                        items: [
                          DropdownMenuItem(
                            value: 'personal',
                            child: Text(l10n.personal),
                          ),
                          DropdownMenuItem(
                            value: 'business',
                            child: Text(l10n.business),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null && value != usageType) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (context.mounted) {
                                _changeUsageType(context, value, setup);
                              }
                            });
                          }
                        },
                      ),
                      if ((setup.businessName ?? '').isNotEmpty) ...[
                        const Divider(height: 28, color: AppColors.border),
                        _SettingRow(
                          label: l10n.businessNameSetting,
                          value: setup.businessName!,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    children: [
                      _SettingRow(
                        label: l10n.language,
                        value: _languagePreferenceLabel(
                          controller.languagePreference,
                          l10n,
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        key: ValueKey(controller.languagePreference),
                        initialValue: controller.languagePreference,
                        decoration: InputDecoration(labelText: l10n.language),
                        items: [
                          DropdownMenuItem(
                            value: 'system',
                            child: Text(l10n.languageSystem),
                          ),
                          DropdownMenuItem(
                            value: 'tr',
                            child: Text(l10n.languageTurkish),
                          ),
                          DropdownMenuItem(
                            value: 'en',
                            child: Text(l10n.languageEnglish),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            controller.setLanguagePreference(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l10n.areas,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      subtitle: Text(
                        l10n.areasSubtitle,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AreaManagementScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.localData,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.localDataMessage,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => _confirmReset(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                        ),
                        child: Text(l10n.resetLocalData),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _usageTypeLabel(String? usageType, AppLocalizations l10n) {
    return switch (usageType) {
      'personal' || 'Personal' => l10n.personal,
      'business' || 'Business' => l10n.business,
      _ => l10n.notSet,
    };
  }

  String _normalizedUsageType(String? usageType) {
    return switch (usageType) {
      'business' || 'Business' => 'business',
      _ => 'personal',
    };
  }

  String _languagePreferenceLabel(String value, AppLocalizations l10n) {
    return switch (value) {
      'tr' => l10n.languageTurkish,
      'en' => l10n.languageEnglish,
      _ => l10n.languageSystem,
    };
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
