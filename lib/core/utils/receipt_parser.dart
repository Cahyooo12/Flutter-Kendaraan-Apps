import 'package:intl/intl.dart';

enum ReceiptKind { fuel, service }

class ParsedReceipt {
  final ReceiptKind kind;
  final DateTime? date;
  final double? totalAmount;
  final double? liters;
  final double? pricePerLiter;
  final String? fuelType;
  final String? stationOrWorkshopName;
  final String rawText;

  const ParsedReceipt({
    required this.kind,
    required this.rawText,
    this.date,
    this.totalAmount,
    this.liters,
    this.pricePerLiter,
    this.fuelType,
    this.stationOrWorkshopName,
  });

  bool get hasAnyField =>
      date != null ||
      totalAmount != null ||
      liters != null ||
      pricePerLiter != null ||
      fuelType != null ||
      stationOrWorkshopName != null;
}

class ReceiptParser {
  static const _fuelKeywords = [
    'PERTAMINA',
    'SHELL',
    'BP',
    'VIVO',
    'PERTAMAX',
    'PERTALITE',
    'DEXLITE',
    'DEX',
    'BIOSOLAR',
    'SOLAR',
    'SPBU',
    'LITER',
    'LITRES',
  ];

  static const _serviceKeywords = [
    'BENGKEL',
    'SERVICE',
    'SERVIS',
    'GANTI OLI',
    'TUNE UP',
    'AHASS',
    'AUTO',
    'WORKSHOP',
    'KAMPAS',
    'BAN',
    'AKI',
  ];

  static ReceiptKind detectKind(String text) {
    final upper = text.toUpperCase();
    var fuelScore = 0;
    var serviceScore = 0;
    for (final k in _fuelKeywords) {
      if (upper.contains(k)) fuelScore++;
    }
    for (final k in _serviceKeywords) {
      if (upper.contains(k)) serviceScore++;
    }
    return serviceScore > fuelScore
        ? ReceiptKind.service
        : ReceiptKind.fuel;
  }

  /// Parse with hint about kind. If kind == null, auto-detect.
  static ParsedReceipt parse(String text, {ReceiptKind? hintKind}) {
    final kind = hintKind ?? detectKind(text);

    final date = _extractDate(text);
    final total = _extractTotal(text);
    final fuelType = kind == ReceiptKind.fuel ? _extractFuelType(text) : null;
    final liters = kind == ReceiptKind.fuel ? _extractLiters(text) : null;
    final pricePerLiter =
        kind == ReceiptKind.fuel ? _extractPricePerLiter(text) : null;
    final name = kind == ReceiptKind.fuel
        ? _extractStation(text)
        : _extractWorkshop(text);

    return ParsedReceipt(
      kind: kind,
      rawText: text,
      date: date,
      totalAmount: total,
      liters: liters,
      pricePerLiter: pricePerLiter,
      fuelType: fuelType,
      stationOrWorkshopName: name,
    );
  }

