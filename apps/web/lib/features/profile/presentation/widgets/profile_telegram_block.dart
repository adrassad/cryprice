import 'package:cryprice_frontend/features/profile/domain/entities/public_user.dart';
import 'package:cryprice_frontend/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileTelegramBlock extends StatelessWidget {
  const ProfileTelegramBlock({
    super.key,
    required this.user,
    required this.isBusy,
  });

  final PublicUser user;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.profileTelegramTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (user.isTelegramLinked)
              _LinkedTelegramContent(user: user, loc: loc, colorScheme: colorScheme)
            else
              _UnlinkedTelegramContent(
                loc: loc,
                theme: theme,
                isBusy: isBusy,
                onLinkPressed: () => _startTelegramLinking(context),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _startTelegramLinking(BuildContext context) async {
    final cubit = context.read<ProfileCubit>();
    await cubit.createTelegramLink();
    if (!context.mounted) {
      return;
    }
    final link = cubit.state.telegramLink?.trim();
    if (link == null || link.isEmpty) {
      return;
    }
    final uri = Uri.tryParse(link);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    cubit.clearTelegramLink();
  }
}

class _LinkedTelegramContent extends StatelessWidget {
  const _LinkedTelegramContent({
    required this.user,
    required this.loc,
    required this.colorScheme,
  });

  final PublicUser user;
  final AppLocalizations loc;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final handle = user.telegramDisplayUsername;
    final linkedColor = colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, color: linkedColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                loc.profileTelegramLinked,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: linkedColor,
                ),
              ),
            ),
          ],
        ),
        if (handle != null) ...[
          const SizedBox(height: 6),
          Text(
            handle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ] else if (user.telegramId != null) ...[
          const SizedBox(height: 6),
          Text(
            '${loc.telegramId}: ${user.telegramId}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _UnlinkedTelegramContent extends StatelessWidget {
  const _UnlinkedTelegramContent({
    required this.loc,
    required this.theme,
    required this.isBusy,
    required this.onLinkPressed,
  });

  final AppLocalizations loc;
  final ThemeData theme;
  final bool isBusy;
  final VoidCallback onLinkPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.profileTelegramLinkPrompt,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          loc.profileTelegramSafetyNote,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: isBusy ? null : onLinkPressed,
          child: isBusy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(loc.profileTelegramLinkButton),
        ),
      ],
    );
  }
}
