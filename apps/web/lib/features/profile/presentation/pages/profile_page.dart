import 'package:cryprice_frontend/core/di/di.dart';
import 'package:cryprice_frontend/core/network/api_error_localizer.dart';
import 'package:cryprice_frontend/core/web/app_cache_reset_service.dart';
import 'package:cryprice_frontend/features/auth/data/local/auth_token_store.dart';
import 'package:cryprice_frontend/features/auth/presentation/widgets/authenticated_feature_gate.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alert_rules_cubit.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alert_rules_state.dart';
import 'package:cryprice_frontend/features/alerts/presentation/widgets/profile_hf_alert_block.dart';
import 'package:cryprice_frontend/features/profile/domain/entities/public_user.dart';
import 'package:cryprice_frontend/features/profile/domain/entities/wallet.dart';
import 'package:cryprice_frontend/features/profile/presentation/widgets/profile_telegram_block.dart';
import 'package:cryprice_frontend/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _alertRulesInitialLoadDone = false;

  @override
  void initState() {
    super.initState();
  }

  void _loadAlertRulesIfNeeded(BuildContext context, PublicUser user) {
    if (_alertRulesInitialLoadDone) {
      return;
    }
    _alertRulesInitialLoadDone = true;
    context.read<AlertRulesCubit>().load(fallbackThresholdHf: user.thresholdHf);
  }

  Future<void> _refreshProfile(BuildContext context) async {
    await context.read<ProfileCubit>().refreshAll();
    if (!context.mounted) {
      return;
    }
    final user = context.read<ProfileCubit>().state.user;
    if (user != null) {
      await context.read<AlertRulesCubit>().load(fallbackThresholdHf: user.thresholdHf);
    }
  }

  Future<void> _onAlertRulesSaved(BuildContext context, AlertRulesState state) async {
    if (state.status != AlertRulesStatus.success) {
      return;
    }

    final loc = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.profileHfAlertsSaveSuccess)),
    );
    context.read<AlertRulesCubit>().clearMessages();

    final thresholdHf = state.globalRule?.thresholdHfValue;
    if (thresholdHf == null) {
      return;
    }

    final synced = await context.read<ProfileCubit>().syncLegacyThresholdHf(thresholdHf);
    if (!context.mounted || synced) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.profileHfAlertsLegacySyncFailed)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileCubit, ProfileState>(
          listenWhen: (previous, current) =>
              previous.lastSuccessMessage != current.lastSuccessMessage ||
              previous.errorMessage != current.errorMessage ||
              (previous.user == null && current.user != null),
          listener: (context, state) {
            if (state.user != null) {
              _loadAlertRulesIfNeeded(context, state.user!);
            }
            if (state.lastSuccessMessage != null && state.lastSuccessMessage!.isNotEmpty) {
              final message = _localizedSuccessMessage(
                AppLocalizations.of(context)!,
                state.lastSuccessMessage!,
              );
              if (message != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              }
              context.read<ProfileCubit>().clearMessages();
            }
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              final loc = AppLocalizations.of(context)!;
              final message = localizeApiError(
                loc,
                code: state.errorCode,
                message: state.errorMessage,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
              context.read<ProfileCubit>().clearMessages();
            }
          },
        ),
        BlocListener<AlertRulesCubit, AlertRulesState>(
          listenWhen: (previous, current) =>
              previous.status != current.status ||
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            if (state.status == AlertRulesStatus.success) {
              _onAlertRulesSaved(context, state);
              return;
            }
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              final loc = AppLocalizations.of(context)!;
              final message = state.errorMessage == kAlertRulesThresholdRangeErrorCode
                  ? loc.profileHfThresholdRangeError(
                      kMinHfThreshold.toStringAsFixed(2),
                      kMaxHfThreshold.toStringAsFixed(2),
                    )
                  : state.errorMessage!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
              context.read<AlertRulesCubit>().clearMessages();
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.profileTitle)),
        body: AuthenticatedFeatureGate(
          onAuthenticated: () => context.read<ProfileCubit>().load(),
          child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.profileStatus == ProfileViewStatus.loading && state.user == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.user == null) {
              if (state.profileStatus == ProfileViewStatus.error) {
                final loc = AppLocalizations.of(context)!;
                final message = localizeApiError(
                  loc,
                  code: state.errorCode,
                  message: state.errorMessage,
                );
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          message,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => context.read<ProfileCubit>().load(),
                          child: Text(loc.portfolioRetry),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Center(child: Text(AppLocalizations.of(context)!.profileLoadFailed));
            }
            return RefreshIndicator(
              onRefresh: () => _refreshProfile(context),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _UserInfoCard(user: state.user!),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: state.profileStatus == ProfileViewStatus.updating
                          ? null
                          : () => _showEditProfileDialog(context, state.user!),
                      icon: state.profileStatus == ProfileViewStatus.updating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.edit),
                      label: Text(AppLocalizations.of(context)!.editProfile),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ProfileHfAlertBlock(
                    isTelegramLinked: state.user!.isTelegramLinked,
                  ),
                  const SizedBox(height: 12),
                  ProfileTelegramBlock(
                    user: state.user!,
                    isBusy: state.profileStatus == ProfileViewStatus.updating,
                  ),
                  const SizedBox(height: 12),
                  _WalletsSection(
                    state: state,
                    onAddWallet: () => _showAddWalletDialog(context),
                    onEditWallet: (wallet) => _showEditWalletDialog(context, wallet),
                    onDeleteWallet: (wallet) => _confirmDeleteWallet(context, wallet),
                    onCopyAddress: (address) => _copyAddress(context, address),
                  ),
                  if (kIsWeb && isAppCacheResetSupported) ...[
                    const SizedBox(height: 24),
                    const _AppCacheResetSection(),
                  ],
                ],
              ),
            );
          },
        ),
        ),
      ),
    );
  }

  Future<void> _copyAddress(BuildContext context, String address) async {
    final loc = AppLocalizations.of(context)!;
    await Clipboard.setData(ClipboardData(text: address));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.copiedToClipboard)),
    );
  }

  Future<void> _showEditProfileDialog(BuildContext context, PublicUser user) async {
    final loc = AppLocalizations.of(context)!;
    final usernameController = TextEditingController(text: user.username ?? '');
    final firstNameController = TextEditingController(text: user.firstName ?? '');
    final lastNameController = TextEditingController(text: user.lastName ?? '');
    final languageController = TextEditingController(text: user.language ?? '');
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(loc.editProfile),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: languageController,
                  decoration: InputDecoration(labelText: loc.language),
                ),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: loc.username),
                ),
                TextField(
                  controller: firstNameController,
                  decoration: InputDecoration(labelText: loc.firstName),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: InputDecoration(labelText: loc.lastName),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(loc.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final patch = <String, Object?>{};
                _putIfChangedString(patch, 'language', user.language, languageController.text);
                _putIfChangedString(patch, 'username', user.username, usernameController.text);
                _putIfChangedString(patch, 'first_name', user.firstName, firstNameController.text);
                _putIfChangedString(patch, 'last_name', user.lastName, lastNameController.text);
                context.read<ProfileCubit>().updateProfile(patch);
                Navigator.pop(dialogContext);
              },
              child: Text(loc.save),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddWalletDialog(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final addressController = TextEditingController();
    final labelController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(loc.addWallet),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: loc.walletAddress),
              ),
              TextField(
                controller: labelController,
                decoration: InputDecoration(labelText: loc.walletLabel),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(loc.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final address = addressController.text.trim();
                final label = labelController.text.trim();
                final validation = _validateAddress(loc, address);
                if (validation != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(validation)));
                  return;
                }
                context.read<ProfileCubit>().addWallet(
                      address: address,
                      label: label.isEmpty ? null : label,
                    );
                Navigator.pop(dialogContext);
              },
              child: Text(loc.save),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditWalletDialog(BuildContext context, Wallet wallet) async {
    final loc = AppLocalizations.of(context)!;
    final labelController = TextEditingController(text: wallet.label ?? '');
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(loc.editWalletLabel),
          content: TextField(
            controller: labelController,
            decoration: InputDecoration(labelText: loc.walletLabel),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(loc.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final value = labelController.text.trim();
                context.read<ProfileCubit>().updateWalletLabel(
                      walletId: wallet.id,
                      label: value.isEmpty ? null : value,
                    );
                Navigator.pop(dialogContext);
              },
              child: Text(loc.save),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteWallet(BuildContext context, Wallet wallet) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(loc.deleteWallet),
          content: Text(loc.deleteWalletConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(loc.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(loc.delete),
            ),
          ],
        );
      },
    );
    if (confirmed == true && context.mounted) {
      context.read<ProfileCubit>().deleteWallet(wallet.id);
    }
  }

  void _putIfChangedString(
    Map<String, Object?> patch,
    String key,
    String? oldValue,
    String newValue,
  ) {
    final normalized = newValue.trim().isEmpty ? null : newValue.trim();
    if (oldValue != normalized) {
      patch[key] = normalized;
    }
  }

  String? _validateAddress(AppLocalizations loc, String address) {
    if (address.isEmpty) {
      return loc.walletAddressRequired;
    }
    if (!address.startsWith('0x')) {
      return loc.walletAddressStartWith0x;
    }
    if (address.length != 42) {
      return loc.walletAddressLengthHint;
    }
    return null;
  }
}

