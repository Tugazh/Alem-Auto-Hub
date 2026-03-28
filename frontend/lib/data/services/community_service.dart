import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../models/community_model.dart';
import '../mock/mock_data.dart';

class CommunityService {
  final ApiClient _apiClient;

  CommunityService(this._apiClient);

  Future<List<CommunityModel>> getCommunities({String? filter}) async {
    try {
      final response = await _apiClient.get(
        '/communities',
        queryParameters: {if (filter != null) 'filter': filter},
      );

      if (response.data is! List) {
        return _applyFilter(MockData.mockCommunities, filter);
      }

      final list = List<Map<String, dynamic>>.from(response.data);
      return list.map((json) => CommunityModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('⚠️ Failed to load communities: $e, using mock data');
      return _applyFilter(MockData.mockCommunities, filter);
    }
  }

  Future<CommunityModel> getCommunity(String id) async {
    try {
      final response = await _apiClient.get('/communities/$id');
      return CommunityModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('⚠️ Failed to load community: $e, using mock data');
      return MockData.mockCommunities.firstWhere(
        (item) => item.id == id,
        orElse: () => MockData.mockCommunities.first,
      );
    }
  }

  Future<List<CommunityMember>> getMembers(String id) async {
    try {
      final response = await _apiClient.get('/communities/$id/members');
      if (response.data is! List) {
        return MockData.mockCommunityMembers[id] ?? [];
      }
      final list = List<Map<String, dynamic>>.from(response.data);
      return list.map((json) => CommunityMember.fromJson(json)).toList();
    } catch (e) {
      debugPrint('⚠️ Failed to load members: $e, using mock data');
      return MockData.mockCommunityMembers[id] ?? [];
    }
  }

  Future<CommunityModel> joinCommunity(String id) async {
    try {
      final response = await _apiClient.post('/communities/$id/join');
      return CommunityModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('⚠️ Failed to join community: $e, using mock data');
      return _toggleJoin(id, true);
    }
  }

  Future<CommunityModel> leaveCommunity(String id) async {
    try {
      final response = await _apiClient.post('/communities/$id/leave');
      return CommunityModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('⚠️ Failed to leave community: $e, using mock data');
      return _toggleJoin(id, false);
    }
  }

  Future<CommunityModel> createCommunity({
    required String name,
    required String description,
    required String emoji,
  }) async {
    try {
      final response = await _apiClient.post(
        '/communities',
        data: {'name': name, 'description': description, 'emoji': emoji},
      );
      return CommunityModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('⚠️ Failed to create community: $e, using mock data');
      final created = CommunityModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        emoji: emoji,
        membersCount: 1,
        isJoined: true,
        isVerified: false,
      );
      MockData.mockCommunities.insert(0, created);
      return created;
    }
  }

  List<CommunityModel> _applyFilter(
    List<CommunityModel> items,
    String? filter,
  ) {
    if (filter == 'mine') {
      return items.where((item) => item.isJoined).toList();
    }
    return items;
  }

  CommunityModel _toggleJoin(String id, bool joined) {
    final index = MockData.mockCommunities.indexWhere((item) => item.id == id);
    if (index == -1) return MockData.mockCommunities.first;
    final item = MockData.mockCommunities[index];
    final updated = item.copyWith(
      isJoined: joined,
      membersCount: joined
          ? item.membersCount + 1
          : (item.membersCount > 0 ? item.membersCount - 1 : 0),
    );
    MockData.mockCommunities[index] = updated;
    return updated;
  }
}
