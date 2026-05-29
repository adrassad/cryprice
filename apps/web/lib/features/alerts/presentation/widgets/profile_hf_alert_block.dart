import 'package:cryprice_frontend/features/alerts/presentation/cubit/alert_rules_cubit.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alert_rules_state.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileHfAlertBlock extends StatefulWidget {
  const ProfileHfAlertBlock({
    super.key,
    required this.isTelegramLinked,
  });

  final bool isTelegramLinked;

  @override
  State<ProfileHfAlertBlock> createState() => _ProfileHfAlertBlockState();
}

class _ProfileHfAlertBlockState extends State<ProfileHfAlertBlock> {
  late final TextEditingController _thresholdController;

  @override
  void initState() {
    super.initState();
    _thresholdController = TextEditingController(
      text: context.read<AlertRulesCubit>().state.thresholdInput,
    );
  }

  @override
  void dispose() {
    _thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocConsumer<AlertRulesCubit, AlertRulesState>(
      listenWhen: (previous, current) => previous.thresholdInput != current.thresholdInput,
      listener: (context, state) {
        if (_thresholdController.text != state.thresholdInput) {
          _thresholdController.value = TextEditingValue(
            text: state.thresholdInput,
            selection: TextSelection.collapsed(offset: state.thresholdInput.length),
          );
        }
      },
      builder: (context, state) {
        final isLoading =
            state.status == AlertRulesStatus.initial || state.status == AlertRulesStatus.loading;
        final isSaving = state.status == AlertRulesStatus.saving;
        final isInteractive = !isLoading && !isSaving;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.profileHfAlertsTitle,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.profileHfAlertsDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(loc.profileHfAlertsEnabled),
                    value: state.enabled,
                    onChanged: isInteractive
                        ? (value) => context.read<AlertRulesCubit>().setEnabled(value)
                        : null,
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _thresholdController,
                    enabled: isInteractive,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: InputDecoration(
                      labelText: loc.thresholdHf,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: context.read<AlertRulesCubit>().setThresholdInput,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.profileHfAlertsHelper,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (!widget.isTelegramLinked) ...[
                    const SizedBox(height: 12),
                    _TelegramWarningNote(message: loc.profileHfAlertsTelegramWarning),
                  ],
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : () => context.read<AlertRulesCubit>().save(),
                      child: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(loc.save),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TelegramWarningNote extends StatelessWidget {
  const _TelegramWarningNote({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
