import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/chat_models.dart';
import 'chat_detail_page.dart';

class ChatListTab extends StatefulWidget {
  final bool showAppBar;

  const ChatListTab({super.key, this.showAppBar = false});

  @override
  State<ChatListTab> createState() => _ChatListTabState();
}

class _ChatListTabState extends State<ChatListTab> {
  bool _isLoading = false;
  List<ChatThreadModel> _threads = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final threads = await ServiceLocator().chatService.getThreads();
      setState(() {
        _threads = threads;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Не удалось загрузить чаты';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(child: Text(_error!))
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _threads.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final thread = _threads[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                tileColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: const CircleAvatar(
                  backgroundColor: AppColors.background,
                  child: Icon(Icons.chat_bubble_outline),
                ),
                title: Text(thread.title),
                subtitle: Text(thread.lastMessage),
                trailing: thread.unreadCount > 0
                    ? CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          '${thread.unreadCount}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      )
                    : null,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatDetailPage(thread: thread),
                  ),
                ),
              );
            },
          );

    if (!widget.showAppBar) return body;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: const Text('Сообщения'),
      ),
      body: body,
    );
  }
}
