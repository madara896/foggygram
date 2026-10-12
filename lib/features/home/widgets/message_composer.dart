import 'package:flutter/material.dart';
import 'package:foggygram/core/theme/foggy_theme.dart';
import 'package:foggygram/features/home/widgets/ai_sheet.dart';
import 'package:foggygram/shared/widgets/widgets.dart';

/// Bottom message composer with file attachment, emoji picker, AI generation sheet,
/// and smooth expandable input bar.
class MessageComposer extends StatefulWidget {
  final ValueChanged<String> onSendMessage;

  const MessageComposer({
    super.key,
    required this.onSendMessage,
  });

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;
  bool _showAiSheet = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasNow = _controller.text.trim().isNotEmpty;
      if (hasNow != _hasText) {
        setState(() => _hasText = hasNow);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // AI Sheet overlay positioned above composer
        if (_showAiSheet)
          Positioned(
            bottom: 64,
            right: 0,
            child: AiSheet(
              onClose: () => setState(() => _showAiSheet = false),
              onInsertText: (inserted) {
                setState(() {
                  _controller.text = inserted;
                });
              },
            ),
          ),

        // Main Composer FrostPanel
        FrostPanel(
          borderRadius: BorderRadius.circular(22),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          backgroundColor: Colors.white.withOpacity(0.06),
          borderColor: Colors.white.withOpacity(0.12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Attach button
              IconButton(
                icon: const Icon(Icons.attach_file_rounded, size: 20),
                color: FoggyColors.muted,
                splashRadius: 20,
                onPressed: () {},
                tooltip: 'Attach media or files',
              ),

              // Emoji button
              IconButton(
                icon: const Icon(Icons.sentiment_satisfied_outlined, size: 20),
                color: FoggyColors.muted,
                splashRadius: 20,
                onPressed: () {},
                tooltip: 'Stickers & Emoji',
              ),

              // Expanded input
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: FrostInput(
                    controller: _controller,
                    hintText: 'Write a message...',
                    maxLines: 5,
                    minLines: 1,
                    showBorder: false,
                    borderRadius: 18,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
              ),

              // AI sparkle button
              IconButton(
                icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                color: _showAiSheet ? Colors.white : FoggyColors.muted,
                splashRadius: 20,
                onPressed: () {
                  setState(() => _showAiSheet = !_showAiSheet);
                },
                tooltip: 'Foggy AI Assistant',
              ),

              // Send button (only visible when text non-empty)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _hasText ? 1.0 : 0.0,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 150),
                  scale: _hasText ? 1.0 : 0.8,
                  child: _hasText
                      ? FrostButton.primary(
                          width: 36,
                          height: 36,
                          borderRadius: 18,
                          padding: EdgeInsets.zero,
                          onPressed: _handleSend,
                          child: const Icon(
                            Icons.arrow_upward_rounded,
                            size: 19,
                            color: Colors.black,
                          ),
                        )
                      : const SizedBox(width: 36, height: 36),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ],
    );
  }
}
