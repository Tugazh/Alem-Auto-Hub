import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/search_models.dart';

class SocialSearchPage extends StatefulWidget {
  const SocialSearchPage({super.key});

  @override
  State<SocialSearchPage> createState() => _SocialSearchPageState();
}

class _SocialSearchPageState extends State<SocialSearchPage> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  SearchResultModel? _result;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Поиск людей, постов, сообществ',
            border: InputBorder.none,
          ),
          onSubmitted: _search,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildResults(),
    );
  }

  Widget _buildResults() {
    final result = _result;
    if (result == null) {
      return const Center(child: Text('Введите запрос для поиска'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          'Люди',
          result.people.isEmpty
              ? const Text('Нет совпадений')
              : Column(
                  children: result.people
                      .map(
                        (person) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.surface,
                            backgroundImage: person.avatarUrl != null
                                ? NetworkImage(person.avatarUrl!)
                                : null,
                            child: person.avatarUrl == null
                                ? Text(person.name[0])
                                : null,
                          ),
                          title: Text(person.name),
                          subtitle: Text('@${person.username}'),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 16),
        _buildSection(
          'Сообщества',
          result.communities.isEmpty
              ? const Text('Нет совпадений')
              : Column(
                  children: result.communities
                      .map(
                        (community) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Text(
                            community.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(community.name),
                          subtitle: Text(
                            '${community.description} · ${community.membersCount} участников',
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 16),
        _buildSection(
          'Посты',
          result.posts.isEmpty
              ? const Text('Нет совпадений')
              : Column(
                  children: result.posts
                      .map(
                        (post) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(post.title),
                          subtitle: Text(post.snippet),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isLoading = true);
    final result = await ServiceLocator().searchService.search(query.trim());
    if (!mounted) return;
    setState(() {
      _result = result;
      _isLoading = false;
    });
  }
}
