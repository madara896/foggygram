import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foggygram/core/ai_agent/foggy_agent_service.dart';
import 'package:foggygram/core/theme/foggy_theme.dart';
import 'package:foggygram/shared/widgets/widgets.dart';

/// Floating AI assistant sheet for composing replies, summarizing threads,
/// analyzing sentiment, and configuring stealth automation.
class AiSheet extends StatefulWidget {
  final VoidCallback onClose;
  final ValueChanged<String> onInsertText;

  const AiSheet({
    super.key,
    required this.onClose,
    required this.onInsertText,
  });

  @override
  State<AiSheet> createState() => _AiSheetState();
}

class _AiSheetState extends State<AiSheet> {
  final TextEditingController _promptController = TextEditingController();
  String _currentResponse = '';
  String _typedText = '';
  Timer? _typingTimer;
  bool _isGenerating = false;

  final Map<String, String> _actionResponses = const {
    'Write reply':
        'Thanks for testing! The glass performance on Windows desktop feels instantaneous, especially with hardware accelerated blur.',
    'Summarize':
        '• UI redesign verified with 0 accent colors.\n• Encrypted SQLite vault active.\n• Ghost mode and recovery tests passed.',
    'Translate':
        'Le nouveau build avec interface en verre dépoli fonctionne parfaitement avec le runtime TDLib.',
    'Mood analysis':
        'Sentiment: Positive & Enthusiastic (Confidence: 98%). The counterparty expresses excitement regarding UI aesthetics.',
    'Schedule':
        'Scheduled message prepared: "Following up on the cryptographic key benchmark at 3:00 PM tomorrow."',
    'Auto-settings':
        'Ghost mode preset active: Read receipts suppressed, typing indicator stealth mode enabled, story viewed incognito.',
  };

  final List<Map<String, dynamic>> _quickActions = const [
    {'title': 'Write reply', 'icon': Icons.edit_note_rounded},
    {'title': 'Summarize', 'icon': Icons.summarize_outlined},
    {'title': 'Translate', 'icon': Icons.translate_rounded},
    {'title': 'Mood analysis', 'icon': Icons.sentiment_satisfied_alt_rounded},
    {'title': 'Schedule', 'icon': Icons.schedule_rounded},
    {'title': 'Auto-settings', 'icon': Icons.auto_fix_high_rounded},
  ];

  @override
  void dispose() {
    _typingTimer?.cancel();
    _promptController.dispose();
    super.dispose();
  }

  void _triggerAction(String actionTitle) {
    final response = _actionResponses[actionTitle] ??
        'AI agent analyzed the conversation context and prepared a suggestion.';
    _startTyping(response);
  }

  Future<void> _submitCustomPrompt() async {
    final text = _promptController.text.trim();
    if (text.isEmpty) return;
    final agent = FoggyAgentService();
    final result = await agent.executeInstruction(text);
    _startTyping(result.responseMessage);
  }

  void _startTyping(String fullText) {
    _typingTimer?.cancel();
    setState(() {
      _currentResponse = fullText;
      _typedText = '';
      _isGenerating = true;
    });

    int index = 0;
    _typingTimer = Timer.periodic(const Duration(milliseconds: 18), (timer) {
      if (index < fullText.length) {
        setState(() {
          _typedText += fullText[index];
        });
        index++;
      } else {
        timer.cancel();
        setState(() {
          _isGenerating = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FrostPanel(
      width: 480,
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(22),
      backgroundColor: const Color(0xFF141416).withOpacity(0.92),
      borderColor: Colors.white.withOpacity(0.18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.65),
          blurRadius: 40,
          offset: const Offset(0, 10),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with small cloud mascot and close button
          Row(
            children: [
              Text(
                '✨ Foggy AI',
                style: FoggyTextStyles.heading.copyWith(fontSize: 17),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 32,
                height: 32,
                child: OverflowBox(
                  maxWidth: 120,
                  maxHeight: 120,
                  child: Transform.scale(
                    scale: 0.3,
                    child: const FoggyCloudMascot(
                      scale: 1.0,
                      enableBobbing: false,
                      enableMouseTracking: false,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                color: FoggyColors.muted,
                onPressed: widget.onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Quick Action Grid (2 columns)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickActions.map((action) {
              final title = action['title'] as String;
              final icon = action['icon'] as IconData;

              return SizedBox(
                width: 216,
                child: FrostPanel(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  borderRadius: BorderRadius.circular(12),
                  backgroundColor: Colors.white.withOpacity(0.04),
                  borderColor: Colors.white.withOpacity(0.08),
                  onTap: () => _triggerAction(title),
                  child: Row(
                    children: [
                      Icon(icon, size: 16, color: FoggyColors.text),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: FoggyTextStyles.caption.copyWith(
                            color: FoggyColors.text,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Response area if generated
          if (_typedText.isNotEmpty || _isGenerating) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _typedText,
                    style: FoggyTextStyles.bodySmall.copyWith(
                      color: FoggyColors.text,
                      height: 1.4,
                    ),
                  ),
                  if (_typedText.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FrostButton.primary(
                          label: 'Insert',
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          borderRadius: 8,
                          onPressed: () {
                            widget.onInsertText(_currentResponse);
                            widget.onClose();
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Custom prompt input
          Row(
            children: [
              Expanded(
                child: FrostInput(
                  controller: _promptController,
                  hintText: 'Ask Foggy AI anything...',
                  borderRadius: 12,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  onSubmitted: (_) => _submitCustomPrompt(),
                ),
              ),
              const SizedBox(width: 8),
              FrostButton.ghost(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                borderRadius: 12,
                onPressed: _submitCustomPrompt,
                child: const Icon(Icons.arrow_upward_rounded, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
