import 'package:flutter/material.dart';
import 'package:foggygram/core/theme/foggy_theme.dart';
import 'package:foggygram/features/models/chat_models.dart';
import 'package:foggygram/shared/widgets/widgets.dart';

/// Glassmorphism message bubble supporting incoming, outgoing, reply previews,
/// read receipts, and local deleted message recovery.
class MessageBubble extends StatefulWidget {
  final MockMessage message;
  final bool isGroup;
  final VoidCallback? onRestoreDeleted;

  const MessageBubble({
    super.key,
    required this.message,
    this.isGroup = false,
    this.onRestoreDeleted,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _isRecoveredViewOpen = false;

  @override
  Widget build(BuildContext context) {
    final msg = widget.message;
    final isOutgoing = msg.isOutgoing;

    final borderRadius = isOutgoing
        ? const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(6),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(20),
          );

    final bg = isOutgoing
        ? Colors.white.withOpacity(0.09)
        : Colors.white.withOpacity(0.05);

    final border = isOutgoing
        ? Colors.white.withOpacity(0.16)
        : Colors.white.withOpacity(0.10);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth * 0.65;

            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: FrostPanel(
                borderRadius: borderRadius,
                backgroundColor: bg,
                borderColor: border,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sender name for group chats
                    if (widget.isGroup && !isOutgoing && msg.senderName != null) ...[
                      Text(
                        msg.senderName!,
                        style: FoggyTextStyles.caption.copyWith(
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],

                    // Reply preview quote
                    if (msg.replyToText != null) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(8),
                          border: Border(
                            left: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                              width: 2.0,
                            ),
                          ),
                        ),
                        child: Text(
                          msg.replyToText!,
                          style: FoggyTextStyles.caption.copyWith(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],

                    // Deleted message layout vs normal message
                    if (msg.isDeleted) ...[
                      _buildDeletedContent(),
                    ] else ...[
                      Text(
                        msg.text,
                        style: FoggyTextStyles.body.copyWith(
                          color: FoggyColors.text,
                          height: 1.35,
                        ),
                      ),
                    ],

                    const SizedBox(height: 4),

                    // Timestamp and read receipt
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Spacer(),
                        Text(
                          msg.time,
                          style: FoggyTextStyles.caption.copyWith(
                            fontSize: 11,
                            color: FoggyColors.muted,
                          ),
                        ),
                        if (isOutgoing) ...[
                          const SizedBox(width: 4),
                          Text(
                            msg.isRead ? '✓✓' : '✓',
                            style: TextStyle(
                              fontSize: 12,
                              color: msg.isRead
                                  ? Colors.white.withOpacity(0.70)
                                  : FoggyColors.muted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDeletedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.block_outlined,
              size: 14,
              color: FoggyColors.muted,
            ),
            const SizedBox(width: 6),
            Text(
              'This message was deleted',
              style: FoggyTextStyles.body.copyWith(
                fontStyle: FontStyle.italic,
                color: FoggyColors.muted,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shield_outlined,
                size: 12,
                color: Colors.white.withOpacity(0.8),
              ),
              const SizedBox(width: 6),
              Text(
                'Recovered by Foggygram',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isRecoveredViewOpen = !_isRecoveredViewOpen;
                  });
                },
                child: Text(
                  _isRecoveredViewOpen ? 'Hide' : 'View',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isRecoveredViewOpen && widget.message.deletedOriginalText != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Text(
              widget.message.deletedOriginalText!,
              style: FoggyTextStyles.body.copyWith(
                color: Colors.white.withOpacity(0.95),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
