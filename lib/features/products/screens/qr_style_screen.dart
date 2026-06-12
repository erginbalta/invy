import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../l10n/app_localizations.dart';
import '../models/qr_style.dart';

class QrStyleScreen extends StatefulWidget {
  const QrStyleScreen({
    required this.code,
    required this.initialStyle,
    super.key,
  });

  final String code;
  final ProductQrStyle initialStyle;

  @override
  State<QrStyleScreen> createState() => _QrStyleScreenState();
}

class _QrStyleScreenState extends State<QrStyleScreen> {
  late ProductQrStyle _style = widget.initialStyle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.customizeQr)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            AppCard(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _style.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: QrImageView(
                    data: widget.code,
                    version: QrVersions.auto,
                    size: 190,
                    backgroundColor: _style.background,
                    eyeStyle: QrEyeStyle(
                      eyeShape: _style.rounded ? QrEyeShape.circle : QrEyeShape.square,
                      color: _style.foreground,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: _style.rounded
                          ? QrDataModuleShape.circle
                          : QrDataModuleShape.square,
                      color: _style.foreground,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _ColorSection(
              title: l10n.qrColor,
              selected: _style.foreground,
              colors: const [
                AppColors.primary,
                Colors.black,
                AppColors.success,
                AppColors.warning,
              ],
              onSelected: (color) => setState(
                () => _style = _style.copyWith(foreground: color),
              ),
            ),
            const SizedBox(height: 16),
            _ColorSection(
              title: l10n.qrBackground,
              selected: _style.background,
              colors: const [
                Colors.white,
                AppColors.background,
                AppColors.primarySoft,
              ],
              onSelected: (color) => setState(
                () => _style = _style.copyWith(background: color),
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.qrShape,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(value: false, label: Text(l10n.qrSquare)),
                      ButtonSegment(value: true, label: Text(l10n.qrRounded)),
                    ],
                    selected: {_style.rounded},
                    onSelectionChanged: (value) {
                      setState(() => _style = _style.copyWith(rounded: value.first));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(_style),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorSection extends StatelessWidget {
  const _ColorSection({
    required this.title,
    required this.selected,
    required this.colors,
    required this.onSelected,
  });

  final String title;
  final Color selected;
  final List<Color> colors;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              for (final color in colors)
                InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => onSelected(color),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected == color ? AppColors.primary : AppColors.border,
                        width: selected == color ? 3 : 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
