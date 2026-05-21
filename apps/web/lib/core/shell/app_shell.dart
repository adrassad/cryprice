import 'package:cryprice_frontend/core/di/di.dart';
import 'package:cryprice_frontend/core/navigation/app_section.dart';
import 'package:cryprice_frontend/core/shell/cubit/shell_navigation_cubit.dart';
import 'package:cryprice_frontend/core/shell/shell_visuals.dart';
import 'package:cryprice_frontend/core/shell/widgets/shell_left_command_menu.dart';
import 'package:cryprice_frontend/core/shell/widgets/shell_section_nav.dart';
import 'package:cryprice_frontend/core/shell/widgets/shell_user_menu.dart';
import 'package:cryprice_frontend/features/crypto_price/presentation/cubit/crypto_cubit.dart';
import 'package:cryprice_frontend/features/crypto_price/presentation/pages/price_calculator_page.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/pages/health_factor_page.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/pages/portfolio_page.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dashboard shell layout for authenticated users ([AppAuthGate]).
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.onProfile,
    required this.onLogin,
    required this.onLogout,
  });

  final VoidCallback onProfile;
  final VoidCallback onLogin;
  final VoidCallback onLogout;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final ShellNavigationCubit _shellNavigationCubit;

  @override
  void initState() {
    super.initState();
    _shellNavigationCubit = ShellNavigationCubit();
  }

  @override
  void dispose() {
    _shellNavigationCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShellNavigationCubit>.value(
      value: _shellNavigationCubit,
      child: _AppShellScaffold(
        onProfile: widget.onProfile,
        onLogin: widget.onLogin,
        onLogout: widget.onLogout,
      ),
    );
  }
}

class _AppShellScaffold extends StatelessWidget {
  const _AppShellScaffold({
    required this.onProfile,
    required this.onLogin,
    required this.onLogout,
  });

  final VoidCallback onProfile;
  final VoidCallback onLogin;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool useWideLayout =
                constraints.maxWidth >= ShellVisuals.wideLayoutMinWidth;

            if (useWideLayout) {
              return _ShellWideLayout(
                onProfile: onProfile,
                onLogin: onLogin,
                onLogout: onLogout,
              );
            }
            return _ShellNarrowLayout(
              onProfile: onProfile,
              onLogin: onLogin,
              onLogout: onLogout,
            );
          },
        ),
      ),
    );
  }
}

class _ShellWideLayout extends StatelessWidget {
  const _ShellWideLayout({
    required this.onProfile,
    required this.onLogin,
    required this.onLogout,
  });

