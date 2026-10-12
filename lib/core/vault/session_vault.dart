import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

/// Represents a single stored Telegram account session inside the Vault.
class VaultAccount {
  final String accountId;
  final String phoneNumber;
  final String displayName;
  final String? username;
  final String? avatarUrl;
  final String sessionString; // Serialized MTProto auth key / TDLib database path
  final DateTime createdAt;
  final DateTime lastActiveAt;

  VaultAccount({
    required this.accountId,
    required this.phoneNumber,
    required this.displayName,
    this.username,
    this.avatarUrl,
    required this.sessionString,
    required this.createdAt,
    required this.lastActiveAt,
  });

  Map<String, dynamic> toJson() => {
        'accountId': accountId,
        'phoneNumber': phoneNumber,
        'displayName': displayName,
        'username': username,
        'avatarUrl': avatarUrl,
        'sessionString': sessionString,
        'createdAt': createdAt.toIso8601String(),
        'lastActiveAt': lastActiveAt.toIso8601String(),
      };

  factory VaultAccount.fromJson(Map<String, dynamic> json) => VaultAccount(
        accountId: json['accountId'] as String,
        phoneNumber: json['phoneNumber'] as String,
        displayName: json['displayName'] as String,
        username: json['username'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        sessionString: json['sessionString'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      );
}

/// The encrypted vault that holds all user Telegram accounts without requiring OTPs.
/// Decrypted once using Master Password / PIN.
class SessionVault {
  static const String currentVaultVersion = '1.0';

  final Map<String, VaultAccount> _accounts = {};
  bool _isUnlocked = false;
  String? _unlockedWithMasterPin;

  bool get isUnlocked => _isUnlocked;
  List<VaultAccount> get accounts => _accounts.values.toList();
  int get accountCount => _accounts.length;

  /// Unlock vault using the master PIN or password
  Future<bool> unlockWithPin(String pin, {String? encryptedPayload}) async {
    // Default master PIN for setup / demo is '000000'
    if (pin.isEmpty) return false;

    if (encryptedPayload != null && encryptedPayload.isNotEmpty) {
      try {
        final decryptedJson = decryptVaultPayload(encryptedPayload, pin);
        final data = jsonDecode(decryptedJson) as Map<String, dynamic>;
        final list = (data['accounts'] as List<dynamic>?) ?? [];
        _accounts.clear();
        for (final item in list) {
          final acc = VaultAccount.fromJson(item as Map<String, dynamic>);
          _accounts[acc.accountId] = acc;
        }
      } catch (e) {
        return false;
      }
    }

    _isUnlocked = true;
    _unlockedWithMasterPin = pin;
    return true;
  }

  /// Lock vault
  void lock() {
    _isUnlocked = false;
    _unlockedWithMasterPin = null;
    _accounts.clear();
  }

  /// Store or update an account session
  void saveAccount(VaultAccount account) {
    _accounts[account.accountId] = account;
  }

  /// Remove an account session
  void removeAccount(String accountId) {
    _accounts.remove(accountId);
  }

  /// Get specific account
  VaultAccount? getAccount(String accountId) => _accounts[accountId];

  /// Export the vault into an encrypted string payload for backup / cloud sync
  String exportEncryptedPayload({String? overridePin}) {
    final pin = overridePin ?? _unlockedWithMasterPin ?? '000000';
    final data = {
      'version': currentVaultVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'accounts': _accounts.values.map((a) => a.toJson()).toList(),
    };
    final jsonStr = jsonEncode(data);
    return encryptVaultPayload(jsonStr, pin);
  }

  /// AES-256 Encryption using PBKDF2 derived key
  static String encryptVaultPayload(String plainText, String password) {
    final salt = Uint8List.fromList(utf8.encode('foggygram_vault_salt_v1'));
    final key = _deriveKey(password, salt);
    final iv = Uint8List(16); // 16-byte initialization vector

    final cipher = CBCBlockCipher(AESEngine());
    final params = ParametersWithIV(KeyParameter(key), iv);
    final paddedParams = PaddedBlockCipherParameters(params, null);
    final paddedCipher = PaddedBlockCipherImpl(PKCS7Padding(), cipher);
    paddedCipher.init(true, paddedParams);

    final inputBytes = Uint8List.fromList(utf8.encode(plainText));
    final encryptedBytes = paddedCipher.process(inputBytes);

    return base64Encode(encryptedBytes);
  }

  /// AES-256 Decryption using PBKDF2 derived key
  static String decryptVaultPayload(String encryptedBase64, String password) {
    final salt = Uint8List.fromList(utf8.encode('foggygram_vault_salt_v1'));
    final key = _deriveKey(password, salt);
    final iv = Uint8List(16);

    final cipher = CBCBlockCipher(AESEngine());
    final params = ParametersWithIV(KeyParameter(key), iv);
    final paddedParams = PaddedBlockCipherParameters(params, null);
    final paddedCipher = PaddedBlockCipherImpl(PKCS7Padding(), cipher);
    paddedCipher.init(false, paddedParams);

    final encryptedBytes = base64Decode(encryptedBase64);
    final decryptedBytes = paddedCipher.process(Uint8List.fromList(encryptedBytes));

    return utf8.decode(decryptedBytes);
  }

  static Uint8List _deriveKey(String password, Uint8List salt) {
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    final params = Pbkdf2Parameters(salt, 10000, 32);
    derivator.init(params);
    return derivator.process(Uint8List.fromList(utf8.encode(password)));
  }
}
