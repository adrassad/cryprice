import 'package:crypto_tracker_app/core/utils/number_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class CountField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String helperText;
  final FocusNode currentNode;
  final FocusNode? nextNode;
  final VoidCallback? onEditingComplete;
  final VoidCallback? onTap;
  final void Function(String)? onFieldSubmitted;

  const CountField({
    super.key,
    required this.controller,
    required this.label,
    required this.helperText,
    required this.currentNode,
    this.nextNode,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final countPresets = ['1', '0.1', '0.01', '0.001'];
    void applyPreset(String value) {
      controller.text = value;
      if (nextNode != null) {
        FocusScope.of(context).requestFocus(nextNode!);
      }
    }

    return TextFormField(
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      textInputAction:
          nextNode != null ? TextInputAction.next : TextInputAction.done,
      inputFormatters: [
        LengthLimitingTextInputFormatter(5),
        DoubleInputFormatter(),
      ],
      onFieldSubmitted: (value) {
        final normalized = value.replaceAll(',', '.');
        onFieldSubmitted?.call(normalized);
      },
      onEditingComplete: onEditingComplete,
      onTap: onTap,
      focusNode: currentNode,

      controller: controller,
      textCapitalization: TextCapitalization.characters,
      style: GoogleFonts.montserrat(fontSize: 16),
      decoration: InputDecoration(
        counterText: "",
        labelText: label,

        isDense: true,
        suffixIcon: PopupMenuButton<String>(
          tooltip: 'Presets',
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onSelected: applyPreset,
          itemBuilder:
              (ctx) =>
                  countPresets
                      .map(
                        (v) => PopupMenuItem<String>(
                          value: v,
                          child: Text(
                            v,
                            style: GoogleFonts.montserrat(fontSize: 15),
                          ),
                        ),
                      )
                      .toList(),
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        labelStyle: GoogleFonts.montserrat(color: Colors.grey[700]),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurple.shade300),
        ),
      ),
    );
  }
}
