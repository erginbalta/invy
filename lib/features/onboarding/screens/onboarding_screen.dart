import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/inventory_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../l10n/app_localizations.dart';

enum UsageChoice { personal, business }

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _businessNameController = TextEditingController();
  UsageChoice _choice = UsageChoice.personal;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _businessNameController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final l10n = AppLocalizations.of(context);
    final businessName = _businessNameController.text.trim();
    if (_choice == UsageChoice.business && businessName.isEmpty) {
      setState(() => _error = l10n.businessNameRequired);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    await context.read<InventoryController>().completeOnboarding(
          usageType: _choice == UsageChoice.personal ? 'personal' : 'business',
          businessName: _choice == UsageChoice.business ? businessName : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.08),
            Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.appTitle,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.onboardingTagline,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
              ),
              const SizedBox(height: 28),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.onboardingQuestion,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _UsageTile(
                      title: l10n.personal,
                      subtitle: l10n.personalSubtitle,
                      selected: _choice == UsageChoice.personal,
                      onTap: () => setState(() => _choice = UsageChoice.personal),
                    ),
                    const SizedBox(height: 12),
                    _UsageTile(
                      title: l10n.business,
                      subtitle: l10n.businessSubtitle,
                      selected: _choice == UsageChoice.business,
                      onTap: () => setState(() => _choice = UsageChoice.business),
                    ),
                    if (_choice == UsageChoice.business) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _businessNameController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: l10n.businessName,
                          hintText: l10n.businessNameHint,
                        ),
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(color: AppColors.danger),
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saving ? null : _continue,
                      child: Text(_saving ? l10n.saving : l10n.continueAction),
                    ),
                  ],
                ),
              ),
            ],
          ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.08),
          ],
        ),
      ),
    );
  }
}

class _UsageTile extends StatelessWidget {
  const _UsageTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.textSecondary),
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
