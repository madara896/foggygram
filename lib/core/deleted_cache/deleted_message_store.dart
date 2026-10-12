/// Local persistent cache that prevents Telegram messages from ever being deleted or hidden.
/// When someone deletes a message or edits it, Foggygram marks it as deleted/edited
/// and preserves the original content for review.
class DeletedMessageRecord {
  final String messageId;
  final String chatId;
  final String senderName;
  final String originalText;
  final DateTime sentAt;
  final DateTime deletedAt;
  final bool wasEdited;
  final String? editedText;

  DeletedMessageRecord({
    required this.messageId,
    required this.chatId,
    required this.senderName,
    required this.originalText,
    required this.sentAt,
    required this.deletedAt,
    this.wasEdited = false,
    this.editedText,
  });

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'chatId': chatId,
        'senderName': senderName,
        'originalText': originalText,
        'sentAt': sentAt.toIso8601String(),
        'deletedAt': deletedAt.toIso8601String(),
        'wasEdited': wasEdited,
        'editedText': editedText,
      };

  factory DeletedMessageRecord.fromJson(Map<String, dynamic> json) =>
      DeletedMessageRecord(
        messageId: json['messageId'] as String,
        chatId: json['chatId'] as String,
        senderName: json['senderName'] as String,
        originalText: json['originalText'] as String,
        sentAt: DateTime.parse(json['sentAt'] as String),
        deletedAt: DateTime.parse(json['deletedAt'] as String),
        wasEdited: (json['wasEdited'] as bool?) ?? false,
        editedText: json['editedText'] as String?,
      );
}

class DeletedMessageStore {
  static final DeletedMessageStore _instance = DeletedMessageStore._internal();
  factory DeletedMessageStore() => _instance;
  DeletedMessageStore._internal();

  /// Map of messageId -> DeletedMessageRecord
  final Map<String, DeletedMessageRecord> _deletedMessages = {};

  List<DeletedMessageRecord> get allRecovered => _deletedMessages.values.toList();

  List<DeletedMessageRecord> getForChat(String chatId) {
    return _deletedMessages.values
        .where((record) => record.chatId == chatId)
        .toList();
  }

  bool isDeleted(String messageId) => _deletedMessages.containsKey(messageId);

  DeletedMessageRecord? getRecord(String messageId) => _deletedMessages[messageId];

  /// Intercepts message deletion from MTProto / TDLib update
  void recordDeletedMessage({
    required String messageId,
    required String chatId,
    required String senderName,
    required String originalText,
    required DateTime sentAt,
  }) {
    _deletedMessages[messageId] = DeletedMessageRecord(
      messageId: messageId,
      chatId: chatId,
      senderName: senderName,
      originalText: originalText,
      sentAt: sentAt,
      deletedAt: DateTime.now(),
    );
  }

  /// Intercepts message edits so original version is never lost
  void recordEditedMessage({
    required String messageId,
    required String chatId,
    required String senderName,
    required String originalText,
    required String newText,
    required DateTime sentAt,
  }) {
    _deletedMessages[messageId] = DeletedMessageRecord(
      messageId: messageId,
      chatId: chatId,
      senderName: senderName,
      originalText: originalText,
      sentAt: sentAt,
      deletedAt: DateTime.now(),
      wasEdited: true,
      editedText: newText,
    );
  }
}
