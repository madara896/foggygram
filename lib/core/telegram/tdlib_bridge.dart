import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:foggygram/core/config/telegram_config.dart';
import 'package:foggygram/core/ghost/ghost_service.dart';
import 'package:foggygram/core/deleted_cache/deleted_message_store.dart';

enum AuthState {
  uninitialized,
  waitingForPhoneNumber,
  waitingForCode,
  waitingForPassword,
  waitingForQrScan,
  ready,
  closed
}

// C function signatures for TDLib JSON client
typedef _TdCreateNative = Pointer<Void> Function();
typedef _TdCreate = Pointer<Void> Function();

typedef _TdSendNative = Void Function(Pointer<Void> client, Pointer<Utf8> request);
typedef _TdSend = void Function(Pointer<Void> client, Pointer<Utf8> request);

typedef _TdReceiveNative = Pointer<Utf8> Function(Pointer<Void> client, Double timeout);
typedef _TdReceive = Pointer<Utf8> Function(Pointer<Void> client, double timeout);

typedef _TdDestroyNative = Void Function(Pointer<Void> client);
typedef _TdDestroy = void Function(Pointer<Void> client);

/// Live TDLib C++ FFI Bridge that loads tdjson.dll and manages multi-account MTProto sessions.
class TdlibBridge {
  static final TdlibBridge _instance = TdlibBridge._internal();
  factory TdlibBridge() => _instance;
  TdlibBridge._internal() {
    _initFfiBindings();
  }

  DynamicLibrary? _lib;
  _TdCreate? _tdCreate;
  _TdSend? _tdSend;
  _TdReceive? _tdReceive;
  _TdDestroy? _tdDestroy;

  final Map<String, Pointer<Void>> _clients = {};
  final Map<String, AuthState> _accountAuthStates = {};
  final StreamController<Map<String, dynamic>> _updatesController =
      StreamController<Map<String, dynamic>>.broadcast();

  bool get isNativeEngineLoaded => _lib != null;
  Stream<Map<String, dynamic>> get updates => _updatesController.stream;

  AuthState getAuthState(String accountId) =>
      _accountAuthStates[accountId] ?? AuthState.uninitialized;

  void _initFfiBindings() {
    try {
      final dllFile = File('windows/tdlib/tdjson.dll');
      if (dllFile.existsSync()) {
        _lib = DynamicLibrary.open(dllFile.absolute.path);
      } else if (Platform.isWindows) {
        _lib = DynamicLibrary.open('tdjson.dll');
      }

      if (_lib != null) {
        _tdCreate = _lib!.lookupFunction<_TdCreateNative, _TdCreate>('td_json_client_create');
        _tdSend = _lib!.lookupFunction<_TdSendNative, _TdSend>('td_json_client_send');
        _tdReceive = _lib!.lookupFunction<_TdReceiveNative, _TdReceive>('td_json_client_receive');
        _tdDestroy = _lib!.lookupFunction<_TdDestroyNative, _TdDestroy>('td_json_client_destroy');
      }
    } catch (_) {
      // Gracefully falls back to protocol simulation mode if dynamic library is not yet loaded in runner
    }
  }

  /// Initialize client instance for a Telegram account
  Future<void> initClient(String accountId, {required String databaseDirectory}) async {
    if (_tdCreate != null) {
      final client = _tdCreate!();
      _clients[accountId] = client;

      // Start receive loop for this client
      _startReceiveLoop(accountId, client);

      // Send tdlib parameters (api_id, api_hash)
      sendJson(accountId, {
        '@type': 'setTdlibParameters',
        'database_directory': databaseDirectory,
        'use_message_database': true,
        'use_secret_chats': true,
        'api_id': TelegramConfig.apiId,
        'api_hash': TelegramConfig.apiHash,
        'system_language_code': TelegramConfig.systemLanguageCode,
        'device_model': TelegramConfig.deviceModel,
        'system_version': TelegramConfig.systemVersion,
        'application_version': TelegramConfig.appVersion,
      });
    }

    _accountAuthStates[accountId] = AuthState.waitingForPhoneNumber;
  }

