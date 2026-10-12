/// Manages stealth / ghost settings for Foggygram (AyuGram-style features).
class GhostService {
  static final GhostService _instance = GhostService._internal();
  factory GhostService() => _instance;
  GhostService._internal();

  /// Global master toggle for Ghost Mode
  bool isGhostModeEnabled = true;

  /// If true, reading a message does NOT send read receipts to the sender.
  bool suppressReadReceipts = true;

  /// If true, being in the app never broadcasts "Online" status to Telegram servers.
  bool suppressOnlineStatus = true;

  /// If true, typing in the input box never sends "typing..." updates.
  bool suppressTypingNotification = true;

  /// If true, watching stories will not register your user ID in story views.
  bool viewStoriesInvisibly = true;

  /// Per-chat ghost mode override map (chatId -> enabled)
  final Map<String, bool> _chatOverrides = {};

  bool isGhostForChat(String chatId) {
    if (_chatOverrides.containsKey(chatId)) {
      return _chatOverrides[chatId]!;
    }
    return isGhostModeEnabled;
  }

  void setGhostForChat(String chatId, bool enabled) {
    _chatOverrides[chatId] = enabled;
  }

  /// Hook to call when user views a message.
  /// Returns `true` if the read receipt should be sent to Telegram, `false` to intercept and drop.
  bool shouldSendReadReceipt(String chatId) {
    if (!isGhostForChat(chatId)) return true;
    return !suppressReadReceipts;
  }
}
