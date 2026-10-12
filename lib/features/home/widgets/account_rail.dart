import 'package:flutter/material.dart';
import 'package:foggygram/core/theme/foggy_theme.dart';
import 'package:foggygram/features/models/chat_models.dart';
import 'package:foggygram/shared/widgets/widgets.dart';

/// AccountRail represents the leftmost 64px vertical strip in macOS layout
/// allowing swift switching between multiple encrypted Telegram accounts.
class AccountRail extends StatelessWidget {
  final List<MockAccount> accounts;
  final String activeAccountId;
  final ValueChanged<String> onSelectAccount;
  final VoidCallback onAddAccount;
  final VoidCallback onOpenSettings;

  const AccountRail({
    super.key,
    required this.accounts,
    required this.activeAccountId,
    required this.onSelectAccount,
    required this.onAddAccount,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // App Logo / Mascot icon
          Tooltip(
            message: 'Foggygram',
            child: SizedBox(
              width: 44,
              height: 44,
              child: OverflowBox(
                maxWidth: 160,
                maxHeight: 160,
                child: Transform.scale(
                  scale: 0.25,
                  child: const FoggyCloudMascot(
                    scale: 1.0,
                    enableBobbing: false,
                    enableMouseTracking: false,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 32,
            height: 1,
            color: Colors.white.withOpacity(0.06),
          ),
          const SizedBox(height: 16),

          // Accounts list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: accounts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final account = accounts[index];
                final isActive = account.id == activeAccountId;

                return Tooltip(
                  message: '${account.name}\n${account.phone}',
                  child: GestureDetector(
                    onTap: () => onSelectAccount(account.id),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.25),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: FrostAvatar(
                        size: 40,
                        name: account.name,
                        border: Border.all(
                          color: isActive
                              ? Colors.white.withOpacity(0.50)
                              : Colors.white.withOpacity(0.10),
                          width: isActive ? 2.0 : 1.0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom action buttons: Add Account & Settings
          Tooltip(
            message: 'Add Telegram Account',
            child: InkWell(
              onTap: onAddAccount,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                  border: Border.all(color: Colors.white.withOpacity(0.10)),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 20,
                  color: FoggyColors.text,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Tooltip(
            message: 'Vault & App Settings',
            child: InkWell(
              onTap: onOpenSettings,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                  border: Border.all(color: Colors.white.withOpacity(0.10)),
                ),
                child: Icon(
                  Icons.settings_outlined,
                  size: 19,
                  color: FoggyColors.muted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