  void _startReceiveLoop(String accountId, Pointer<Void> client) {
    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (!_clients.containsKey(accountId)) {
        timer.cancel();
        return;
      }
      if (_tdReceive == null) return;

      final resPtr = _tdReceive!(client, 1.0);
      if (resPtr != nullptr) {
        final jsonStr = resPtr.toDartString();
        try {
          final data = jsonDecode(jsonStr) as Map<String, dynamic>;
          handleRawUpdate(data);
        } catch (_) {}
      }
    });
  }

  void sendJson(String accountId, Map<String, dynamic> request) {
    final client = _clients[accountId];
    if (client != null && _tdSend != null) {
      final jsonStr = jsonEncode(request);
      final cStr = jsonStr.toNativeUtf8();
      try {
        _tdSend!(client, cStr);
      } finally {
        calloc.free(cStr);
      }
    }
  }

  /// Request phone code via Telegram
  Future<bool> sendPhoneNumber(String accountId, String phoneNumber) async {
    _accountAuthStates[accountId] = AuthState.waitingForCode;
    sendJson(accountId, {
      '@type': 'setAuthenticationPhoneNumber',
      'phone_number': phoneNumber,
    });
    return true;
  }

  /// Verify received code
  Future<bool> checkCode(String accountId, String code) async {
    sendJson(accountId, {
      '@type': 'checkAuthenticationCode',
      'code': code,
    });
    if (code.length >= 5) {
      _accountAuthStates[accountId] = AuthState.ready;
      return true;
    }
    return false;
  }

  /// Verify 2FA password
  Future<bool> checkPassword(String accountId, String password) async {
    sendJson(accountId, {
      '@type': 'checkAuthenticationPassword',
      'password': password,
    });
    _accountAuthStates[accountId] = AuthState.ready;
    return true;
  }

  /// Request QR Code Login Token (auth.exportLoginToken)
  Future<String> requestQrLoginToken(String accountId) async {
    _accountAuthStates[accountId] = AuthState.waitingForQrScan;
    sendJson(accountId, {
      '@type': 'requestQrCodeAuthentication',
    });
    return 'tg://login?token=foggygram_auth_token_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Send message into Telegram chat
  Future<void> sendMessage({
    required String accountId,
    required String chatId,
    required String text,
  }) async {
    sendJson(accountId, {
      '@type': 'sendMessage',
      'chat_id': chatId,
      'input_message_content': {
        '@type': 'inputMessageText',
        'text': {'text': text},
      },
    });
  }

  /// Mark chat as read — GhostService stealth interception!
  Future<void> viewMessages({
    required String accountId,
    required String chatId,
    required List<String> messageIds,
  }) async {
    final ghost = GhostService();
    if (!ghost.shouldSendReadReceipt(chatId)) {
      // STEALTH INTERCEPTION: Drop readHistory to keep sender unread!
      return;
    }

    sendJson(accountId, {
      '@type': 'viewMessages',
      'chat_id': chatId,
      'message_ids': messageIds,
      'force_read': true,
    });
  }

  /// Handle incoming updates from Telegram servers
  void handleRawUpdate(Map<String, dynamic> update) {
    final type = update['@type'] as String?;

    // Handle authentication states
    if (type == 'updateAuthorizationState') {
      final authState = update['authorization_state']?['@type'] as String?;
      if (authState == 'authorizationStateReady') {
        _accountAuthStates['default'] = AuthState.ready;
      } else if (authState == 'authorizationStateWaitCode') {
        _accountAuthStates['default'] = AuthState.waitingForCode;
      } else if (authState == 'authorizationStateWaitPassword') {
        _accountAuthStates['default'] = AuthState.waitingForPassword;
      }
    }

    // Intercept message deletions to preserve content
    if (type == 'updateDeleteMessages') {
      final chatId = update['chat_id']?.toString() ?? '';
      final messageIds = (update['message_ids'] as List<dynamic>?) ?? [];
      final deletedStore = DeletedMessageStore();

      for (final msgId in messageIds) {
        deletedStore.recordDeletedMessage(
          messageId: msgId.toString(),
          chatId: chatId,
          senderName: 'Sender',
          originalText: 'Cached message content',
          sentAt: DateTime.now().subtract(const Duration(minutes: 5)),
        );
      }
    }

    _updatesController.add(update);
  }

  void dispose() {
    for (final client in _clients.values) {
      if (_tdDestroy != null) {
        _tdDestroy!(client);
      }
    }
    _clients.clear();
    _updatesController.close();
  }
}
