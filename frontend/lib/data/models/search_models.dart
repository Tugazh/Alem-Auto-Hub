class SearchPersonModel {
  final String id;
  final String name;
  final String username;
  final String? avatarUrl;

  const SearchPersonModel({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
  });

  factory SearchPersonModel.fromJson(Map<String, dynamic> json) {
    return SearchPersonModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }
}

class SearchCommunityModel {
  final String id;
  final String name;
  final String description;
  final int membersCount;
  final String emoji;

  const SearchCommunityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.membersCount,
    required this.emoji,
  });

  factory SearchCommunityModel.fromJson(Map<String, dynamic> json) {
    return SearchCommunityModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      membersCount: (json['membersCount'] as num?)?.toInt() ?? 0,
      emoji: json['emoji']?.toString() ?? '',
    );
  }
}

class SearchPostModel {
  final String id;
  final String title;
  final String snippet;
  final DateTime? createdAt;

  const SearchPostModel({
    required this.id,
    required this.title,
    required this.snippet,
    this.createdAt,
  });

  factory SearchPostModel.fromJson(Map<String, dynamic> json) {
    return SearchPostModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      snippet: json['snippet']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

class SearchResultModel {
  final String query;
  final List<SearchPersonModel> people;
  final List<SearchCommunityModel> communities;
  final List<SearchPostModel> posts;

  const SearchResultModel({
    required this.query,
    required this.people,
    required this.communities,
    required this.posts,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      query: json['query']?.toString() ?? '',
      people: (json['people'] as List<dynamic>? ?? [])
          .map((item) => SearchPersonModel.fromJson(item))
          .toList(),
      communities: (json['communities'] as List<dynamic>? ?? [])
          .map((item) => SearchCommunityModel.fromJson(item))
          .toList(),
      posts: (json['posts'] as List<dynamic>? ?? [])
          .map((item) => SearchPostModel.fromJson(item))
          .toList(),
    );
  }

  SearchResultModel copyWith({
    String? query,
    List<SearchPersonModel>? people,
    List<SearchCommunityModel>? communities,
    List<SearchPostModel>? posts,
  }) {
    return SearchResultModel(
      query: query ?? this.query,
      people: people ?? this.people,
      communities: communities ?? this.communities,
      posts: posts ?? this.posts,
    );
  }
}
