import 'package:flutter/material.dart';
import 'package:foggygram/core/theme/foggy_theme.dart';
import 'package:foggygram/features/models/chat_models.dart';
import 'package:foggygram/shared/widgets/widgets.dart';

/// Rightmost details pane for chat info, ghost mode toggles, shared media, and files.
class InfoPane extends StatefulWidget {
  final MockChat chat;
  final VoidCallback? onClose;

  const InfoPane({
    super.key,
    required this.chat,
    this.onClose,
  });

  @override
  State<InfoPane> createState() => _InfoPaneState();
}

class _InfoPaneState extends State<InfoPane> {
  bool _ghostModeEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Close button at top
          if (widget.onClose != null)
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                color: FoggyColors.muted,
                onPressed: widget.onClose,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ),

          // Large Avatar centered
          Center(
            child: FrostAvatar(
              size: 72,
              name: widget.chat.name,
              imageUrl: widget.chat.avatarUrl,
              isOnline: widget.chat.isOnline,
            ),
          ),
          const SizedBox(height: 12),

          // Name & username
          Center(
            child: Text(
              widget.chat.name,
              style: FoggyTextStyles.heading.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 2),
          Center(
            child: Text(
              '@${widget.chat.name.replaceAll(RegExp(r'\s+'), '').toLowerCase()}',
              style: FoggyTextStyles.caption.copyWith(color: FoggyColors.muted),
            ),
          ),
          const SizedBox(height: 20),

          // Ghost Mode toggle section
          FrostPanel(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            borderRadius: BorderRadius.circular(14),
            backgroundColor: Colors.white.withOpacity(0.04),
            child: FrostToggle(
              label: 'Ghost Mode',
              value: _ghostModeEnabled,
              onChanged: (val) {
                setState(() => _ghostModeEnabled = val);
              },
            ),
          ),
          const SizedBox(height: 14),

          // Info details in small FrostPanel
          FrostPanel(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            borderRadius: BorderRadius.circular(14),
            backgroundColor: Colors.white.withOpacity(0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Phone', '+1 555 000 1234'),
                const Divider(height: 18, color: Colors.white10),
                _buildInfoRow(
                  'Username',
                  '@${widget.chat.name.replaceAll(RegExp(r'\s+'), '').toLowerCase()}',
                ),
                const Divider(height: 18, color: Colors.white10),
                _buildInfoRow('Bio', 'Building the future of messaging'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Shared Media section
          Text(
            'Shared Media',
            style: FoggyTextStyles.label.copyWith(color: FoggyColors.text),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05 + (index % 3) * 0.02),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 18,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Shared Files section
          Text(
            'Shared Files',
            style: FoggyTextStyles.label.copyWith(color: FoggyColors.text),
          ),
          const SizedBox(height: 10),
          FrostPanel(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            borderRadius: BorderRadius.circular(14),
            backgroundColor: Colors.white.withOpacity(0.04),
            child: Column(
              children: [
                _buildFileRow('vault_spec_v1.pdf', '2.4 MB'),
                const Divider(height: 14, color: Colors.white10),
                _buildFileRow('tdlib_binding.rs', '840 KB'),
                const Divider(height: 14, color: Colors.white10),
                _buildFileRow('session_keys.bin', '128 KB'),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: FoggyTextStyles.caption.copyWith(
            fontSize: 11,
            color: FoggyColors.muted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: FoggyTextStyles.bodySmall.copyWith(
            color: FoggyColors.text,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFileRow(String name, String size) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.insert_drive_file_outlined,
            size: 16,
            color: FoggyColors.text,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: FoggyTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                size,
                style: FoggyTextStyles.caption.copyWith(
                  fontSize: 10,
                  color: FoggyColors.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