String? _localizedSuccessMessage(AppLocalizations loc, String key) {
  return switch (key) {
    ProfileSuccessMessageKey.profileUpdated => loc.profileUpdatedSuccess,
    ProfileSuccessMessageKey.publicAddressAdded => loc.publicAddressAddedSuccess,
    ProfileSuccessMessageKey.publicAddressLabelUpdated => loc.publicAddressLabelUpdatedSuccess,
    ProfileSuccessMessageKey.publicAddressRemoved => loc.publicAddressRemovedSuccess,
    ProfileSuccessMessageKey.telegramLinkCreated => loc.profileTelegramLinkCreatedSuccess,
    _ => null,
  };
}

class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard({required this.user});

  final PublicUser user;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim().isEmpty
                        ? loc.notSpecified
                        : '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoLine(label: loc.profileUserIdLabel, value: user.id?.toString() ?? loc.notSpecified),
            _InfoLine(
              label: loc.telegramId,
              value: user.telegramId?.toString() ?? loc.notSpecified,
            ),
            _InfoLine(label: loc.username, value: user.username ?? loc.notSpecified),
            _InfoLine(label: loc.email, value: user.email ?? loc.notSpecified),
            _InfoLine(
              label: loc.emailVerified,
              value: user.emailVerified == null
                  ? loc.notSpecified
                  : (user.emailVerified! ? loc.yes : loc.no),
            ),
            _InfoLine(label: loc.language, value: user.language ?? loc.notSpecified),
          ],
        ),
      ),
    );
  }
}

