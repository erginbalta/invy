import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../l10n/app_localizations.dart';
import '../models/receipt_review_line.dart';
import '../services/receipt_parser.dart';
import '../services/receipt_scan_service.dart';
import 'receipt_review_screen.dart';

class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({
    this.orderId,
    super.key,
  });

  final int? orderId;

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final _scanService = ReceiptScanService();
  final _parser = const ReceiptParser();
  bool _isReading = false;

  Future<void> _pickAndRead(
    ImageSource source,
    ReceiptDocumentType type,
  ) async {
    setState(() => _isReading = true);
    try {
      final text = await _scanService.scanFrom(source);
      if (!mounted || text == null) return;

      final lines = _parser.parse(text, type: type);
      if (lines.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).receiptReadFailed)),
        );
      }
      await _openReview(lines);
    } finally {
      if (mounted) setState(() => _isReading = false);
    }
  }

  Future<void> _chooseSource(ReceiptDocumentType type) async {
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(l10n.camera),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(l10n.gallery),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (source != null) await _pickAndRead(source, type);
  }

  Future<void> _openReview(List<ReceiptReviewLine> lines) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ReceiptReviewScreen(
          initialLines: lines,
          orderId: widget.orderId,
        ),
      ),
    );
    if (saved == true && mounted && widget.orderId != null) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.receiptInvoice)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _DocumentSourceCard(
              title: l10n.chooseReceiptSource,
              buttonLabel: l10n.scanReceipt,
              icon: Icons.receipt_long_outlined,
              isReading: _isReading,
              onScan: () => _chooseSource(ReceiptDocumentType.receipt),
            ),
            const SizedBox(height: 14),
            _DocumentSourceCard(
              title: l10n.chooseInvoiceSource,
              buttonLabel: l10n.scanInvoice,
              icon: Icons.description_outlined,
              isReading: _isReading,
              onScan: () => _chooseSource(ReceiptDocumentType.invoice),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.noReceiptLines,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isReading ? null : () => _openReview(const []),
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(l10n.addLine),
                    ),
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

class _DocumentSourceCard extends StatelessWidget {
  const _DocumentSourceCard({
    required this.title,
    required this.buttonLabel,
    required this.icon,
    required this.isReading,
    required this.onScan,
  });

  final String title;
  final String buttonLabel;
  final IconData icon;
  final bool isReading;
  final VoidCallback onScan;

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
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isReading ? null : onScan,
              icon: isReading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(icon),
              label: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}
