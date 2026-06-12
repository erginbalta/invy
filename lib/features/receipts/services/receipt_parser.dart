import '../models/receipt_review_line.dart';

enum ReceiptDocumentType { receipt, invoice }

class ReceiptParser {
  const ReceiptParser();

  List<ReceiptReviewLine> parse(
    String text, {
    required ReceiptDocumentType type,
  }) {
    final sourceLines = text
        .split(RegExp(r'\r?\n'))
        .map(_cleanLine)
        .whereType<String>()
        .toList();
    final startIndex = switch (type) {
      ReceiptDocumentType.receipt => _receiptStartIndex(sourceLines),
      ReceiptDocumentType.invoice => _invoiceStartIndex(sourceLines),
    };
    if (startIndex == -1) return const [];

    final grouped = <String, ReceiptReviewLine>{};
    for (final cleaned in sourceLines.skip(startIndex)) {
      if (_isSeparator(cleaned)) continue;
      if (_looksLikeMetadata(cleaned)) continue;
      if (!_looksLikeProductLine(cleaned, allowBareName: true, type: type)) {
        continue;
      }

      final quantity = _quantityFor(cleaned);
      final name = _nameFor(cleaned);
      final key = _normalizeName(name);
      if (name.length < 2 || key.length < 2 || _looksLikeMetadata(name)) {
        continue;
      }

      final existing = grouped[key];
      grouped[key] = existing == null
          ? ReceiptReviewLine(name: name, quantity: quantity)
          : existing.copyWith(quantity: existing.quantity + quantity);
    }

    return grouped.values.toList();
  }

  int _receiptStartIndex(List<String> lines) {
    for (var index = 0; index < lines.length; index++) {
      if (!_isSeparator(lines[index])) continue;
      final next = _firstProductAfter(lines, index + 1, ReceiptDocumentType.receipt);
      if (next != -1) return next;
    }
    return _clusterStartIndex(lines, ReceiptDocumentType.receipt);
  }

  int _invoiceStartIndex(List<String> lines) {
    for (var index = 0; index < lines.length; index++) {
      if (!_looksLikeInvoiceHeader(lines[index])) continue;
      final next = _firstProductAfter(lines, index + 1, ReceiptDocumentType.invoice);
      if (next != -1) return next;
    }
    return _clusterStartIndex(lines, ReceiptDocumentType.invoice);
  }

  int _firstProductAfter(
    List<String> lines,
    int start,
    ReceiptDocumentType type,
  ) {
    final end = (start + 12).clamp(0, lines.length);
    for (var index = start; index < end; index++) {
      if (_looksLikeProductLine(lines[index], allowBareName: true, type: type)) {
        return index;
      }
    }
    return -1;
  }

  int _clusterStartIndex(List<String> lines, ReceiptDocumentType type) {
    for (var index = 0; index < lines.length; index++) {
      if (!_looksLikeProductLine(lines[index], allowBareName: true, type: type)) {
        continue;
      }

      final windowEnd = (index + 6).clamp(0, lines.length);
      final signals = lines
          .sublist(index, windowEnd)
          .where((line) => _looksLikeProductLine(line, allowBareName: true, type: type))
          .length;
      if (signals >= 2) return index;
    }
    return -1;
  }

  String? _cleanLine(String value) {
    final trimmed = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (trimmed.isEmpty || trimmed.length < 3) return null;
    if (_isSeparator(trimmed)) return trimmed;
    if (!_hasLetter(trimmed)) return null;
    return trimmed;
  }

