import 'package:flutter/material.dart';
import 'package:foggygram/core/theme/foggy_theme.dart';
import 'package:foggygram/shared/widgets/widgets.dart';

/// Single item in the chat list reflecting Telegram conversations with
/// unread pills, online status, and macOS-style glass hover and selection highlights.
class ChatTile extends StatefulWidget {
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final String? avatarUrl;
  final bool isSelected;
  final bool isOnline;
  final VoidCallback? onTap;

  const ChatTile({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.avatarUrl,
    this.isSelected = false,
    this.isOnline = false,
    this.onTap,
  });

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.transparent;
    if (widget.isSelected) {
      bg = Colors.white.withOpacity(0.07);
    } else if (_isHovered) {
      bg = Colors.white.withOpacity(0.04);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Selected left border accent
              if (widget.isSelected)
                Positioned(
                  left: 0,
                  top: 14,
                  bottom: 14,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.40),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

              // Tile content
              Row(
                children: [
                  const SizedBox(width: 4),
                  FrostAvatar(
                    size: 42,
                    name: widget.name,
                    imageUrl: widget.avatarUrl,
                    isOnline: widget.isOnline,
                  ),
                  const SizedBox(width: 12),
                  // Center name & message snippet
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: FoggyTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: FoggyColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.lastMessage,
                          style: FoggyTextStyles.bodySmall.copyWith(
                            color: FoggyColors.muted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Right time & unread pill
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.time,
                        style: FoggyTextStyles.caption.copyWith(
                          fontSize: 11,
                          color: FoggyColors.muted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (widget.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${widget.unreadCount}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 19),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