class _WalletsSection extends StatelessWidget {
  const _WalletsSection({
    required this.state,
    required this.onAddWallet,
    required this.onEditWallet,
    required this.onDeleteWallet,
    required this.onCopyAddress,
  });

  final ProfileState state;
  final VoidCallback onAddWallet;
  final ValueChanged<Wallet> onEditWallet;
  final ValueChanged<Wallet> onDeleteWallet;
  final ValueChanged<String> onCopyAddress;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final wallets = state.wallets;
    final status = state.walletsStatus;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(loc.walletsTitle, style: Theme.of(context).textTheme.titleMedium),
                ),
                IconButton(onPressed: onAddWallet, icon: const Icon(Icons.add)),
              ],
            ),
            if (status == WalletsViewStatus.loading && wallets.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (status != WalletsViewStatus.loading && wallets.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Text(loc.walletsEmpty),
                    const SizedBox(height: 8),
                    OutlinedButton(onPressed: onAddWallet, child: Text(loc.addWallet)),
                  ],
                ),
              ),
            ...wallets.map((wallet) {
              final isBusy = state.activeWalletId == wallet.id &&
                  (status == WalletsViewStatus.updating || status == WalletsViewStatus.deleting);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(wallet.label ?? loc.notSpecified),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_shortAddress(wallet.address)),
                    Text('${loc.createdAt}: ${wallet.createdAt ?? loc.notSpecified}'),
                  ],
                ),
                trailing: isBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Wrap(
                        spacing: 4,
                        children: [
                          IconButton(
                            onPressed: () => onCopyAddress(wallet.address),
                            icon: const Icon(Icons.copy, size: 18),
                          ),
                          IconButton(
                            onPressed: () => onEditWallet(wallet),
                            icon: const Icon(Icons.edit, size: 18),
                          ),
                          IconButton(
                            onPressed: () => onDeleteWallet(wallet),
                            icon: const Icon(Icons.delete, size: 18),
                          ),
                        ],
                      ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _shortAddress(String address) {
    if (address.length <= 12) {
      return address;
    }
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
}

class _AppCacheResetSection extends StatelessWidget {
  const _AppCacheResetSection();

  Future<void> _confirmAndReset(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(loc.appCacheResetConfirmTitle),
          content: Text(loc.appCacheResetConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(loc.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(loc.appCacheResetConfirmAction),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    await resetAppCache(clearAuthTokens: () => di<AuthTokenStore>().clear());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc.appCacheReset,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              loc.appCacheResetConfirmMessage,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _confirmAndReset(context),
                icon: const Icon(Icons.cached_outlined),
                label: Text(loc.appCacheReset),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