  // ─── Date ─────────────────────────────────────────────────────────────────
  static DateTime? _extractDate(String text) {
    // Match patterns: dd/MM/yyyy, dd-MM-yyyy, dd.MM.yyyy, dd MMM yyyy, yyyy-MM-dd
    final patterns = <RegExp>[
      RegExp(r'\b(\d{1,2})[/.\-](\d{1,2})[/.\-](\d{2,4})\b'),
      RegExp(r'\b(\d{4})[/.\-](\d{1,2})[/.\-](\d{1,2})\b'),
      RegExp(
        r'\b(\d{1,2})\s+(Jan|Feb|Mar|Apr|Mei|May|Jun|Jul|Agu|Aug|Sep|Okt|Oct|Nov|Des|Dec)[a-z]*\s+(\d{2,4})\b',
        caseSensitive: false,
      ),
    ];

    for (final re in patterns) {
      final match = re.firstMatch(text);
      if (match == null) continue;

      try {
        if (re == patterns[2]) {
          final day = int.parse(match.group(1)!);
          final monStr = match.group(2)!.toLowerCase();
          final year = _normalizeYear(int.parse(match.group(3)!));
          final month = _monthFromShort(monStr);
          if (month != null) {
            return _safeDate(year, month, day);
          }
        } else if (re == patterns[1]) {
          // yyyy-MM-dd
          final year = _normalizeYear(int.parse(match.group(1)!));
          final month = int.parse(match.group(2)!);
          final day = int.parse(match.group(3)!);
          return _safeDate(year, month, day);
        } else {
          // dd-MM-yyyy
          final day = int.parse(match.group(1)!);
          final month = int.parse(match.group(2)!);
          final year = _normalizeYear(int.parse(match.group(3)!));
          return _safeDate(year, month, day);
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  static int _normalizeYear(int y) {
    if (y < 100) return 2000 + y;
    return y;
  }

  static int? _monthFromShort(String s) {
    const map = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'mei': 5,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'agu': 8,
      'aug': 8,
      'sep': 9,
      'okt': 10,
      'oct': 10,
      'nov': 11,
      'des': 12,
      'dec': 12,
    };
    final key = s.length >= 3 ? s.substring(0, 3) : s;
    return map[key];
  }

  static DateTime? _safeDate(int y, int m, int d) {
    if (y < 2000 || y > 2100) return null;
    if (m < 1 || m > 12) return null;
    if (d < 1 || d > 31) return null;
    try {
      final dt = DateTime(y, m, d);
      if (dt.month != m || dt.day != d) return null;
      return dt;
    } catch (_) {
      return null;
    }
  }

  // ─── Total Amount ────────────────────────────────────────────────────────
  static double? _extractTotal(String text) {
    // Look for keywords near amounts
    final upper = text.toUpperCase();
    final lines = upper.split('\n');

    final keywords = [
      'TOTAL',
      'JUMLAH BAYAR',
      'BAYAR',
      'GRAND TOTAL',
      'NETTO',
      'TOTAL HARGA',
      'TOTAL PEMBELIAN',
    ];

    double? best;
    for (final line in lines) {
      for (final kw in keywords) {
        if (line.contains(kw)) {
          final amt = _firstAmount(line);
          if (amt != null) {
            // Heuristic: keep the largest (final total usually largest)
            if (best == null || amt > best) best = amt;
          }
        }
      }
    }

    if (best != null) return best;

    // Fallback: pick the largest numeric value that looks like rupiah (≥ 1000)
    final all = _allAmounts(upper);
    final candidates = all.where((a) => a >= 1000).toList()..sort();
    return candidates.isEmpty ? null : candidates.last;
  }

  static double? _firstAmount(String line) {
    // Match Rp 12.345 or 12,345 or 12345
    final re = RegExp(r'(?:RP\.?\s*)?(\d{1,3}(?:[.,]\d{3})+|\d{4,})(?:[.,]\d{1,2})?',
        caseSensitive: false);
    final match = re.firstMatch(line);
    if (match == null) return null;
    return _parseNumber(match.group(1)!);
  }

  static List<double> _allAmounts(String text) {
    final re = RegExp(r'(?:RP\.?\s*)?(\d{1,3}(?:[.,]\d{3})+|\d{4,})',
        caseSensitive: false);
    final out = <double>[];
    for (final m in re.allMatches(text)) {
      final v = _parseNumber(m.group(1)!);
      if (v != null) out.add(v);
    }
    return out;
  }

  static double? _parseNumber(String s) {
    // Indonesian format: thousand separator . , decimal separator
    // Strip thousand separators (both . and ,) since OCR may swap them.
    final cleaned = s.replaceAll(RegExp(r'[.,]'), '');
    return double.tryParse(cleaned);
  }

  // ─── Fuel Type ───────────────────────────────────────────────────────────
  static String? _extractFuelType(String text) {
    final upper = text.toUpperCase();
    const types = [
      'PERTAMAX TURBO',
      'PERTAMAX',
      'PERTALITE',
      'DEXLITE',
      'PERTAMINA DEX',
      'BIOSOLAR',
      'SOLAR',
      'SHELL V-POWER',
      'SHELL SUPER',
      'SHELL DIESEL',
      'BP ULTIMATE',
      'BP 92',
      'BP 95',
      'BP DIESEL',
      'REVVO 89',
      'REVVO 92',
      'REVVO 95',
    ];
    for (final t in types) {
      if (upper.contains(t)) {
        // Normalize casing
        return t
            .split(' ')
            .map((w) => w.isEmpty
                ? ''
                : w[0] + w.substring(1).toLowerCase())
            .join(' ');
      }
    }
    return null;
  }

  // ─── Liters ──────────────────────────────────────────────────────────────
  static double? _extractLiters(String text) {
    final upper = text.toUpperCase();
    // Patterns: 12.34 L, 12,34 LITER, VOLUME 5.23
    final patterns = [
      RegExp(r'(\d+[.,]\d{1,3})\s*(?:L|LTR|LITER|LITRES)\b'),
      RegExp(r'\b(?:VOLUME|JUMLAH)\s*[:=]?\s*(\d+[.,]\d{1,3})'),
    ];
    for (final re in patterns) {
      final m = re.firstMatch(upper);
      if (m != null) {
        // Replace , with . for decimal
        final raw = m.group(1)!.replaceAll(',', '.');
        final v = double.tryParse(raw);
        if (v != null && v > 0 && v < 1000) return v;
      }
    }
    return null;
  }

  // ─── Price Per Liter ─────────────────────────────────────────────────────
  static double? _extractPricePerLiter(String text) {
    final upper = text.toUpperCase();
    final patterns = [
      RegExp(r'(?:HARGA|PRICE)\s*(?:\/?\s*)?L(?:TR|ITER)?\s*[:=]?\s*(?:RP\.?\s*)?(\d{1,3}(?:[.,]\d{3})+|\d{4,})'),
      RegExp(r'(?:RP\.?\s*)?(\d{1,3}(?:[.,]\d{3})+|\d{4,})\s*\/\s*L'),
    ];
    for (final re in patterns) {
      final m = re.firstMatch(upper);
      if (m != null) {
        final v = _parseNumber(m.group(1)!);
        if (v != null && v >= 1000 && v < 100000) return v;
      }
    }
    return null;
  }

  // ─── Station ─────────────────────────────────────────────────────────────
  static String? _extractStation(String text) {
    final lines = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty);
    const brands = ['PERTAMINA', 'SHELL', 'BP', 'VIVO', 'AKR', 'SPBU'];
    // Pick the first line that contains a brand, take that line as station name
    for (final line in lines) {
      final upper = line.toUpperCase();
      for (final b in brands) {
        if (upper.contains(b)) {
          // Clean: keep alphanumeric and spaces, limit length
          final cleaned = line
              .replaceAll(RegExp(r'[^A-Za-z0-9 ]'), '')
              .trim();
          if (cleaned.length > 3 && cleaned.length < 60) return cleaned;
        }
      }
    }
    return null;
  }

  // ─── Workshop ────────────────────────────────────────────────────────────
  static String? _extractWorkshop(String text) {
    final lines = text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    const hits = ['BENGKEL', 'AHASS', 'AUTO', 'MOTOR', 'WORKSHOP', 'SERVICE'];
    for (final line in lines) {
      final upper = line.toUpperCase();
      for (final h in hits) {
        if (upper.contains(h)) {
          final cleaned = line
              .replaceAll(RegExp(r'[^A-Za-z0-9 .,&-]'), '')
              .trim();
          if (cleaned.length > 3 && cleaned.length < 60) return cleaned;
        }
      }
    }
    // Fallback: take first non-empty line (often store header)
    if (lines.isNotEmpty) {
      final first = lines.first;
      if (first.length > 3 && first.length < 60) {
        return first.replaceAll(RegExp(r'[^A-Za-z0-9 .,&-]'), '').trim();
      }
    }
    return null;
  }
}

extension ParsedReceiptFormatting on ParsedReceipt {
  String get formattedDate => date == null
      ? '-'
      : DateFormat('dd MMM yyyy', 'id_ID').format(date!);

  String formattedAmount(double? v) => v == null
      ? '-'
      : NumberFormat.currency(
              locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
          .format(v);
}
