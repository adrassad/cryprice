import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultBreakpoints {
  const ResultBreakpoints(this.width);
  final double width;

  bool get isMobile => width < 600;
  bool get isTablet => width >= 600 && width < 1024;
  bool get isDesktop => width >= 1024;
}

class SectionColors {
  const SectionColors({
    required this.headerBg,
    required this.onHeader,
    required this.bodyBg,
    required this.border,
    required this.headerIcon,
  });

  final Color headerBg;
  final Color onHeader;
  final Color bodyBg;
  final Color border;
  final Color headerIcon;

  static SectionColors of(BuildContext context, PanelKind kind) {
    final c = Theme.of(context).colorScheme;
    return switch (kind) {
      PanelKind.cex => SectionColors(
        headerBg: c.primary,
        onHeader: c.onPrimary,
        bodyBg: c.surfaceContainerLow,
        border: c.outlineVariant,
        headerIcon: c.onPrimary,
      ),
      PanelKind.dex => SectionColors(
        headerBg: c.tertiary,
        onHeader: c.onTertiary,
        bodyBg: c.surfaceContainerHigh,
        border: c.outlineVariant,
        headerIcon: c.onTertiary,
      ),
    };
  }
}

enum PanelKind {
  cex,
  dex,
}

class SectionPanel extends StatelessWidget {
  const SectionPanel({
    super.key,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final PanelKind kind;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sc = SectionColors.of(context, kind);
    final headIcon = switch (kind) {
      PanelKind.cex => Icons.show_chart,
      PanelKind.dex => Icons.hub_outlined,
    };

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: sc.bodyBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: sc.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: theme.brightness == Brightness.dark ? 0.35 : 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            color: sc.headerBg,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(headIcon, color: sc.headerIcon, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                          color: sc.onHeader,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.montserrat(
                          fontSize: 12.5,
                          height: 1.3,
                          color: sc.onHeader.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: spaced(children, gap: 12),
            ),
          ),
        ],
      ),
    );
  }
}

List<Widget> spaced(List<Widget> raw, {double gap = 10}) {
  if (raw.isEmpty) {
    return raw;
  }
  final out = <Widget>[];
  for (var i = 0; i < raw.length; i++) {
    if (i > 0) {
      out.add(SizedBox(height: gap));
    }
    out.add(raw[i]);
  }
  return out;
}
