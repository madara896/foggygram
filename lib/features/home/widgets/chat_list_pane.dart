import 'package:flutter/material.dart';
import 'package:foggygram/features/models/chat_models.dart';
import 'package:foggygram/features/home/widgets/chat_tile.dart';
import 'package:foggygram/shared/widgets/widgets.dart';

/// Middle pane displaying filterable and searchable chat lists in glass aesthetics.
class ChatListPane extends StatefulWidget {
  final List<MockChat> chats;
  final String? selectedChatId;
  final ValueChanged<MockChat> onSelectChat;

  const ChatListPane({
    super.key,
    required this.chats,
    required this.selectedChatId,
    required this.onSelectChat,
  });

  @override
  State<ChatListPane> createState() => _ChatListPaneState();
}

class _ChatListPaneState extends State<ChatListPane> {
  final TextEditingController _searchController = TextEditingController();
  int _categoryIndex = 0;
  final List<String> _categories = const ['All', 'Private', 'Groups', 'Channels'];
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MockChat> get _filteredChats {
    final category = _categories[_categoryIndex];
    return widget.chats.where((chat) {
      if (_searchQuery.isNotEmpty) {
        final matchesName =
            chat.name.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesMsg =
            chat.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase());
        if (!matchesName && !matchesMsg) return false;
      }

      if (category == 'All') return true;
      if (category == 'Private' && chat.category == 'Private') return true;
      if (category == 'Groups' && (chat.category == 'Groups' || chat.isGroup)) return true;
      if (category == 'Channels' && chat.category == 'Channels') return true;
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredChats;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
      ),
      child: Column(
        children: [
          // Top search & categories
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              children: [
                FrostSearch(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                  },
                ),
                const SizedBox(height: 12),
                FrostSegmented(
                  segments: _categories,
                  selectedIndex: _categoryIndex,
                  onChanged: (index) {
                    setState(() => _categoryIndex = index);
                  },
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.06),
          ),

          // List of chats
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No conversations found',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 13,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final chat = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: ChatTile(
                          name: chat.name,
                          lastMessage: chat.lastMessage,
                          time: chat.time,
                          unreadCount: chat.unreadCount,
                          avatarUrl: chat.avatarUrl,
                          isOnline: chat.isOnline,
                          isSelected: chat.id == widget.selectedChatId,
                          onTap: () => widget.onSelectChat(chat),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
