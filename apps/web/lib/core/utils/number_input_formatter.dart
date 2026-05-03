import 'package:flutter/services.dart';

class DoubleInputFormatter extends TextInputFormatter {
  final bool allowNegative;
  final int? decimalRange;

  DoubleInputFormatter({this.allowNegative = false, this.decimalRange});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final value = newValue.text;
    if (value.isEmpty) {
      return newValue;
    }

    // Allow digits with one optional decimal separator (`.` or `,`)
    // and optional leading minus.
    final pattern = allowNegative
        ? RegExp(r'^-?\d*(?:[.,]\d*)?$')
        : RegExp(r'^\d*(?:[.,]\d*)?$');
    if (!pattern.hasMatch(value)) {
      return oldValue;
    }

    if (decimalRange != null) {
      final normalized = value.replaceAll(',', '.');
      final dotIndex = normalized.indexOf('.');
      if (dotIndex >= 0) {
        final decimalsCount = normalized.length - dotIndex - 1;
        if (decimalsCount > decimalRange!) {
          return oldValue;
        }
      }
    }

    if (!allowNegative && value.startsWith('-')) {
      return oldValue;
    }

    if (allowNegative && value == '-') {
      // Keep intermediate typing state for negative numbers.
      return newValue;
    }

    if (value.startsWith('.') || value.startsWith(',') || value == '-.' || value == '-,') {
      // Keep intermediate typing state for decimal input.
      return newValue;
    }

    final normalized = value.replaceAll(',', '.');
    if (normalized == '.') {
      return newValue;
    }

    if (double.tryParse(normalized) == null && normalized != '-' && normalized != '-.') {
        return oldValue;
    }

    return newValue;
  }
}