  final VoidCallback onProfile;
  final VoidCallback onLogin;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShellNavigationCubit, ShellNavigationState>(
      builder: (BuildContext context, ShellNavigationState navState) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 8, 16),
              child: Align(
                alignment: Alignment.topCenter,
                child: ShellVisuals.panel(
                  context: context,
                  child: const ShellLeftCommandMenu(),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ShellHeader(
                    title: _sectionTitle(context, navState.selectedSection),
                    onProfile: onProfile,
                    onLogin: onLogin,
                    onLogout: onLogout,
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints inner) {
                        final bool compactNav =
                            inner.maxWidth < ShellVisuals.sectionNavReserveWidth + 48;
                        final double rightPad = compactNav
                            ? 72
                            : ShellVisuals.sectionNavReserveWidth;
                        final double bottomPad = compactNav
                            ? 72
                            : ShellVisuals.sectionNavReserveBottom;

                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                8,
                                0,
                                rightPad,
                                bottomPad,
                              ),
                              child: _ShellSectionBody(
                                selectedSection: navState.selectedSection,
                              ),
                            ),
                            Positioned(
                              right: 16,
                              bottom: 16,
                              child: ShellVisuals.panel(
                                context: context,
                                padding: const EdgeInsets.all(8),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: ShellVisuals.sectionNavMaxWidth,
                                  ),
                                  child: ShellSectionNav(
                                    compactLabels: compactNav,
                                    selectedSection: navState.selectedSection,
                                    onSectionSelected: context
                                        .read<ShellNavigationCubit>()
                                        .selectSection,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ShellNarrowLayout extends StatelessWidget {
  const _ShellNarrowLayout({
    required this.onProfile,
    required this.onLogin,
    required this.onLogout,
  });

  final VoidCallback onProfile;
  final VoidCallback onLogin;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShellNavigationCubit, ShellNavigationState>(
      builder: (BuildContext context, ShellNavigationState navState) {
        final loc = AppLocalizations.of(context)!;
        final bool veryNarrow = MediaQuery.sizeOf(context).width < 400;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 0,
                    child: ShellVisuals.panel(
                      context: context,
                      padding: const EdgeInsets.all(6),
                      child: const ShellLeftCommandMenu(
                        layout: ShellCommandMenuLayout.horizontal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ShellHeaderTitle(
                      title: _sectionTitle(context, navState.selectedSection),
                      dense: true,
                    ),
                  ),
                  ShellUserMenu(
                    onProfile: onProfile,
                    onLogin: onLogin,
                    onLogout: onLogout,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _ShellSectionBody(selectedSection: navState.selectedSection),
              ),
            ),
            NavigationBar(
              selectedIndex: _sectionIndex(navState.selectedSection),
              labelBehavior: veryNarrow
                  ? NavigationDestinationLabelBehavior.onlyShowSelected
                  : NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: (int index) {
                context.read<ShellNavigationCubit>().selectSection(
                  AppSection.values[index],
                );
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.calculate_outlined),
                  label: loc.navPriceCalculator,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.pie_chart_outline),
                  label: loc.navPortfolio,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.monitor_heart_outlined),
                  label: loc.navHealthFactorCalculator,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ShellHeader extends StatelessWidget {
  const _ShellHeader({
    required this.title,
    required this.onProfile,
    required this.onLogin,
    required this.onLogout,
  });

  final String title;
  final VoidCallback onProfile;
  final VoidCallback onLogin;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          height: kToolbarHeight,
          child: Row(
            children: [
              Expanded(child: _ShellHeaderTitle(title: title)),
              ShellUserMenu(
                onProfile: onProfile,
                onLogin: onLogin,
                onLogout: onLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShellHeaderTitle extends StatelessWidget {
  const _ShellHeaderTitle({
    required this.title,
    this.dense = false,
  });

  final String title;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.montserrat(
        fontSize: dense ? 18 : 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _ShellSectionBody extends StatelessWidget {
  const _ShellSectionBody({required this.selectedSection});

  final AppSection selectedSection;

  static const List<Widget> _pages = <Widget>[
    _ShellPriceCalculatorTab(),
    _ShellPortfolioTab(),
    HealthFactorPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _sectionIndex(selectedSection),
      children: _pages,
    );
  }
}

/// Owns [TitleCubit] for the shell price tab; stays mounted under [IndexedStack].
class _ShellPriceCalculatorTab extends StatefulWidget {
  const _ShellPriceCalculatorTab();

  @override
  State<_ShellPriceCalculatorTab> createState() => _ShellPriceCalculatorTabState();
}

class _ShellPriceCalculatorTabState extends State<_ShellPriceCalculatorTab> {
  late final TitleCubit _titleCubit;

  @override
  void initState() {
    super.initState();
    _titleCubit = di<TitleCubit>();
  }

  @override
  void dispose() {
    _titleCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TitleCubit>.value(
      value: _titleCubit,
      child: const PriceCalculatorPage(),
    );
  }
}

/// Owns [PortfolioCubit] for the shell portfolio tab; stays mounted under [IndexedStack].
class _ShellPortfolioTab extends StatefulWidget {
  const _ShellPortfolioTab();

  @override
  State<_ShellPortfolioTab> createState() => _ShellPortfolioTabState();
}

class _ShellPortfolioTabState extends State<_ShellPortfolioTab> {
  late final PortfolioCubit _portfolioCubit;

  @override
  void initState() {
    super.initState();
    _portfolioCubit = di<PortfolioCubit>()..load();
  }

  @override
  void dispose() {
    _portfolioCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PortfolioCubit>.value(
      value: _portfolioCubit,
      child: const PortfolioPage(),
    );
  }
}

String _sectionTitle(BuildContext context, AppSection section) {
  final loc = AppLocalizations.of(context)!;
  return switch (section) {
    AppSection.priceCalculator => loc.navPriceCalculator,
    AppSection.portfolio => loc.navPortfolio,
    AppSection.healthFactorCalculator => loc.navHealthFactorCalculator,
  };
}

int _sectionIndex(AppSection section) {
  return switch (section) {
    AppSection.priceCalculator => 0,
    AppSection.portfolio => 1,
    AppSection.healthFactorCalculator => 2,
  };
}