  int _quantityFor(String line) {
    final patterns = [
      RegExp(r'(?:x|X|\*)\s*(\d{1,4})'),
      RegExp(r'(\d{1,4})\s*(?:adet|AD|ad|pcs|piece|qty)\b', caseSensitive: false),
      RegExp(r'\b(\d{1,4})\s*x\b', caseSensitive: false),
      RegExp(r'\b(\d{1,4})[,.]000\b'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(line);
      final value = int.tryParse(match?.group(1) ?? '');
      if (value != null && value > 0) return value;
    }

    return 1;
  }

  String _nameFor(String line) {
    var name = line;
    name = name.replaceAll(RegExp(r'(?:x|X|\*)\s*\d{1,4}'), ' ');
    name = name.replaceAll(
      RegExp(r'\b\d{1,4}\s*(?:adet|AD|ad|pcs|piece|qty)\b', caseSensitive: false),
      ' ',
    );
    name = name.replaceAll(RegExp(r'\b\d{1,4}\s*x\b', caseSensitive: false), ' ');
    name = name.replaceAll(RegExp(r'\b\d{1,4}[,.]000\b'), ' ');
    name = name.replaceAll(RegExp(r'%\s*\d{1,2}'), ' ');
    name = name.replaceAll(RegExp(r'\*?\b\d+([,.]\d{2})\b'), ' ');
    name = name.replaceAll(
      RegExp(r'\b\d+([,.]\d{1,3})?\s*(?:TL|TRY)\b', caseSensitive: false),
      ' ',
    );
    name = name.replaceAll(RegExp(r'^\s*\d{1,3}[\-.)]?\s+'), ' ');
    name = name.replaceAll(RegExp(r'\b(?:TL|TRY|USD|EUR)\b', caseSensitive: false), ' ');
    name = name.replaceAll(RegExp(r'\s+'), ' ').trim();
    return name;
  }

  String _normalizeName(String value) {
    return _plainUpper(value)
        .replaceAll(RegExp(r'[^A-Z0-9ĞÜŞÖÇ ]'), ' ')
        .replaceAll(RegExp(r'\b(?:ADET|AD|PCS|PIECE|QTY)\b'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  bool _looksLikeProductLine(
    String value, {
    required bool allowBareName,
    required ReceiptDocumentType type,
  }) {
    if (_isSeparator(value) || _looksLikeMetadata(value)) return false;
    if (!_hasLetter(value)) return false;

    final hasPrice = RegExp(r'\*?\b\d+[,.]\d{2}\b').hasMatch(value) ||
        RegExp(r'\b\d+[,.]\d{1,3}\s*(?:TL|TRY)\b', caseSensitive: false).hasMatch(value);
    final hasVat = RegExp(r'%\s*\d{1,2}').hasMatch(value);
    final hasQuantity = RegExp(
      r'(?:x|X|\*)\s*\d{1,4}|\b\d{1,4}\s*(?:adet|AD|ad|pcs|piece|qty)\b|\b\d{1,4}\s*x\b|\b\d{1,4}[,.]000\b',
      caseSensitive: false,
    ).hasMatch(value);
    if (hasPrice || hasVat || hasQuantity) return true;

    if (!allowBareName) return false;
    final key = _normalizeName(_nameFor(value));
    final words = key.split(' ').where((word) => word.isNotEmpty).length;
    final maxLength = type == ReceiptDocumentType.invoice ? 54 : 40;
    return key.length >= 3 && key.length <= maxLength && words <= 7;
  }

  bool _looksLikeInvoiceHeader(String value) {
    final upper = _plainUpper(value);
    final hits = [
      'URUN',
      'MAL',
      'HIZMET',
      'ACIKLAMA',
      'MIKTAR',
      'BIRIM',
      'TUTAR',
    ].where(upper.contains).length;
    return hits >= 1;
  }

  bool _isSeparator(String value) {
    final compact = value.replaceAll(RegExp(r'\s+'), '');
    return compact.length >= 4 && RegExp(r'^[-_=*—–]+$').hasMatch(compact);
  }

  bool _looksLikeMetadata(String value) {
    final upper = _plainUpper(value);
    return upper.contains('TOPLAM') ||
        upper.contains('TOTAL') ||
        upper.contains('KDV') ||
        upper.contains('VAT') ||
        upper.contains('TAX') ||
        upper.contains('TARIH') ||
        upper.contains('SAAT') ||
        upper.contains('FIS NO') ||
        upper.contains('FATURA NO') ||
        upper.contains('BELGE NO') ||
        upper.contains('VERGI') ||
        upper.contains('VKN') ||
        upper.contains('TCKN') ||
        upper.contains('IBAN') ||
        upper.contains('ADRES') ||
        upper.contains('TEL') ||
        upper.contains('TELEFON') ||
        upper.contains('KASIYER') ||
        upper.contains('SUBE') ||
        upper.contains('TERMINAL') ||
        upper.contains('NAKIT') ||
        upper.contains('CASH') ||
        upper.contains('CARD') ||
        upper.contains('KART') ||
        RegExp(r'\b\d{1,2}[./-]\d{1,2}[./-]\d{2,4}\b').hasMatch(value) ||
        RegExp(r'\b\d{1,2}:\d{2}\b').hasMatch(value) ||
        RegExp(r'\b0?\d{3}[\s-]?\d{3}[\s-]?\d{2}[\s-]?\d{2}\b').hasMatch(value);
  }

  bool _hasLetter(String value) {
    return value.runes.any((rune) {
      final char = String.fromCharCode(rune);
      return RegExp(r'[A-Za-z]').hasMatch(char) || 'ĞÜŞİÖÇğüşıöç'.contains(char);
    });
  }

  String _plainUpper(String value) {
    return value
        .toUpperCase()
        .replaceAll('İ', 'I')
        .replaceAll('İ', 'I')
        .replaceAll('Ğ', 'G')
        .replaceAll('Ü', 'U')
        .replaceAll('Ş', 'S')
        .replaceAll('Ö', 'O')
        .replaceAll('Ç', 'C');
  }
}
