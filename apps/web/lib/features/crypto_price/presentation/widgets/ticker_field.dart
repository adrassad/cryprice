import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/latin_input_formatter.dart';

class TickerField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String helperText;
  final FocusNode currentNode;
  final FocusNode? nextNode;
  final VoidCallback? onEditingComplete;
  final VoidCallback? onTap;

  const TickerField({
    super.key,
    required this.controller,
    required this.label,
    required this.helperText,
    required this.currentNode,
    this.nextNode,
    this.onEditingComplete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final popularTickers = [
      'BTC',
      'WBTC',
      'BTC.b',
      'cbBTC',
      'SOL',
      'ETH',
      'WETH',
      'AVAX',
      'WAVAX',
      'USDT',
      'USDC',
    ];
    void applyPreset(String ticker) {
      controller.text = ticker;
      if (nextNode != null) {
        FocusScope.of(context).requestFocus(nextNode);
      }
    }

    return TextFormField(
      inputFormatters: [
        LengthLimitingTextInputFormatter(5),
        LatinInputFormatter(),
      ],
      onFieldSubmitted: (_) {
        if (nextNode != null) {
          FocusScope.of(context).requestFocus(nextNode);
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      onTap: onTap,
      onEditingComplete: onEditingComplete,
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
                  popularTickers
                      .map(
                        (t) => PopupMenuItem<String>(
                          value: t,
                          child: Text(
                            t,
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
