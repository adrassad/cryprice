import 'dart:math' show max, min;

import 'package:cryprice_frontend/core/shell/shell_visuals.dart';
import 'package:cryprice_frontend/features/crypto_price/presentation/cubit/crypto_cubit.dart';
import 'package:cryprice_frontend/features/crypto_price/presentation/widgets/count_field.dart';
import 'package:cryprice_frontend/features/crypto_price/presentation/widgets/error_display.dart';
import 'package:cryprice_frontend/features/crypto_price/presentation/widgets/result_price_list.dart';
import 'package:cryprice_frontend/features/crypto_price/presentation/widgets/ticker_field.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/count_keyboard.dart';
import '../widgets/ticker_keyboard.dart';

/// Body-only price calculator (form + CEX/DEX results). Requires [TitleCubit] above.
///
/// Must not include Scaffold, AppBar, theme/locale toggles, profile/logout, or
/// other auth chrome — those live in [AppShell] / [LoginPage].
class PriceCalculatorPage extends StatefulWidget {
  const PriceCalculatorPage({super.key});

  @override
  State<PriceCalculatorPage> createState() => _PriceCalculatorPageState();
}

class _PriceCalculatorPageState extends State<PriceCalculatorPage> {
  final _countController = TextEditingController();
  final _ticker1Controller = TextEditingController();
  final _ticker2Controller = TextEditingController();
  final _countFocus = FocusNode();
  final _ticker1Focus = FocusNode();
  final _ticker2Focus = FocusNode();
  final _buttonFocus = FocusNode();

  /// Collapses the input form after a successful [TitleLoaded]; local UI only.
  bool _isInputCollapsed = false;

  @override
  void dispose() {
    _countController.dispose();
    _ticker1Controller.dispose();
    _ticker2Controller.dispose();
    _countFocus.dispose();
    _ticker1Focus.dispose();
    _ticker2Focus.dispose();
    _buttonFocus.dispose();
    super.dispose();
  }

  void _expandInput() {
    if (!_isInputCollapsed) {
      return;
    }
    setState(() => _isInputCollapsed = false);
  }

