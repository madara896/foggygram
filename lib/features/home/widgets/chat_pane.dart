import 'package:flutter/material.dart';
import 'package:foggygram/core/theme/foggy_theme.dart';
import 'package:foggygram/features/models/chat_models.dart';
import 'package:foggygram/features/home/widgets/message_bubble.dart';
import 'package:foggygram/features/home/widgets/message_composer.dart';
import 'package:foggygram/shared/widgets/widgets.dart';

/// Center-right chat pane displaying active conversation history,
/// date markers, glass header, and composer.
class ChatPane extends StatefulWidget {
  final MockChat? selectedChat;
  final bool isInfoPaneOpen;
  final VoidCallback onToggleInfoPane;

  const ChatPane({
    super.key,
    required this.selectedChat,
    required this.isInfoPaneOpen,
    required this.onToggleInfoPane,
  });

  @override
  State<ChatPane> createState() => _ChatPaneState();
}

class _ChatPaneState extends State<ChatPane> {
  late List<MockMessage> _messages;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages = List.of(MockMessage.initialMessagesChat1);
  }

  void _handleSendMessage(String text) {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $ampm';

    setState(() {
      _messages.add(
        MockMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          text: text,
          time: timeStr,
          isOutgoing: true,
          isRead: false,
        ),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });

    // TODO: TDLib integration - send message to active peer via FFI
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedChat == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            FoggyCloudMascot(
              scale: 0.8,
              enableBobbing: true,
              enableMouseTracking: true,
              speechBubble: 'Select a chat to start messaging',
            ),
          ],
        ),
      );
    }

    final chat = widget.selectedChat!;

    return Column(
      children: [
        // Top Bar
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          child: Row(
            children: [
              FrostAvatar(
                size: 32,
                name: chat.name,
                imageUrl: chat.avatarUrl,
                isOnline: chat.isOnline,
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: FoggyTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    chat.isOnline ? 'Online' : 'last seen recently',
                    style: FoggyTextStyles.caption.copyWith(
                      fontSize: 11,
                      color: chat.isOnline
                          ? Colors.white.withOpacity(0.8)
                          : FoggyColors.muted,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Actions: search, call, info toggle
              IconButton(
                icon: const Icon(Icons.search_rounded, size: 19),
                color: FoggyColors.muted,
                splashRadius: 18,
                onPressed: () {},
                tooltip: 'Search in conversation',
              ),
              IconButton(
                icon: const Icon(Icons.phone_outlined, size: 19),
                color: FoggyColors.muted,
                splashRadius: 18,
                onPressed: () {},
                tooltip: 'Voice Call',
              ),
              IconButton(
                icon: Icon(
                  widget.isInfoPaneOpen
                      ? Icons.dock_rounded
                      : Icons.info_outline_rounded,
                  size: 19,
                ),
                color: widget.isInfoPaneOpen ? Colors.white : FoggyColors.muted,
                splashRadius: 18,
                onPressed: widget.onToggleInfoPane,
                tooltip: 'Toggle Details Pane',
              ),
            ],
          ),
        ),

        // Messages list
        Expanded(
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            children: [
              _buildDateSeparator('Yesterday'),
              ..._messages.take(3).map((m) => MessageBubble(
                    message: m,
                    isGroup: chat.isGroup,
                  )),
              _buildDateSeparator('Today'),
              ..._messages.skip(3).map((m) => MessageBubble(
                    message: m,
                    isGroup: chat.isGroup,
                  )),
            ],
          ),
        ),

        // Composer at bottom
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: MessageComposer(
            onSendMessage: _handleSendMessage,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSeparator(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Text(
            label,
            style: FoggyTextStyles.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: FoggyColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}
