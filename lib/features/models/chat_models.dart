class MockAccount {
  final String id;
  final String name;
  final String phone;
  final String? avatarUrl;

  const MockAccount({
    required this.id,
    required this.name,
    required this.phone,
    this.avatarUrl,
  });

  static const List<MockAccount> initialAccounts = [
    MockAccount(
      id: 'acc_personal',
      name: 'Personal',
      phone: '+1 555 019 2834',
      avatarUrl: null,
    ),
    MockAccount(
      id: 'acc_work',
      name: 'Work',
      phone: '+1 555 482 9102',
      avatarUrl: null,
    ),
    MockAccount(
      id: 'acc_dev',
      name: 'Dev',
      phone: '+1 555 773 4019',
      avatarUrl: null,
    ),
  ];
}

class MockChat {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final bool isGroup;
  final bool isMuted;
  final bool isPinned;
  final String? avatarUrl;
  final String? category; // 'Private', 'Groups', 'Channels'

  const MockChat({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isGroup = false,
    this.isMuted = false,
    this.isPinned = false,
    this.avatarUrl,
    this.category,
  });

  static const List<MockChat> initialChats = [
    MockChat(
      id: 'chat_1',
      name: 'Alex Chen',
      lastMessage: 'The new glass UI build looks incredible! 🌫️',
      time: '12:42 PM',
      unreadCount: 3,
      isOnline: true,
      category: 'Private',
      isPinned: true,
    ),
    MockChat(
      id: 'chat_2',
      name: 'Elena Rostova',
      lastMessage: 'Can you verify the encrypted vault session?',
      time: '11:15 AM',
      unreadCount: 1,
      isOnline: true,
      category: 'Private',
      isPinned: true,
    ),
    MockChat(
      id: 'chat_3',
      name: 'Foggygram Devs',
      lastMessage: 'Release v1.4 tag pushed to origin with TDLib ffi bindings',
      time: '10:30 AM',
      unreadCount: 8,
      isGroup: true,
      category: 'Groups',
      isPinned: true,
    ),
    MockChat(
      id: 'chat_4',
      name: 'Telegram News & Radar',
      lastMessage: 'Telegram API update introduces new stories parameters',
      time: '9:05 AM',
      unreadCount: 0,
      category: 'Channels',
    ),
    MockChat(
      id: 'chat_5',
      name: 'Sophia Laurent',
      lastMessage: 'Let\'s catch up later about ghost mode test results.',
      time: 'Yesterday',
      unreadCount: 0,
      isOnline: false,
      category: 'Private',
    ),
    MockChat(
      id: 'chat_6',
      name: 'Design Systems Syndicate',
      lastMessage: 'Blur radius 24 with 6% white opacity gives the optimal depth',
      time: 'Yesterday',
      unreadCount: 0,
      isGroup: true,
      category: 'Groups',
    ),
    MockChat(
      id: 'chat_7',
      name: 'Marcus Vance',
      lastMessage: 'Sent you the decrypted sqlite schema dump',
      time: 'Oct 11',
      unreadCount: 0,
      category: 'Private',
    ),
    MockChat(
      id: 'chat_8',
      name: 'Rust & TDLib Core',
      lastMessage: 'Cross-compiling libtdjson.dll for x86_64 Windows runtime',
      time: 'Oct 10',
      unreadCount: 0,
      isGroup: true,
      category: 'Groups',
    ),
    MockChat(
      id: 'chat_9',
      name: 'Crypto & Privacy Tech',
      lastMessage: 'AES-256-GCM hardware acceleration benchmark comparison',
      time: 'Oct 09',
      unreadCount: 0,
      category: 'Channels',
    ),
    MockChat(
      id: 'chat_10',
      name: 'Liam Zhang',
      lastMessage: 'Does the cloud mascot track cursor smoothly on 144Hz monitors?',
      time: 'Oct 08',
      unreadCount: 0,
      isOnline: true,
      category: 'Private',
    ),
    MockChat(
      id: 'chat_11',
      name: 'Secret Operations',
      lastMessage: 'Ghost mode enabled: read receipts suppressed completely.',
      time: 'Oct 07',
      unreadCount: 0,
      isGroup: true,
      category: 'Groups',
    ),
    MockChat(
      id: 'chat_12',
      name: 'Flutter Desktop Community',
      lastMessage: 'Windows backdrop blur acrylic acrylic effects showcase',
      time: 'Oct 05',
      unreadCount: 0,
      category: 'Channels',
    ),
  ];
}