  void _requestPrice(BuildContext context) {
    if (_countController.text.isEmpty) {
      _countController.text = '1';
    }
    context.read<TitleCubit>().getPrice(
      _ticker1Controller.text.trim(),
      _ticker2Controller.text.trim(),
      _countController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocListener<TitleCubit, TitleState>(
      listenWhen: (TitleState? previous, TitleState current) {
        return current is TitleLoaded ||
            current is TitleError ||
            current is TitleInitial;
      },
      listener: (BuildContext context, TitleState state) {
        if (state is TitleLoaded) {
          if (!_isInputCollapsed) {
            setState(() => _isInputCollapsed = true);
          }
        } else if (state is TitleError || state is TitleInitial) {
          if (_isInputCollapsed) {
            setState(() => _isInputCollapsed = false);
          }
        }
      },
      child: LayoutBuilder(
        builder: (context, outer) {
          final maxW0 = outer.maxWidth;
          final narrow0 = maxW0 < 540;
          final padH = narrow0 ? 12.0 : 16.0;
          final padV = MediaQuery.sizeOf(context).height < 620 ? 8.0 : 16.0;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxW = constraints.maxWidth;
                final bodyH = constraints.maxHeight;
                final narrow = maxW < 540;
                final short = bodyH < 560;
                final gapAfterInput = short ? 8.0 : 12.0;
                final hintFont = short ? 14.0 : 16.0;

                final double formMaxHeight =
                    (bodyH.isFinite && bodyH > 0)
                        ? min(520, max(120, bodyH * 0.58)).toDouble()
                        : 400.0;

                final Widget expandedInput = ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: formMaxHeight),
                  child: SingleChildScrollView(
                    primary: false,
                    child: _buildExpandedForm(
                      context: context,
                      loc: loc,
                      narrow: narrow,
                      short: short,
                    ),
                  ),
                );

                final Widget compactInput = _buildCompactSummary(
                  context: context,
                  loc: loc,
                  narrow: narrow,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedCrossFade(
                      firstCurve: Curves.easeInOut,
                      secondCurve: Curves.easeInOut,
                      sizeCurve: Curves.easeInOut,
                      duration: const Duration(milliseconds: 260),
                      crossFadeState: _isInputCollapsed
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: expandedInput,
                      secondChild: compactInput,
                    ),
                    SizedBox(height: gapAfterInput),
                    Expanded(
                      child: BlocBuilder<TitleCubit, TitleState>(
                        builder: (context, state) {
                          if (state is TitleInitial) {
                            return Center(
                              child: Text(
                                loc.enterTicker,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: hintFont,
                                  height: 1.4,
                                ),
                              ),
                            );
                          } else if (state is TitleLoading) {
                            final gifSize = short ? 96.0 : 120.0;
                            return Center(
                              child: Image.asset(
                                'assets/gifs/loading.gif',
                                height: gifSize,
                                width: gifSize,
                                fit: BoxFit.contain,
                              ),
                            );
                          } else if (state is TitleLoaded) {
                            return ResultPriceList(
                              l10n: loc,
                              rows: state.rows,
                              countMultiplier: state.countMultiplier,
                              userTicker1: state.userTicker1,
                              userTicker2: state.userTicker2,
                              localizeError: (code) => _localizeError(code, loc),
                              offchainConvert: state.offchainConvert,
                            );
                          } else if (state is TitleError) {
                            return Center(
                              child: ErrorDisplay(errorCode: state.errorCode),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompactSummary({
    required BuildContext context,
    required AppLocalizations loc,
    required bool narrow,
  }) {
    final theme = Theme.of(context);
    final String coin1 = _ticker1Controller.text.trim().toUpperCase();
    final String coin2 = _ticker2Controller.text.trim().toUpperCase();
    final String countText = _countController.text.trim().isEmpty
        ? '1'
        : _countController.text.trim();
    final String summary = loc.priceInputSummary(coin1, coin2, countText);

    final Widget editButton = TextButton.icon(
      onPressed: _expandInput,
      icon: const Icon(Icons.edit_outlined, size: 18),
      label: Text(loc.editPriceInput),
      style: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );

    return ShellVisuals.panel(
      context: context,
      padding: EdgeInsets.symmetric(
        horizontal: narrow ? 12 : 16,
        vertical: narrow ? 10 : 12,
      ),
      child: narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  summary,
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: editButton,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Text(
                    summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                editButton,
              ],
            ),
    );
  }

  Widget _buildExpandedForm({
    required BuildContext context,
    required AppLocalizations loc,
    required bool narrow,
    required bool short,
  }) {
    final gapTickers = short ? 6.0 : 10.0;
    final gapCount = short ? 6.0 : 10.0;
    final gapBeforeBtn = short ? 4.0 : 5.0;
    final swapPaddingH = narrow ? 4.0 : 8.0;
    final swapSize = short ? 44.0 : 48.0;
    final btnPadH = narrow ? 20.0 : 40.0;
    final btnPadV = short ? 10.0 : 16.0;
    final labelFont = short ? 14.0 : 16.0;

    Widget swapControl() {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: Size(swapSize, swapSize),
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: () {
          final temp = _ticker1Controller.text;
          _ticker1Controller.text = _ticker2Controller.text;
          _ticker2Controller.text = temp;
        },
        child: const Icon(Icons.swap_horiz_rounded),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!short) const SizedBox(height: 8),
        if (narrow) ...[
          TickerField(
            controller: _ticker1Controller,
            label: loc.coin1,
            helperText: 'BTC',
            currentNode: _ticker1Focus,
            nextNode: _ticker2Focus,
            onTap: () {
              if (isMobile(context)) {
                _showTickerKeyboard(context, 1);
              }
            },
          ),
          SizedBox(height: gapTickers),
          Center(child: swapControl()),
          SizedBox(height: gapTickers),
          TickerField(
            controller: _ticker2Controller,
            label: loc.coin2,
            helperText: 'USDT',
            currentNode: _ticker2Focus,
            nextNode: _buttonFocus,
            onTap: () {
              if (isMobile(context)) {
                _showTickerKeyboard(context, 2);
              }
            },
          ),
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TickerField(
                  controller: _ticker1Controller,
                  label: loc.coin1,
                  helperText: 'BTC',
                  currentNode: _ticker1Focus,
                  nextNode: _ticker2Focus,
                  onTap: () {
                    if (isMobile(context)) {
                      _showTickerKeyboard(context, 1);
                    }
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: swapPaddingH),
                child: swapControl(),
              ),
              Expanded(
                child: TickerField(
                  controller: _ticker2Controller,
                  label: loc.coin2,
                  helperText: 'USDT',
                  currentNode: _ticker2Focus,
                  nextNode: _buttonFocus,
                  onTap: () {
                    if (isMobile(context)) {
                      _showTickerKeyboard(context, 2);
                    }
                  },
                ),
              ),
            ],
          ),
        SizedBox(height: gapCount),
        CountField(
          controller: _countController,
          label: loc.count,
          helperText: '0.0000',
          currentNode: _countFocus,
          nextNode: _buttonFocus,
          onEditingComplete: () => _requestPrice(context),
          onFieldSubmitted: (_) => _requestPrice(context),
          onTap: () {
            if (isMobile(context)) {
              _showCountKeyboard(context);
            }
          },
        ),
        SizedBox(height: gapBeforeBtn),
        ElevatedButton(
          focusNode: _buttonFocus,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: btnPadH,
              vertical: btnPadV,
            ),
            minimumSize: Size(0, short ? 42 : 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () {
            FocusScope.of(context).unfocus();
            _requestPrice(context);
          },
          child: Text(
            loc.getPrice,
            style: GoogleFonts.montserrat(fontSize: labelFont),
          ),
        ),
      ],
    );
  }

  bool isMobile(BuildContext context) {
    if (kIsWeb) {
      return false;
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.android => true,
      _ => false,
    };
  }

  void _showCountKeyboard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return CountKeyboard(
          onTextInput: (value) {
            _countController.text += value;
          },
          onBackspace: () {
            final text = _countController.text;
            if (text.isNotEmpty) {
              _countController.text = text.substring(0, text.length - 1);
            }
          },
          onDone: () {
            _requestPrice(context);
            Navigator.of(context).pop();
            FocusScope.of(context).requestFocus(_buttonFocus);
          },
        );
      },
    );
  }

  void _showTickerKeyboard(BuildContext context, numberTicker) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return TickerKeyboard(
          onTextInput: (value) {
            if (numberTicker == 1) {
              _ticker1Controller.text += value;
            } else {
              _ticker2Controller.text += value;
            }
          },
          onBackspace: () {
            if (numberTicker == 1) {
              final text = _ticker1Controller.text;
              if (text.isNotEmpty) {
                _ticker1Controller.text = text.substring(0, text.length - 1);
              }
            } else {
              final text = _ticker2Controller.text;
              if (text.isNotEmpty) {
                _ticker2Controller.text = text.substring(0, text.length - 1);
              }
            }
          },
          onDone: () {
            Navigator.of(context).pop();
            if (numberTicker == 1) {
              FocusScope.of(context).requestFocus(_ticker2Focus);
            } else {
              FocusScope.of(context).requestFocus(_buttonFocus);
            }
          },
        );
      },
    );
  }

  String _localizeError(String? code, AppLocalizations loc) {
    switch (code) {
      case 'error_no_internet':
        return loc.error_no_internet;
      case 'error_fetch_failed':
        return loc.error_fetch_failed;
      case 'error_rate_limited':
        return loc.error_rate_limited;
      case 'error_invalid_count':
        return loc.error_invalid_count;
      case 'error_unknown':
        return loc.error_unknown;
      default:
        return loc.error_unknown;
    }
  }
}
