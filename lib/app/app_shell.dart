import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/orders/screens/orders_screen.dart';
import '../features/products/screens/product_list_screen.dart';
import '../features/receipts/screens/receipt_screen.dart';
import '../features/settings/screens/area_management_screen.dart';
import '../l10n/app_localizations.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          AreaManagementScreen(),
          ProductListScreen(),
          DashboardScreen(),
          ReceiptScreen(),
          OrdersScreen(),
        ],
      ),
      bottomNavigationBar: _PremiumNavBar(
        selectedIndex: _index,
        onSelected: (value) => setState(() => _index = value),
      ),
    );
  }
}

class _PremiumNavBar extends StatelessWidget {
  const _PremiumNavBar({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 88,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Positioned.fill(
              top: 16,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(color: AppColors.border),
                  ),
                ),
                child: Row(
                  children: [
                    _NavItem(
                      index: 0,
                      selectedIndex: selectedIndex,
                      icon: Icons.location_on_outlined,
                      selectedIcon: Icons.location_on,
                      label: l10n.areas,
                      onSelected: onSelected,
                    ),
                    _NavItem(
                      index: 1,
                      selectedIndex: selectedIndex,
                      icon: Icons.inventory_2_outlined,
                      selectedIcon: Icons.inventory_2,
                      label: l10n.products,
                      onSelected: onSelected,
                    ),
                    const SizedBox(width: 82),
                    _NavItem(
                      index: 3,
                      selectedIndex: selectedIndex,
                      icon: Icons.receipt_long_outlined,
                      selectedIcon: Icons.receipt_long,
                      label: l10n.receiptInvoice,
                      onSelected: onSelected,
                    ),
                    _NavItem(
                      index: 4,
                      selectedIndex: selectedIndex,
                      icon: Icons.list_alt_outlined,
                      selectedIcon: Icons.list_alt,
                      label: l10n.orders,
                      onSelected: onSelected,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -8,
              child: _HomeNavButton(
                selected: selectedIndex == 2,
                onTap: () => onSelected(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onSelected,
  });

  final int index;
  final int selectedIndex;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = index == selectedIndex;
    return Expanded(
      child: InkWell(
        onTap: () => onSelected(index),
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? selectedIcon : icon,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeNavButton extends StatelessWidget {
  const _HomeNavButton({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              selected ? Icons.home : Icons.home_outlined,
              color: selected ? Colors.white : AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.home,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
