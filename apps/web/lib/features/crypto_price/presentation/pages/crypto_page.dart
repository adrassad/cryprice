import 'dart:math' show max, min;

import 'package:crypto_tracker_app/features/crypto_price/presentation/widgets/count_field.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crypto_tracker_app/features/crypto_price/presentation/cubit/crypto_cubit.dart';
import 'package:crypto_tracker_app/features/crypto_price/presentation/widgets/error_display.dart';
import 'package:crypto_tracker_app/features/crypto_price/presentation/widgets/ticker_field.dart';
import 'package:crypto_tracker_app/features/crypto_price/presentation/widgets/result_price_list.dart';
import 'package:crypto_tracker_app/gen_l10n/app_localizations.dart';

import '../widgets/count_keyboard.dart';
import '../widgets/ticker_keyboard.dart';

class CryptoPage extends StatefulWidget {
  final VoidCallback onToggleLocale;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;
  const CryptoPage({
    super.key,
    required this.onToggleLocale,
    required this.onToggleTheme,
    required this.onLogout,
  });

  @override
  State<CryptoPage> createState() => _CryptoPageState();
}

class _CryptoPageState extends State<CryptoPage> {
  static final Uri _telegramBotUri = Uri.parse('https://t.me/AaveRadar_bot');
  final _countController = TextEditingController();
  final _ticker1Controller = TextEditingController();
  final _ticker2Controller = TextEditingController();
  final _countFocus = FocusNode();
  final _ticker1Focus = FocusNode();
  final _ticker2Focus = FocusNode();
  final _buttonFocus = FocusNode();

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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          loc.appTitle,
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: widget.onToggleLocale,
            tooltip: loc.switchLanguage,
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onToggleTheme,
            tooltip: loc.switchTheme,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
            tooltip: loc.signOut,
          ),
          IconButton(
            icon: const Icon(Icons.telegram),
            onPressed: _openTelegramBot,
            tooltip: '@AaveRadar_bot',
          ),
        ],
      ),
      body: SafeArea(
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
                  final gapTickers = short ? 6.0 : 10.0;
                  final gapCount = short ? 6.0 : 10.0;
                  final gapBeforeBtn = short ? 4.0 : 5.0;
                  final gapAfterBtn = short ? 8.0 : 12.0;
                  final swapPaddingH = narrow ? 4.0 : 8.0;
                  final swapSize = short ? 44.0 : 48.0;
                  final btnPadH = narrow ? 20.0 : 40.0;
                  final btnPadV = short ? 10.0 : 16.0;
                  final labelFont = short ? 14.0 : 16.0;
                  final hintFont = short ? 14.0 : 16.0;

                  /// Form intrinsics (labels + 4 chip rows) can exceed [bodyH] on short
                  /// viewports. Cap + scroll the form region; results keep [Expanded].
                  final double formMaxHeight =
                      (bodyH.isFinite && bodyH > 0)
                          ? min(520, max(120, bodyH * 0.58)).toDouble()
                          : 400.0;

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

                  final formColumn = Column(
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
                              padding: EdgeInsets.symmetric(
                                horizontal: swapPaddingH,
                              ),
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
                        onEditingComplete: () {
                          if (_countController.text.isEmpty) {
                            _countController.text = '1';
                          }
                          context.read<TitleCubit>().getPrice(
                            _ticker1Controller.text.trim(),
                            _ticker2Controller.text.trim(),
                            _countController.text,
                          );
                        },
                        onFieldSubmitted: (_) {
                          if (_countController.text.isEmpty) {
                            _countController.text = '1';
                          }
                          context.read<TitleCubit>().getPrice(
                            _ticker1Controller.text.trim(),
                            _ticker2Controller.text.trim(),
                            _countController.text,
                          );
                        },
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
                          context.read<TitleCubit>().getPrice(
                            _ticker1Controller.text.trim(),
                            _ticker2Controller.text.trim(),
                            _countController.text,
                          );
                        },
                        child: Text(
                          loc.getPrice,
                          style: GoogleFonts.montserrat(fontSize: labelFont),
                        ),
                      ),
                    ],
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: formMaxHeight),
                        child: SingleChildScrollView(
                          primary: false,
                          child: formColumn,
                        ),
                      ),
                      SizedBox(height: gapAfterBtn),
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
                                localizeError:
                                    (code) => _localizeError(code, loc),
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
      ),
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

  Future<void> _openTelegramBot() async {
    final bool opened = await launchUrl(_telegramBotUri, mode: LaunchMode.externalApplication);
    if (opened || !mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open @AaveRadar_bot')),
    );
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
            context.read<TitleCubit>().getPrice(
              _ticker1Controller.text.trim(),
              _ticker2Controller.text.trim(),
              _countController.text,
            );
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
      case 'error_unknown':
        return loc.error_unknown;
      default:
        return loc.error_unknown;
    }
  }
}
