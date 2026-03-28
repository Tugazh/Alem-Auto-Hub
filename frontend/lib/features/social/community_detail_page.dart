import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/community_model.dart';

class CommunityDetailPage extends StatefulWidget {
  final CommunityModel community;

  const CommunityDetailPage({super.key, required this.community});

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  CommunityModel? _community;
  List<CommunityMember> _members = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _community = widget.community;
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final service = ServiceLocator().communityService;
    final detail = await service.getCommunity(widget.community.id);
    final members = await service.getMembers(widget.community.id);
    if (!mounted) return;
    setState(() {
      _community = detail;
      _members = members;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final community = _community ?? widget.community;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: Text(community.name),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (community.coverUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      community.coverUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(community.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        community.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (community.isVerified)
                      const Icon(Icons.verified, color: AppColors.success),
                  ],
                ),
                const SizedBox(height: 8),
                Text(community.description),
                const SizedBox(height: 8),
                Text('${community.membersCount} участников'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _toggleJoin(community),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: community.isJoined
                        ? AppColors.surface
                        : AppColors.primary,
                  ),
                  child: Text(community.isJoined ? 'Покинуть' : 'Вступить'),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Участники',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _members
                      .map(
                        (member) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.surface,
                              backgroundImage: member.avatarUrl != null
                                  ? NetworkImage(member.avatarUrl!)
                                  : null,
                              child: member.avatarUrl == null
                                  ? Text(member.name[0])
                                  : null,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              member.name,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
    );
  }

  Future<void> _toggleJoin(CommunityModel community) async {
    final service = ServiceLocator().communityService;
    final updated = community.isJoined
        ? await service.leaveCommunity(community.id)
        : await service.joinCommunity(community.id);
    if (!mounted) return;
    setState(() {
      _community = updated;
    });
  }
}
