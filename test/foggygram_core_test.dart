import 'package:flutter_test/flutter_test.dart';
import 'package:foggygram/core/vault/session_vault.dart';
import 'package:foggygram/core/ghost/ghost_service.dart';
import 'package:foggygram/core/deleted_cache/deleted_message_store.dart';
import 'package:foggygram/core/ai_agent/foggy_agent_service.dart';

void main() {
  group('SessionVault Tests', () {
    test('Encrypts and decrypts multiple accounts with master PIN without OTP', () async {
      final vault = SessionVault();

      // Add 2 mock accounts
      vault.saveAccount(VaultAccount(
        accountId: 'acc_1',
        phoneNumber: '+15550192834',
        displayName: 'Alex Chen',
        sessionString: 'auth_key_blob_account_1',
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      ));

      vault.saveAccount(VaultAccount(
        accountId: 'acc_2',
        phoneNumber: '+15554829102',
        displayName: 'Work Phone',
        sessionString: 'auth_key_blob_account_2',
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      ));

      expect(vault.accountCount, equals(2));

      // Export payload encrypted with PIN '000000'
      final encryptedPayload = vault.exportEncryptedPayload(overridePin: '000000');
      expect(encryptedPayload.isNotEmpty, isTrue);

      // Create new fresh vault on a new device/session
      final newVault = SessionVault();
      expect(newVault.isUnlocked, isFalse);

      // Attempt unlock with wrong PIN
      final failUnlock = await newVault.unlockWithPin('123456', encryptedPayload: encryptedPayload);
      expect(failUnlock, isFalse);
      expect(newVault.accountCount, equals(0));

      // Unlock with correct master PIN
      final successUnlock = await newVault.unlockWithPin('000000', encryptedPayload: encryptedPayload);
      expect(successUnlock, isTrue);
      expect(newVault.isUnlocked, isTrue);
      expect(newVault.accountCount, equals(2));
      expect(newVault.getAccount('acc_1')?.displayName, equals('Alex Chen'));
      expect(newVault.getAccount('acc_2')?.displayName, equals('Work Phone'));
    });
  });

  group('GhostService Tests', () {
    test('Blocks read receipts when ghost mode is active', () {
      final ghost = GhostService();
      ghost.isGhostModeEnabled = true;
      ghost.suppressReadReceipts = true;

      // Receipts should be blocked
      expect(ghost.shouldSendReadReceipt('chat_123'), isFalse);

      // Per-chat override: disable ghost for specific friend
      ghost.setGhostForChat('chat_friend', false);
      expect(ghost.shouldSendReadReceipt('chat_friend'), isTrue);
      expect(ghost.shouldSendReadReceipt('chat_123'), isFalse);
    });
  });

  group('DeletedMessageStore Tests', () {
    test('Preserves deleted message in local cache with metadata', () {
      final store = DeletedMessageStore();

      store.recordDeletedMessage(
        messageId: 'msg_999',
        chatId: 'chat_456',
        senderName: 'Maya',
        originalText: 'Secret meeting at 5 PM',
        sentAt: DateTime.now().subtract(const Duration(minutes: 10)),
      );

      expect(store.isDeleted('msg_999'), isTrue);
      final record = store.getRecord('msg_999');
      expect(record, isNotNull);
      expect(record!.originalText, equals('Secret meeting at 5 PM'));
      expect(record.senderName, equals('Maya'));
    });
  });

  group('FoggyAgentService Tests', () {
    test('Autonomously configures ghost protocol via natural language', () async {
      final agent = FoggyAgentService();
      final ghost = GhostService();

      ghost.isGhostModeEnabled = false;

      // Natural language command: "Foggy, activate ghost mode"
      final result = await agent.executeInstruction(
        'Foggy, activate ghost mode for me',
        ghostService: ghost,
      );

      expect(result.success, isTrue);
      expect(ghost.isGhostModeEnabled, isTrue);
      expect(ghost.suppressReadReceipts, isTrue);
    });

    test('Autonomously exports session vault via natural language', () async {
      final agent = FoggyAgentService();
      final vault = SessionVault();

      vault.saveAccount(VaultAccount(
        accountId: 'acc_test',
        phoneNumber: '+1999888777',
        displayName: 'Backup User',
        sessionString: 'test_auth_key',
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      ));

      final result = await agent.executeInstruction(
        'Please backup my vault sessions',
        vault: vault,
      );

      expect(result.success, isTrue);
      expect(result.data?['encryptedPayload'], isNotNull);
    });
  });
}