class MockMessage {
  final String id;
  final String text;
  final String time;
  final bool isOutgoing;
  final bool isRead;
  final String? senderName;
  final String? replyToText;
  final bool isDeleted;
  final String? deletedOriginalText;

  const MockMessage({
    required this.id,
    required this.text,
    required this.time,
    required this.isOutgoing,
    this.isRead = true,
    this.senderName,
    this.replyToText,
    this.isDeleted = false,
    this.deletedOriginalText,
  });

  MockMessage copyWith({
    String? id,
    String? text,
    String? time,
    bool? isOutgoing,
    bool? isRead,
    String? senderName,
    String? replyToText,
    bool? isDeleted,
    String? deletedOriginalText,
  }) {
    return MockMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      time: time ?? this.time,
      isOutgoing: isOutgoing ?? this.isOutgoing,
      isRead: isRead ?? this.isRead,
      senderName: senderName ?? this.senderName,
      replyToText: replyToText ?? this.replyToText,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedOriginalText: deletedOriginalText ?? this.deletedOriginalText,
    );
  }

  static const List<MockMessage> initialMessagesChat1 = [
    MockMessage(
      id: 'm1',
      text: 'Hey! Have you had a chance to test Foggygram on Windows 11?',
      time: '12:15 PM',
      isOutgoing: false,
      senderName: 'Alex Chen',
    ),
    MockMessage(
      id: 'm2',
      text: 'Yes! Just spun up the latest build with the pure monochrome glassmorphism palette.',
      time: '12:18 PM',
      isOutgoing: true,
      isRead: true,
    ),
    MockMessage(
      id: 'm3',
      text: 'The acrylic blur and 160deg gradients look so smooth. How is TDLib performing?',
      time: '12:20 PM',
      isOutgoing: false,
      senderName: 'Alex Chen',
      replyToText: 'Just spun up the latest build with the pure monochrome glassmorphism palette.',
    ),
    MockMessage(
      id: 'm4',
      text: 'Near-instant synchronization. SQLite encrypted vault keeps local sessions isolated.',
      time: '12:22 PM',
      isOutgoing: true,
      isRead: true,
    ),
    MockMessage(
      id: 'm5',
      text: 'Check this deleted message behavior when someone un-sends in a channel.',
      time: '12:25 PM',
      isOutgoing: false,
      senderName: 'Alex Chen',
    ),
    MockMessage(
      id: 'm6',
      text: 'This message was deleted',
      time: '12:26 PM',
      isOutgoing: false,
      senderName: 'Alex Chen',
      isDeleted: true,
      deletedOriginalText: 'I thought about adding accent colors, but pure monochrome looks 10x sleeker.',
    ),
    MockMessage(
      id: 'm7',
      text: 'Foggygram cached it locally before the revocation payload arrived!',
      time: '12:28 PM',
      isOutgoing: true,
      isRead: true,
    ),
    MockMessage(
      id: 'm8',
      text: 'Ghost mode is also working seamlessly. I can preview voice notes and stories completely unseen.',
      time: '12:30 PM',
      isOutgoing: true,
      isRead: true,
    ),
    MockMessage(
      id: 'm9',
      text: 'That is huge for telegram power users. What about the embedded AI assistant?',
      time: '12:33 PM',
      isOutgoing: false,
      senderName: 'Alex Chen',
    ),
    MockMessage(
      id: 'm10',
      text: 'It can summarize unread chat history, compose contextual replies, and translate on the fly.',
      time: '12:35 PM',
      isOutgoing: true,
      isRead: true,
    ),
    MockMessage(
      id: 'm11',
      text: 'Can we also test multi-account switching?',
      time: '12:37 PM',
      isOutgoing: false,
      senderName: 'Alex Chen',
    ),
    MockMessage(
      id: 'm12',
      text: 'You can maintain unlimited parallel sessions without relogging. Master PIN protects the vault.',
      time: '12:38 PM',
      isOutgoing: true,
      isRead: true,
    ),
    MockMessage(
      id: 'm13',
      text: 'And the cloud mascot covers its eyes when we enter the vault PIN! ☁️🔐',
      time: '12:39 PM',
      isOutgoing: false,
      senderName: 'Alex Chen',
    ),
    MockMessage(
      id: 'm14',
      text: 'Exactly! The eye-tracking glint and shy hands animation make it feel alive.',
      time: '12:40 PM',
      isOutgoing: true,
      isRead: true,
    ),
    MockMessage(
      id: 'm15',
      text: 'The new glass UI build looks incredible! 🌫️',
      time: '12:42 PM',
      isOutgoing: false,
      senderName: 'Alex Chen',
    ),
  ];
}
