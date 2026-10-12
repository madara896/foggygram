import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:foggygram/core/theme/foggy_theme.dart';
import 'package:foggygram/features/models/chat_models.dart';
import 'package:foggygram/features/home/widgets/account_rail.dart';
import 'package:foggygram/features/home/widgets/chat_list_pane.dart';
import 'package:foggygram/features/home/widgets/chat_pane.dart';
import 'package:foggygram/features/home/widgets/info_pane.dart';

/// The central 3-column macOS desktop workspace for Foggygram.
/// Features a resizable chat list pane, multi-account rail, full chat view, and togglable info pane.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<MockAccount> _accounts = MockAccount.initialAccounts;
  late String _activeAccountId;

  final List<MockChat> _chats = MockChat.initialChats;
  MockChat? _selectedChat;

  double _chatListWidth = 320.0;
  bool _isInfoPaneOpen = true;

  @override
  void initState() {
    super.initState();
    _activeAccountId = _accounts.first.id;
    _selectedChat = _chats.first;
  }

  void _onResizeDrag(DragUpdateDetails details) {
    setState(() {
      _chatListWidth = (_chatListWidth + details.delta.dx).clamp(240.0, 480.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FoggyColors.base,
      body: Row(
        children: [
          // 1. AccountRail (64px wide)
          AccountRail(
            accounts: _accounts,
            activeAccountId: _activeAccountId,
            onSelectAccount: (accId) {
              setState(() => _activeAccountId = accId);
            },
            onAddAccount: () {
              context.go('/login');
            },
            onOpenSettings: () {
              context.go('/vault-unlock');
            },
          ),

          // Divider 1
          _buildDivider(),

          // 2. ChatListPane (resizable width, initial 320px)
          SizedBox(
            width: _chatListWidth,
            child: ChatListPane(
              chats: _chats,
              selectedChatId: _selectedChat?.id,
              onSelectChat: (chat) {
                setState(() => _selectedChat = chat);
              },
            ),
          ),

          // Resizer handle
          MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              onHorizontalDragUpdate: _onResizeDrag,
              child: Container(
                width: 4,
                color: Colors.transparent,
                child: Center(
                  child: Container(
                    width: 1,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
            ),
          ),

          // 3. Center-right ChatPane (expanded flex)
          Expanded(
            child: ChatPane(
              selectedChat: _selectedChat,
              isInfoPaneOpen: _isInfoPaneOpen,
              onToggleInfoPane: () {
                setState(() => _isInfoPaneOpen = !_isInfoPaneOpen);
              },
            ),
          ),

          // 4. Optional Right InfoPane (280px)
          if (_isInfoPaneOpen && _selectedChat != null) ...[
            _buildDivider(),
            InfoPane(
              chat: _selectedChat!,
              onClose: () {
                setState(() => _isInfoPaneOpen = false);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      color: Colors.white.withOpacity(0.06),
    );
  }
}
